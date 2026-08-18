-- ============================================================
-- Buloke Farm — the run they just came off
-- Apply after 20260802000037_run_not_drop.sql.
-- Safe to run more than once.
--
-- Days on feed vanishes the moment a run is closed. That is right
-- for "is this animal on feed today", and useless for the question
-- actually asked at sale time: how long was it fed, and when did it
-- come off. A steer that finished 94 days a fortnight ago should
-- still say so on the herd list.
--
-- So the last CLOSED run is carried alongside the open one. An
-- animal can have both — off the March load, on the June one — and
-- the two never merge: the open run is what it is on now, the
-- closed one is what it came off.
-- ============================================================

-- Only runs count, not drops: 037's distinction applies here too, or
-- every bale rolled out last winter would read as a finished run.
create or replace view v_animal_feed_last with (security_invoker = on) as
select distinct on (c.animal_id)
  c.animal_id,
  c.fed_on                          as last_run_from,
  c.ended_on                        as off_feed_on,
  (c.ended_on - c.fed_on)           as days_fed_last,
  coalesce(fs.feedstuff, c.ration)  as last_feedstuff
from v_feed_cover c
join feed_event fe on fe.id = c.feed_event_id and fe.is_run
left join feed_source fs on fs.id = c.feed_source_id
where c.ended_on is not null
order by c.animal_id, c.ended_on desc, c.fed_on;

-- Appended to v_animal_current, so the herd list still costs one query.
create or replace view v_animal_current with (security_invoker = on) as
select
  a.id, a.stock_code, a.year_letter, a.herd_number, a.name, a.nlis_tag,
  a.origin, a.sex, a.dob, a.breed, a.grade, a.coat_colour, a.polled,
  a.marking_code, a.birth_weight_kg, a.weaned_on, a.notes,
  a.purchased_on, a.purchase_note,
  a.heritage_id,  h.name  as heritage_name,
  a.property_id,  pr.pic  as pic,
  a.origin_property_id, opr.pic as origin_pic,
  a.sire_id, coalesce(sire.name, sire.stock_code) as sire_name,
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
  a.gestation_days,
  sire.stock_code as sire_code,

  fd.on_feed_since,
  fd.days_on_feed,
  fd.feedstuff as on_feed_feedstuff,

  fd.est_empty_on,
  fd.est_days_left,

  lf.off_feed_on,
  lf.days_fed_last,
  lf.last_feedstuff

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
left join v_animal_feed fd on fd.animal_id = a.id
left join v_animal_feed_last lf on lf.animal_id = a.id
where a.origin <> 'reference';

notify pgrst, 'reload schema';
