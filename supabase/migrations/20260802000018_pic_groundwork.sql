-- ============================================================
-- Buloke Farm — groundwork for a second PIC
-- Apply after 20260802000017_stock_year_animals.sql.
--
-- Two PICs registered against the same land, one herd running as one
-- mob, but two businesses and two tax returns. Nothing here changes
-- what the app does today — with one PIC every figure is identical.
-- It puts the identifier where it will be needed so that adding the
-- second herd is a filter rather than a rebuild.
--
-- Deliberately NOT done here:
--   * splitting the trading account by PIC — that changes the shape of
--     v_stock_year, and building it against a single value would be
--     building it blind. The column it needs is added below.
--   * per-PIC LPA treatment records. One drench run legitimately covers
--     both herds, so v_treatment_report has to become animal-aware
--     rather than gain a where clause. Noted, not attempted.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Every real animal belongs to a PIC.
--
-- Nullable was harmless while there was one. With two, an animal
-- without a PIC isn't neutral — it falls out of both filters and
-- lands in whichever report forgets to filter. Backfilled first,
-- then enforced.
--
-- Reference sires are exempt: a bull at another stud that exists
-- only to hang a pedigree on has no PIC here and shouldn't be given
-- a false one.
-- ------------------------------------------------------------

update animal
   set property_id = (select id from property where pic = '3BWWY089')
 where property_id is null
   and origin <> 'reference';

do $$ begin
  alter table animal add constraint animal_pic_required_ck
    check (origin = 'reference' or property_id is not null);
exception when duplicate_object then null; end $$;

comment on column animal.property_id is
  'The PIC this animal is registered to — whose it is, for NVD, NLIS and tax. Not where it grazes.';

-- ------------------------------------------------------------
-- 2. Which PIC is the primary registration for the land.
--
-- paddock.property_id means "which land", not "whose stock". Both
-- herds graze every paddock, so it must never be used to filter a
-- herd. With two own-PICs on one property, is_own alone can no longer
-- answer "which letterhead does this report carry" — so say it.
-- ------------------------------------------------------------

alter table property add column if not exists is_primary boolean not null default false;
alter table property add column if not exists trading_name text;

create unique index if not exists property_one_primary
  on property ((true)) where is_primary;

update property
   set is_primary   = true,
       trading_name = coalesce(trading_name, 'Buloke Farm'),
       address      = coalesce(address, '267 North Canal Rd, Trafalgar VIC 3824')
 where pic = '3BWWY089';

comment on column property.is_primary is
  'The registration the property itself trades under. Drives page letterheads and where new paddocks are attached. Exactly one.';

-- ------------------------------------------------------------
-- 3. Carry the PIC into the views that will need to filter on it.
--
-- Appended at the end of each, so nothing reading these views today
-- notices. The trading account gets it at the animal level, which is
-- where the split will eventually be made.
-- ------------------------------------------------------------

-- Stock: the base list every trading-account figure is counted from.
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
  an.property_id, pr.pic
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

-- Joinings: the dam's PIC decides whose calf it is.
drop view if exists v_joining_result;
create view v_joining_result with (security_invoker = on) as
select
  j.id, j.dam_id, d.stock_code as dam_code, d.name as dam_name,
  j.method,
  j.sire_id, coalesce(s.name, sem.sire_name) as sire_name,
  j.ai_semen_id, sem.straw_code, sem.tank,
  j.paddock_id, p.name as paddock_name,
  j.season, j.cycle, j.attempt, j.joined_on, j.bull_out, j.tested_on,
  j.gestation_days, j.due_on, j.confidence, j.outcome, j.notes,
  c.calved_on, c.outcome as calving_outcome,
  calf.stock_code as calf_code,
  (select count(*) from record_change_log l
    where l.table_name='joining' and l.row_id=j.id) as edits,
  d.property_id, dpr.pic
from joining j
join animal d on d.id = j.dam_id
left join property dpr  on dpr.id  = d.property_id
left join animal   s    on s.id    = j.sire_id
left join ai_semen sem  on sem.id  = j.ai_semen_id
left join paddock  p    on p.id    = j.paddock_id
left join calving  c    on c.joining_id = j.id
left join animal   calf on calf.id = c.calf_id;

-- Treatments: one run can legitimately cover both herds, so this says
-- which PICs were involved rather than pretending there is only one.
-- Appended to the definition from 007 — every existing column stays,
-- because the report page and the row editor both read them.
create or replace view v_treatment_report with (security_invoker = on) as
select
  t.id,
  t.treated_on, t.description, t.product_name, t.batch_number,
  t.product_expiry, t.dose_rate, t.route,
  t.withholding_days, t.esi_days, t.safe_for_slaughter,
  t.treated_by, t.treated_by_contact,
  coalesce(t.treated_by, u.display_name)  as treated_by_shown,
  coalesce(t.treated_by_contact, u.phone) as contact_shown,
  t.adverse_reaction, t.broken_needle, t.notes,
  count(ta.animal_id)                     as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags,
  (select count(*) from record_change_log l
    where l.table_name='treatment' and l.row_id=t.id) as edits,
  string_agg(distinct pr.pic, ', ')       as pics
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
left join animal a on a.id = ta.animal_id
left join property pr on pr.id = a.property_id
group by t.id, u.display_name, u.phone;

notify pgrst, 'reload schema';
