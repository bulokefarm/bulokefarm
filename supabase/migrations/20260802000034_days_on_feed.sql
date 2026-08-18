-- ============================================================
-- Buloke Farm — days on feed, and closing a feed run when the
-- load runs out.
-- Apply after 20260802000033_resolve_female_refs.sql.
-- Safe to run more than once.
--
-- Two things were missing.
--
-- 1. Nothing said how long an animal had been on the ration. The
--    data was all there — feed_event.fed_on with ended_on null is
--    an open run — but no view exposed it, so the herd list had no
--    way to show it. Days on feed is the number the buyer asks for,
--    so it belongs on the animal, not buried in a feed report.
--
-- 2. "Mark as all used up" already sets feed_source.exhausted_on,
--    and the store view already hides exhausted loads. But the
--    feed_events pointing at that source stayed OPEN forever, so
--    every animal on the Irwins run would have gone on counting
--    days months after the silo was empty. Setting exhausted_on now
--    closes them, on the same date.
--
-- WHO IS ON A RUN. Feeding is normally recorded against a paddock
-- and the eaters are derived from paddock_stay. But the Irwins runs
-- came across from the old per-animal feeding_period table, so they
-- name their animals directly and carry no paddock. Both shapes have
-- to count, or the Cottage Paddock mob shows nothing.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Make the amounts already recorded countable.
--
-- The Irwins events carry '3.95 tonne' and '4.00 tonne' as free
-- text in `amount`; the numeric `qty` column added later was never
-- backfilled, so the store balance has been null the whole time.
-- This parses what is already written rather than inventing it.
-- ------------------------------------------------------------

update feed_event
   set qty = substring(amount from '^[0-9]+(?:\.[0-9]+)?')::numeric
 where qty is null
   and amount is not null
   and amount ~ '^[0-9]';

-- Give the source the unit its own feed-outs are written in, but only
-- when every parseable event agrees. A source fed out in both bales
-- and tonnes is a data problem, not something to average over.
update feed_source fs
   set unit = u.unit
  from (
    select fe.feed_source_id,
           min(lower(substring(fe.amount from '[A-Za-z]+'))) as unit,
           count(distinct lower(substring(fe.amount from '[A-Za-z]+'))) as variants
      from feed_event fe
     where fe.feed_source_id is not null
       and fe.amount ~ '[A-Za-z]'
     group by fe.feed_source_id
  ) u
 where u.feed_source_id = fs.id
   and u.variants = 1
   and fs.unit is null;

-- ------------------------------------------------------------
-- 2. Who is on what, and since when.
--
-- One row per animal per feed event that covers it, from either
-- shape. `union` not `union all`: an event that both names an animal
-- and covers its paddock is one feeding, not two.
-- ------------------------------------------------------------

create or replace view v_feed_cover with (security_invoker = on) as
select fa.animal_id, fe.id as feed_event_id, fe.fed_on, fe.ended_on,
       fe.feed_source_id, fe.ration, fe.paddock_id
  from feed_event fe
  join feed_event_animal fa on fa.feed_event_id = fe.id
union
select s.animal_id, fe.id, fe.fed_on, fe.ended_on,
       fe.feed_source_id, fe.ration, fe.paddock_id
  from feed_event fe
  join paddock_stay s
    on s.paddock_id = fe.paddock_id
   and s.moved_in  <= coalesce(fe.ended_on, current_date)
   and (s.moved_out is null or s.moved_out >= fe.fed_on)
 where fe.paddock_id is not null;

-- The current run only. An event dated in the future is booked, not
-- started, so it does not accrue days yet.
-- Guarded for the same reason as v_animal_current below: 035 appends
-- est_empty_on / est_days_left here, and `create or replace view`
-- cannot drop columns. Re-running 034 afterwards would otherwise
-- abort. If the later columns exist, 035 already owns this view.
do $guard$
begin
  if not exists (select 1 from information_schema.columns
                  where table_name = 'v_animal_feed'
                    and column_name = 'est_empty_on') then
    execute $v$
create or replace view v_animal_feed with (security_invoker = on) as
select
  c.animal_id,
  min(c.fed_on)                  as on_feed_since,
  (current_date - min(c.fed_on)) as days_on_feed,
  count(*)                       as open_runs,
  string_agg(distinct coalesce(fs.feedstuff, c.ration), ', ')
                                 as feedstuff
from v_feed_cover c
left join feed_source fs on fs.id = c.feed_source_id
where c.ended_on is null
  and c.fed_on <= current_date
group by c.animal_id;
$v$;
  end if;
end $guard$;

-- ------------------------------------------------------------
-- 3. Put it on the animal.
--
-- `create or replace view` can only APPEND columns, so the existing
-- list below is reproduced verbatim from 20260802000024_sire_code
-- and the three new columns go on the end. Do not reorder it.
-- ------------------------------------------------------------

-- Guarded: a LATER migration appends more columns to this view, and
-- `create or replace view` cannot drop columns. Without this check,
-- re-running 034 after 035 aborts with "cannot drop columns from
-- view" — which would break the rule that every migration here is
-- safe to run again. If the later columns are already present, this
-- migration's work is done and it steps aside.
do $guard$
begin
  if not exists (select 1 from information_schema.columns
                  where table_name = 'v_animal_current'
                    and column_name = 'est_empty_on') then
    execute $v$
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
  fd.feedstuff as on_feed_feedstuff

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
where a.origin <> 'reference';
$v$;
  end if;
end $guard$;

-- ------------------------------------------------------------
-- 4. Running out closes the run.
--
-- The date the load was declared empty is the date the animals came
-- off it. `greatest` guards the one nonsense case: a load marked
-- exhausted before an event that fed from it, which would otherwise
-- violate the ended_on >= fed_on check and abort the update.
-- ------------------------------------------------------------

create or replace function close_feed_runs_on_exhaustion()
returns trigger language plpgsql as $$
begin
  if new.exhausted_on is not null
     and (old.exhausted_on is null or old.exhausted_on <> new.exhausted_on) then
    update feed_event
       set ended_on = greatest(new.exhausted_on, fed_on)
     where feed_source_id = new.id
       and ended_on is null;
  end if;
  return null;
end $$;

drop trigger if exists feed_source_exhausted on feed_source;
create trigger feed_source_exhausted
  after update on feed_source
  for each row execute function close_feed_runs_on_exhaustion();

-- ------------------------------------------------------------
-- 5. Empty by the numbers closes it too.
--
-- Only fires when the intake quantity is actually known. A source
-- with a null quantity has no balance to reach zero, so it stays
-- open until someone presses "Mark as all used up" — silence is the
-- honest answer there, not a guessed exhaustion date.
--
-- No recursion: this sets exhausted_on, which fires the trigger
-- above, which writes ended_on back onto feed_event, which fires
-- this again — but by then exhausted_on is set, the guarded select
-- returns no row, and it stops.
-- ------------------------------------------------------------

-- The balance test itself, callable on its own. Three different tables
-- can move this balance — a feed-out, an adjustment, or someone finally
-- filling in how much was delivered — so the test lives in one place
-- and the triggers are thin wrappers that name the source.
create or replace function feed_source_close_if_empty(sid uuid)
returns void language plpgsql as $$
declare
  qty_in numeric;
  used   numeric;
  adj    numeric;
  asof   date;
begin
  if sid is null then return; end if;

  select quantity into qty_in
    from feed_source where id = sid and exhausted_on is null;
  if qty_in is null then return; end if;

  select coalesce(sum(qty), 0), max(fed_on) into used, asof
    from feed_event where feed_source_id = sid;
  select coalesce(sum(qty_delta), 0) into adj
    from feed_adjustment where feed_source_id = sid;

  if qty_in + adj - used <= 0 then
    update feed_source
       set exhausted_on = coalesce(asof, current_date)
     where id = sid and exhausted_on is null;
  end if;
end $$;

create or replace function feed_line_changed()
returns trigger language plpgsql as $$
begin
  perform feed_source_close_if_empty(
    coalesce(new.feed_source_id, old.feed_source_id));
  return null;
end $$;

-- The quantity is often typed in long after the feeding — the Irwins
-- silo was fed out for months before anyone recorded what came in.
-- Without this, filling that figure in leaves a load sitting at a
-- negative balance and still open.
create or replace function feed_source_quantity_changed()
returns trigger language plpgsql as $$
begin
  perform feed_source_close_if_empty(new.id);
  return null;
end $$;

drop trigger if exists feed_event_empties_source on feed_event;
create trigger feed_event_empties_source
  after insert or update or delete on feed_event
  for each row execute function feed_line_changed();

drop trigger if exists feed_adjustment_empties_source on feed_adjustment;
create trigger feed_adjustment_empties_source
  after insert or update or delete on feed_adjustment
  for each row execute function feed_line_changed();

drop trigger if exists feed_source_quantity_set on feed_source;
create trigger feed_source_quantity_set
  after update of quantity on feed_source
  for each row execute function feed_source_quantity_changed();

-- ------------------------------------------------------------
-- 6. Close anything already empty on the day this lands.
-- ------------------------------------------------------------

-- Guarded: 035 overturns the idea that an empty store ends a feeding
-- run — a self feeder keeps the mob fed for weeks after the silo is
-- bare. Left unguarded, re-running 034 after 035 would reach in and
-- close every run whose source had been marked exhausted, silently
-- zeroing days-on-feed for the whole mob. Once v_feed_load exists,
-- 035 is in charge and this backfill must not fire.
do $guard$
begin
  if not exists (select 1 from information_schema.views
                  where table_name = 'v_feed_load') then
    update feed_event fe
       set ended_on = greatest(fs.exhausted_on, fe.fed_on)
      from feed_source fs
     where fs.id = fe.feed_source_id
       and fs.exhausted_on is not null
       and fe.ended_on is null;
  end if;
end $guard$;

notify pgrst, 'reload schema';
