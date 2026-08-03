-- ============================================================
-- Buloke Farm — when an animal left
-- Apply after 20260802000014_stock_year.sql.
--
-- life_state has always said an animal was sold or died. It has never
-- said when, because the date sits on the animal_status row and the
-- view only carried the state. So the herd list could tell you S 26
-- was sold and not that it happened in July 2024.
--
-- Appended rather than rebuilt: CREATE OR REPLACE VIEW can add columns
-- at the end, and doing it that way leaves anything reading this view
-- untouched. The full definition is restated because Postgres requires
-- it, not because anything before exit_on has changed.
-- ============================================================

create or replace view v_animal_current with (security_invoker = on) as
select
  a.id, a.stock_code, a.year_letter, a.herd_number, a.name, a.nlis_tag,
  a.origin, a.sex, a.dob, a.breed, a.grade, a.coat_colour, a.polled,
  a.marking_code, a.birth_weight_kg, a.weaned_on, a.notes,
  a.purchased_on, a.purchase_note,
  a.heritage_id,  h.name  as heritage_name,
  a.property_id,  pr.pic  as pic,
  a.origin_property_id, opr.pic as origin_pic,
  a.sire_id, sire.name as sire_name,
  a.dam_id,  dam.stock_code as dam_code, dam.name as dam_name,

  (current_date - a.dob)                     as age_days,
  round((current_date - a.dob) / 30.4375, 2) as age_months,
  round((current_date - a.dob) / 365.25, 2)  as age_years,

  s.life_state, s.class,
  w.weight_kg  as last_weight_kg,
  w.weighed_on as last_weighed_on,
  case when w.weight_kg is not null and a.birth_weight_kg is not null
            and w.weighed_on > a.dob
       then round((w.weight_kg - a.birth_weight_kg) / (w.weighed_on - a.dob), 4)
  end as adg_kg_per_day,

  pk.id       as paddock_id,
  pk.name     as paddock_name,
  pk.colour   as paddock_colour,
  st.moved_in as in_paddock_since,

  cl.clear_domestic, cl.within_whp,

  -- The first time she stopped being alive. First rather than latest:
  -- a later row correcting her class doesn't move the day she was sold.
  -- exit_status_id comes along so the app can correct that exact row
  -- instead of guessing which one it meant.
  ex.effective_on as exit_on,
  ex.life_state   as exit_state,
  ex.id           as exit_status_id,
  ex.reason       as exit_reason

from animal a
left join animal dam   on dam.id  = a.dam_id
left join animal sire  on sire.id = a.sire_id
left join heritage h   on h.id    = a.heritage_id
left join property pr  on pr.id   = a.property_id
left join property opr on opr.id  = a.origin_property_id
left join lateral (
  select life_state, class from animal_status
  where animal_id = a.id and effective_on <= current_date
  order by effective_on desc limit 1) s on true
left join lateral (
  select weight_kg, weighed_on from weight_event
  where animal_id = a.id order by weighed_on desc limit 1) w on true
left join lateral (
  select paddock_id, moved_in from paddock_stay
  where animal_id = a.id and moved_out is null limit 1) st on true
left join lateral (
  select id, effective_on, life_state, reason from animal_status
  where animal_id = a.id and life_state <> 'alive'
  order by effective_on limit 1) ex on true
left join paddock pk on pk.id = st.paddock_id
left join v_animal_clearance cl on cl.animal_id = a.id
where a.origin <> 'reference';

comment on column animal_status.effective_on is
  'The day the change took effect, not the day it was typed. For a sale or a death this is the date the animal left.';

notify pgrst, 'reload schema';
