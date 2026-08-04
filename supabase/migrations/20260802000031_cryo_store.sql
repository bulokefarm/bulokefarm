-- ============================================================
-- Buloke Farm — the cryo store
-- Apply after 20260802000030_restore_expectations.sql.
--
-- Two tanks, six locations each. Tank 1 is semen. Tank 2 holds
-- embryos in locations 1 and 2, the rest reserved for semen. A
-- location holds straws from many bulls at once.
--
-- Three things this adds:
--
--   * where a straw physically is — tank and location
--   * embryos, which are a different animal to semen: two parents,
--     a stage and a grade, and implanted into a recipient rather
--     than used to inseminate
--   * a transaction ledger, because straws move constantly. The
--     spreadsheet's "No. in stock" cannot be derived from what is
--     recorded — A. Sundowner shows 1 delivered and 3 in stock, and
--     W Winds Beau's 35 are spread across Nu-Genes, Agri-gene and
--     Rupari. A counter that disagrees with its own working is worse
--     than no counter, so the count becomes a sum.
--
-- Every transaction names its female as text as well as by id. Most
-- of the inseminations on file are to Rupari cows that are not in
-- this database yet. The written name is the record; the link is an
-- improvement that can be made later without disturbing it.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Where things are.
-- ------------------------------------------------------------

alter table ai_semen add column if not exists location smallint
  check (location between 1 and 6);
alter table ai_semen add column if not exists marking text;      -- 'Yellow, white strws'
alter table ai_semen add column if not exists horn_status text;  -- H, P, PP
alter table ai_semen add column if not exists price_per_straw numeric(8,2);
alter table ai_semen add column if not exists cost_inc_gst numeric(10,2);

comment on column ai_semen.tank is 'Which flask. Two on the place.';
comment on column ai_semen.location is 'Canister position 1-6. A location holds straws from many bulls.';
comment on column ai_semen.straws_in is
  'What was delivered. Not the count on hand — that is the sum of the ledger.';

create index if not exists ai_semen_where_idx on ai_semen (tank, location);

-- ------------------------------------------------------------
-- 2. Embryos.
--
-- Not semen with extra columns: an embryo has a donor and a sire, it
-- is graded, and it goes into a recipient. Sharing a table would mean
-- half the columns null on every row.
-- ------------------------------------------------------------

create table if not exists embryo (
  id            uuid primary key default gen_random_uuid(),
  tank          text,
  location      smallint check (location between 1 and 6),
  donor_id      uuid references animal(id),   -- when she is on file
  donor_ref     text,                         -- as written, always
  sire_id       uuid references animal(id),
  sire_ref      text,
  pairing       text,                         -- 'Workman(PP) x Xallie(hh)'
  stage         text,                         -- '4/5', '6', '7'
  grade         text,                         -- '1'
  marking       text,                         -- 'clr tip yellow strw'
  flush_ref     text,                         -- 'K4189'
  collected_on  date,
  units_in      int check (units_in >= 0),
  cost_inc_gst  numeric(10,2),
  notes         text,
  retired_on    date,
  created_at    timestamptz not null default now(),
  created_by    uuid references farm_user(id) default auth.uid()
);

create index if not exists embryo_where_idx on embryo (tank, location);
create index if not exists embryo_donor_idx on embryo (donor_id);

comment on table embryo is
  'Frozen embryos. donor_ref and sire_ref hold the names as written, since many are Rupari animals not yet on file.';

-- ------------------------------------------------------------
-- 3. The ledger.
--
-- One table for both, because a straw and an embryo move the same
-- ways. Exactly one of the two references is set on each row.
-- ------------------------------------------------------------

do $$ begin
  if not exists (select 1 from pg_type where typname='cryo_kind_t') then
    create type cryo_kind_t as enum
      ('received','used','discarded','sent_out','returned','stocktake');
  end if;
end $$;

create table if not exists cryo_txn (
  id            uuid primary key default gen_random_uuid(),
  ai_semen_id   uuid references ai_semen(id) on delete cascade,
  embryo_id     uuid references embryo(id)   on delete cascade,
  kind          cryo_kind_t not null,

  -- Signed, and the sign has to agree with the kind. Half straws are
  -- real: a short straw or a plugged one gets recorded as it went.
  qty           numeric(6,2) not null,

  on_date       date not null,
  female_id     uuid references animal(id),   -- the cow, when she is on file
  female_ref    text,                         -- her name as written, always
  joining_id    uuid references joining(id) on delete set null,
  counterparty  text,                         -- 'Nu-Genes', 'Agri-gene'
  outcome       text,                         -- held, empty, slipped
  confidence    numeric(3,2) check (confidence between 0 and 1),
  notes         text,
  created_at    timestamptz not null default now(),
  created_by    uuid references farm_user(id) default auth.uid(),

  constraint cryo_txn_one_subject_ck
    check ((ai_semen_id is not null) <> (embryo_id is not null)),
  constraint cryo_txn_sign_ck check (
        (kind in ('received','returned')          and qty > 0)
     or (kind in ('used','discarded','sent_out')  and qty < 0)
     or (kind = 'stocktake'                       and qty <> 0))
);

create index if not exists cryo_txn_semen_idx  on cryo_txn (ai_semen_id, on_date);
create index if not exists cryo_txn_embryo_idx on cryo_txn (embryo_id, on_date);
create index if not exists cryo_txn_unmapped_idx on cryo_txn (female_ref)
  where female_id is null and female_ref is not null;

comment on column cryo_txn.qty is
  'Signed. Received and returned add, used, discarded and sent_out take away, a stocktake corrects either way.';
comment on column cryo_txn.female_ref is
  'The female as written on the sheet. Kept even once female_id is filled in — it is what the record actually said.';

-- ------------------------------------------------------------
-- 4. Counts are sums.
-- ------------------------------------------------------------

drop view if exists v_ai_semen;
create view v_ai_semen with (security_invoker = on) as
select
  s.*,
  coalesce(t.on_hand, 0)                       as straws_left,
  coalesce(t.used, 0)                          as straws_used,
  coalesce(a.stock_code, a.name, s.sire_name)  as sire_label,
  t.last_moved
from ai_semen s
left join animal a on a.id = s.sire_id
left join lateral (
  select sum(qty)                                        as on_hand,
         -sum(qty) filter (where kind = 'used')           as used,
         max(on_date)                                     as last_moved
    from cryo_txn where ai_semen_id = s.id
) t on true;

create or replace view v_embryo with (security_invoker = on) as
select
  e.*,
  coalesce(t.on_hand, 0)                          as units_left,
  coalesce(t.used, 0)                             as units_used,
  coalesce(d.stock_code, d.name, e.donor_ref)     as donor_label,
  coalesce(sa.stock_code, sa.name, e.sire_ref)    as sire_label,
  t.last_moved
from embryo e
left join animal d  on d.id  = e.donor_id
left join animal sa on sa.id = e.sire_id
left join lateral (
  select sum(qty)                                        as on_hand,
         -sum(qty) filter (where kind = 'used')           as used,
         max(on_date)                                     as last_moved
    from cryo_txn where embryo_id = e.id
) t on true;

-- What is in each location, so a tank can be checked against itself.
create or replace view v_cryo_location with (security_invoker = on) as
select tank, location, 'semen' as holds,
       count(*)::int as entries, sum(straws_left)::numeric as units
  from v_ai_semen where retired_on is null and tank is not null
 group by tank, location
union all
select tank, location, 'embryo',
       count(*)::int, sum(units_left)::numeric
  from v_embryo where retired_on is null and tank is not null
 group by tank, location
 order by tank, location, holds;

-- The mapping worklist. Every insemination whose cow is named but not
-- linked — which is most of them until Rupari's herd is imported.
create or replace view v_cryo_unmapped with (security_invoker = on) as
select t.id, t.on_date, t.kind, t.female_ref,
       coalesce(s.sire_name, e.pairing) as subject,
       t.notes
  from cryo_txn t
  left join ai_semen s on s.id = t.ai_semen_id
  left join embryo   e on e.id = t.embryo_id
 where t.female_id is null and t.female_ref is not null
 order by t.on_date desc;

comment on view v_cryo_unmapped is
  'Transactions naming a female who is not on file. Shrinks as herds are imported; not an error list.';

-- ------------------------------------------------------------
-- 5. RLS and change logging, same shape as everything else.
-- ------------------------------------------------------------

alter table embryo   enable row level security;
alter table cryo_txn enable row level security;

do $$
declare t text;
begin
  foreach t in array array['embryo','cryo_txn'] loop
    execute format('drop policy if exists %I_read   on %I', t, t);
    execute format('drop policy if exists %I_insert on %I', t, t);
    execute format('drop policy if exists %I_update on %I', t, t);
    execute format('drop policy if exists %I_delete on %I', t, t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format('create policy %I_delete on %I for delete to authenticated using (my_role() = ''owner'')', t, t);
  end loop;
end $$;

drop trigger if exists embryo_changed on embryo;
create trigger embryo_changed after update or delete on embryo
  for each row execute function log_record_change();

drop trigger if exists cryo_txn_changed on cryo_txn;
create trigger cryo_txn_changed after update or delete on cryo_txn
  for each row execute function log_record_change();

notify pgrst, 'reload schema';
