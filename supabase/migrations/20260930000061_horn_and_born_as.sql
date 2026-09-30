-- ============================================================
-- 61. Horn as it is written, and how many were born.
--
-- Two things Toland's ewe file records that the animal could not.
--
-- Horn. animal.polled was a boolean, true or false, from the cattle
-- sheet's P/H column. A stud writes the poll genotype: PP, PH or HH,
-- and the middle one is the one that matters — a PH ewe is polled to
-- look at and carries a horn allele, and collapsing that to true
-- throws away the reason the test was done. polled becomes horn,
-- text, one of five: P and H for what was seen, PP PH HH for what
-- was tested. Nothing is invented on the way across: a cow written
-- P stays P, because nobody tested her and she may be PH.
--
-- Born as. A lambing is one calving row per lamb, so litter size can
-- be counted — but only when the dam and every sibling are on file.
-- For an imported ewe whose twin was sold years ago they never will
-- be, and "born a twin" is a birth fact a stud keeps and breeds on,
-- not a derivation. born_as is that fact, 1 to 5, null when not
-- known.
--
-- The change log captures rows as jsonb, so it needs no change.
-- v_animal_current names its columns and has to be dropped to swap
-- one out; nothing else depends on it (record_drop reads it by name
-- at run time, which survives a drop).
--
-- Safe to run more than once.
-- ============================================================

-- 1. The new column, filled from the old one while it is still there.
alter table animal add column if not exists horn text;

alter table animal drop constraint if exists animal_horn_ck;
alter table animal add constraint animal_horn_ck
  check (horn in ('P', 'H', 'PP', 'PH', 'HH'));

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'animal'
                and column_name = 'polled') then
    update animal
       set horn = case polled when true then 'P' when false then 'H' end
     where horn is null and polled is not null;
  end if;
end $$;

comment on column animal.horn is
  'P or H as seen; PP, PH or HH as tested. A P was never tested and may be PH.';

-- 2. How many in the litter.
alter table animal add column if not exists born_as smallint;

alter table animal drop constraint if exists animal_born_as_ck;
alter table animal add constraint animal_born_as_ck
  check (born_as between 1 and 5);

comment on column animal.born_as is
  'How many were born with this one, itself included: 1 single, 2 twin, 3 triplet. Null when not known.';

-- 3. The herd view, as in 38, with horn where polled was and born_as
--    beside birth weight. Dropped rather than replaced because a
--    column cannot change type in place.
drop view if exists v_animal_current;

alter table animal drop column if exists polled;

create view v_animal_current with (security_invoker = on) as
select
  a.id, a.stock_code, a.year_letter, a.herd_number, a.name, a.nlis_tag,
  a.origin, a.sex, a.dob, a.breed, a.grade, a.coat_colour, a.horn,
  a.marking_code, a.birth_weight_kg, a.born_as, a.weaned_on, a.notes,
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

-- Check:
--   select horn, count(*) from animal group by 1;   -- P for every cow written P, nothing else
--   select born_as from v_animal_current limit 1;   -- the column is there, null
