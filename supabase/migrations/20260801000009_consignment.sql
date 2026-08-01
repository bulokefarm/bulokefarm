-- ============================================================
-- Buloke Farm — consignments, NVD and waybill
-- Apply after 11_feed_adjust.sql. Safe to run more than once.
--
-- Replaces the placeholder `movement` tables from 01 (never populated)
-- with a proper consignment record covering LPA 5A/5B.
--
-- The point of doing this in the database rather than on paper: the
-- NVD asks whether any animal is inside a withholding period, and the
-- treatment records already know the answer.
-- ============================================================

drop table if exists movement_animal;
drop table if exists movement;

do $$
begin
  if not exists (select 1 from pg_type where typname='consign_dir_t') then
    create type consign_dir_t as enum ('out','in');
  end if;
  if not exists (select 1 from pg_type where typname='nvd_kind_t') then
    create type nvd_kind_t as enum ('book','envd');
  end if;
  if not exists (select 1 from pg_type where typname='destination_t') then
    create type destination_t as enum ('saleyard','abattoir','property','agent','other');
  end if;
end $$;

create table if not exists consignment (
  id             uuid primary key default gen_random_uuid(),
  direction      consign_dir_t not null default 'out',
  consigned_on   date not null default current_date,

  -- Paperwork
  nvd_kind       nvd_kind_t,
  nvd_serial     text,                 -- book serial, or the eNVD number
  waybill_no     text,
  nlis_upload_id text,                 -- from the NLIS transfer
  nlis_sent_on   date,

  -- Where it went
  destination_kind destination_t,
  destination      text,               -- 'Pakenham saleyards'
  destination_pic  text,
  counterparty     text,               -- buyer, vendor or agent
  carrier          text,
  vehicle_rego     text,

  head_declared  int,
  notes          text,

  -- NVD declarations. Recorded as answered, not inferred, but the app
  -- pre-fills them from the records and flags disagreements.
  q_owned_since_birth     boolean,
  q_ram_fed               boolean,
  q_byproduct_fed         boolean,
  q_within_whp            boolean,
  q_hgp_treated           boolean,
  q_chemical_risk         boolean,
  q_movement_restriction  boolean,
  declared_by    text,
  declared_on    date,

  recorded_by    uuid references farm_user(id) default auth.uid(),
  created_at     timestamptz not null default now()
);
create index if not exists consignment_date_idx on consignment (consigned_on desc);
create unique index if not exists consignment_nvd_uq
  on consignment (nvd_serial) where nvd_serial is not null;

create table if not exists consignment_animal (
  consignment_id    uuid not null references consignment(id) on delete cascade,
  animal_id         uuid not null references animal(id) on delete restrict,
  lot               text,
  sale_weight_kg    numeric(7,2),
  carcass_weight_kg numeric(7,2),
  price_per_kg      numeric(8,3),
  amount_ex_gst     numeric(12,2),
  gst               numeric(12,2),
  fees              numeric(12,2),
  primary key (consignment_id, animal_id)
);

drop trigger if exists consignment_changed on consignment;
create trigger consignment_changed after update or delete on consignment
  for each row execute function log_record_change();

-- ------------------------------------------------------------
-- Withholding clearance, per animal.
-- safe_for_slaughter is already generated on treatment; this rolls
-- up the latest one and adds the export interval.
-- ------------------------------------------------------------

create or replace view v_animal_clearance with (security_invoker = on) as
select
  a.id                                    as animal_id,
  a.stock_code,
  max(t.safe_for_slaughter)               as clear_domestic,
  max(t.treated_on + coalesce(t.esi_days,0)) as clear_export,
  max(t.treated_on)                       as last_treated,
  (max(t.safe_for_slaughter) > current_date)               as within_whp,
  (max(t.treated_on + coalesce(t.esi_days,0)) > current_date) as within_esi
from animal a
left join treatment_animal ta on ta.animal_id = a.id
left join treatment t on t.id = ta.treatment_id
where a.origin <> 'reference'
group by a.id, a.stock_code;

-- ------------------------------------------------------------
-- Consigning: attach the animals, mark them gone, empty the paddock.
-- Refuses if anything is still inside a withholding period unless
-- you deliberately override.
-- ------------------------------------------------------------

create or replace function consign_animals(
    p_consignment uuid,
    p_animal_ids  uuid[],
    p_override_whp boolean default false)
returns int language plpgsql security invoker set search_path = public as $$
declare
  c        consignment%rowtype;
  blocked  text;
  new_state life_state_t;
  n int;
begin
  select * into c from consignment where id = p_consignment;
  if not found then raise exception 'Consignment not found'; end if;

  if c.direction = 'out' and not p_override_whp then
    select string_agg(stock_code, ', ' order by stock_code) into blocked
      from v_animal_clearance
     where animal_id = any(p_animal_ids) and clear_domestic > c.consigned_on;
    if blocked is not null then
      raise exception 'Still inside a withholding period: %', blocked;
    end if;
  end if;

  insert into consignment_animal (consignment_id, animal_id)
  select p_consignment, unnest(p_animal_ids)
  on conflict do nothing;
  get diagnostics n = row_count;

  if c.direction = 'out' then
    new_state := case when c.destination_kind = 'abattoir'
                      then 'slaughtered'::life_state_t else 'sold'::life_state_t end;

    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    select unnest(p_animal_ids), c.consigned_on, new_state, null,
           concat_ws(' ', 'Consigned to', c.destination,
                     case when c.nvd_serial is not null then '· NVD '||c.nvd_serial end)
    on conflict (animal_id, effective_on) do update
      set life_state = excluded.life_state, reason = excluded.reason;

    update paddock_stay set moved_out = c.consigned_on
     where animal_id = any(p_animal_ids) and moved_out is null;
  end if;

  update consignment set head_declared = (
    select count(*) from consignment_animal where consignment_id = p_consignment)
   where id = p_consignment;

  return n;
end $$;

-- ------------------------------------------------------------
-- Reporting view — LPA 5A/5B.
-- ------------------------------------------------------------

create or replace view v_consignment with (security_invoker = on) as
select
  c.*,
  u.display_name                                   as recorded_by_name,
  count(ca.animal_id)                              as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags,
  sum(ca.sale_weight_kg)                           as total_kg,
  sum(ca.amount_ex_gst)                            as total_ex_gst,
  (select count(*) from record_change_log l
    where l.table_name='consignment' and l.row_id=c.id) as edits
from consignment c
left join farm_user u on u.id = c.recorded_by
left join consignment_animal ca on ca.consignment_id = c.id
left join animal a on a.id = ca.animal_id
group by c.id, u.display_name;

-- ------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['consignment','consignment_animal'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists %I_read on %I', t, t);
    execute format('drop policy if exists %I_insert on %I', t, t);
    execute format('drop policy if exists %I_update on %I', t, t);
    execute format('drop policy if exists %I_delete on %I', t, t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format($f$create policy %I_delete on %I for delete to authenticated using (my_role() = 'owner')$f$, t, t);
  end loop;
end $$;
