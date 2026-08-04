-- ============================================================
-- Buloke Farm — sheep
-- Apply after 20260802000018_pic_groundwork.sql.
--
-- One animal table, not a parallel set of sheep tables. Nearly every
-- sheep record in the spreadsheet is something this schema already
-- holds: the drench is a treatment, the ram going out is a joining
-- with a paddock and a mob, the sale is a consignment, the death is
-- a status change, the sire is a reference animal. Duplicating twenty
-- tables to hold ninety sheep would double the schema and buy nothing.
--
-- Gestation is already per-dam, so 145 days is data rather than a
-- special case.
--
-- What genuinely doesn't exist yet is shearing.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Which animal is which.
-- ------------------------------------------------------------

do $$ begin
  if not exists (select 1 from pg_type where typname='species_t') then
    create type species_t as enum ('cattle','sheep');
  end if;
end $$;

alter table animal add column if not exists species species_t not null default 'cattle';
create index if not exists animal_species_idx on animal (species);

comment on column animal.species is
  'Everything on the books so far is cattle, so that is the default. Set explicitly on import.';

-- ------------------------------------------------------------
-- 2. Vocabulary.
--
-- Less new than expected: yearling, harvest and breeder already carry
-- the Adult ewes, the Yearlings and the Harvest lambs. Only the lamb
-- and the ram have nowhere to sit, and only the wether is missing
-- from sex — it is to a ram what a steer is to a bull.
--
-- ADD VALUE is deliberately not used anywhere below. A value added
-- here cannot be used until this has committed.
-- ------------------------------------------------------------

alter type sex_t          add value if not exists 'wether';
alter type animal_class_t add value if not exists 'lamb';
alter type animal_class_t add value if not exists 'ram';

-- ------------------------------------------------------------
-- 3. Shearing.
--
-- A mob event with a date and a list of animals, like a treatment,
-- and modelled the same way. Marking is included as a kind because
-- that is how it is recorded in practice — tallied with the shed
-- work rather than with the drenches.
-- ------------------------------------------------------------

do $$ begin
  if not exists (select 1 from pg_type where typname='shearing_kind_t') then
    create type shearing_kind_t as enum ('shearing','crutching','clip','marking');
  end if;
end $$;

create table if not exists shearing (
  id           uuid primary key default gen_random_uuid(),
  shorn_on     date not null,
  kind         shearing_kind_t not null default 'shearing',
  description  text,                        -- 'Summer clip', 'Autumn shearing'
  contractor   text,
  bales        numeric(6,2) check (bales >= 0),
  micron       numeric(4,1) check (micron > 0),
  notes        text,
  recorded_by  uuid references farm_user(id) default auth.uid(),
  created_at   timestamptz not null default now()
);
create index if not exists shearing_date_idx on shearing (shorn_on desc);

create table if not exists shearing_animal (
  shearing_id uuid not null references shearing(id) on delete cascade,
  animal_id   uuid not null references animal(id) on delete cascade,
  primary key (shearing_id, animal_id)
);

alter table shearing        enable row level security;
alter table shearing_animal enable row level security;

do $$
declare t text;
begin
  foreach t in array array['shearing','shearing_animal'] loop
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

drop trigger if exists shearing_changed on shearing;
create trigger shearing_changed after update or delete on shearing
  for each row execute function log_record_change();

create or replace view v_shearing with (security_invoker = on) as
select
  s.id, s.shorn_on, s.kind, s.description, s.contractor,
  s.bales, s.micron, s.notes,
  count(sa.animal_id)                                  as head,
  string_agg(a.stock_code, ', ' order by a.stock_code)  as tags,
  (select count(*) from record_change_log l
    where l.table_name='shearing' and l.row_id=s.id)   as edits
from shearing s
left join shearing_animal sa on sa.shearing_id = s.id
left join animal a on a.id = sa.animal_id
group by s.id;

-- ------------------------------------------------------------
-- 4. Species through to the trading account.
--
-- A sheep and a cow are not interchangeable head, so the schedule
-- will have to split. The column goes in at the animal level now;
-- splitting the totals is a change to the page and waits until there
-- is sheep data to test it against.
-- ------------------------------------------------------------

drop view if exists v_stock_year_class;
drop view if exists v_stock_year;
drop view if exists v_stock_year_animal;

create view v_stock_year_animal with (security_invoker = on) as
with span as (
  select
    least(
      coalesce((select min(effective_on) from animal_status), current_date),
      coalesce((select min(dob) from animal where origin <> 'reference'), current_date)
    ) as d0,
    greatest(
      coalesce((select max(effective_on) from animal_status), current_date),
      current_date
    ) as d1
  ),
years as (
  select fy, make_date(fy - 1, 7, 1) as fy_start, make_date(fy, 6, 30) as fy_end
  from span,
  generate_series(
    extract(year from d0)::int + case when extract(month from d0) >= 7 then 1 else 0 end,
    extract(year from d1)::int + case when extract(month from d1) >= 7 then 1 else 0 end
  ) as fy
),
opening as (
  select y.fy, y.fy_start, y.fy_end, 'opening'::text as bucket,
         a.id as animal_id, s.effective_on as on_date, s.class, null::text as detail
  from years y
  cross join animal a
  join lateral (
    select effective_on, life_state, class from animal_status
     where animal_id = a.id and effective_on < y.fy_start
     order by effective_on desc limit 1) s on true
  where a.origin <> 'reference' and s.life_state = 'alive'
),
closing as (
  select y.fy, y.fy_start, y.fy_end, 'closing'::text,
         a.id, s.effective_on, s.class, null::text
  from years y
  cross join animal a
  join lateral (
    select effective_on, life_state, class from animal_status
     where animal_id = a.id and effective_on <= y.fy_end
     order by effective_on desc limit 1) s on true
  where a.origin <> 'reference' and s.life_state = 'alive'
),
entries as (
  select y.fy, y.fy_start, y.fy_end,
         case when e.origin = 'purchased' then 'purchases' else 'natural_increase' end,
         e.animal_id, e.entered_on, null::animal_class_t, e.origin::text
  from years y
  join v_stock_entry e on e.entered_on between y.fy_start and y.fy_end
),
exits as (
  select y.fy, y.fy_start, y.fy_end,
         case x.exit_kind when 'sale'  then 'sales'
                          when 'death' then 'deaths'
                          else 'rations' end,
         x.animal_id, x.effective_on, null::animal_class_t,
         coalesce(x.destination_kind::text, x.life_state::text)
  from years y
  join v_stock_exit x on x.effective_on between y.fy_start and y.fy_end
)
select
  u.fy,
  (u.fy - 1) || '-' || right(u.fy::text, 2) as fy_label,
  u.fy_start, u.fy_end, u.bucket,
  u.animal_id, an.stock_code, an.name, an.sex, an.breed, an.dob,
  u.on_date,
  coalesce(u.class::text, 'unclassed') as class,
  u.detail,
  an.property_id, pr.pic,
  an.species
from (
  select * from opening
  union all select * from closing
  union all select * from entries
  union all select * from exits
) u
join animal an on an.id = u.animal_id
left join property pr on pr.id = an.property_id;

create view v_stock_year with (security_invoker = on) as
select
  fy, fy_label, fy_start, fy_end,
  count(*) filter (where bucket = 'opening')::int          as opening,
  count(*) filter (where bucket = 'purchases')::int        as purchases,
  count(*) filter (where bucket = 'natural_increase')::int as natural_increase,
  count(*) filter (where bucket = 'sales')::int            as sales,
  count(*) filter (where bucket = 'deaths')::int           as deaths,
  count(*) filter (where bucket = 'rations')::int          as rations,
  count(*) filter (where bucket = 'closing')::int          as closing
from v_stock_year_animal
group by fy, fy_label, fy_start, fy_end
order by fy;

create view v_stock_year_class with (security_invoker = on) as
select fy, fy_label, class, count(*)::int as head
from v_stock_year_animal
where bucket = 'closing'
group by fy, fy_label, class
order by fy, class;

notify pgrst, 'reload schema';
