-- ============================================================
-- Buloke Farm — species through to the app
-- Apply after the sheep import.
--
-- species went onto animal in 019 and into the trading-account views,
-- but not into the two views the app actually reads. So the herd list
-- is now 151 animals with nothing to tell a ewe from a cow, and the
-- sire and dam pickers offer rams for a cattle joining.
--
-- Both are appended to, not rebuilt: CREATE OR REPLACE can add columns
-- at the end, and nothing reading them today needs to change.
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

  ex.effective_on as exit_on,
  ex.life_state   as exit_state,
  ex.id           as exit_status_id,
  ex.reason       as exit_reason,

  a.species,
  a.gestation_days

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

-- A ram is not a candidate sire for a cow. The picker has to be able
-- to narrow, and it can't without knowing which is which.
create or replace view v_breeding_stock with (security_invoker = on) as
select a.id, a.name, a.stock_code, a.sex, a.origin,
       coalesce(nullif(trim(concat_ws(' ', a.stock_code, a.name)), ''), 'Unnamed') as label,
       a.species
from animal a
where a.origin = 'reference' or a.sex in ('female','male');

notify pgrst, 'reload schema';
