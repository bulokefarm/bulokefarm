-- ============================================================
-- Buloke Farm — the feeder running dry is not the silo running dry
-- Apply after 20260802000034_days_on_feed.sql.
-- Safe to run more than once.
--
-- 034 treated feed_source.exhausted_on as the end of the feeding
-- run and closed every open feed_event when it was set. That is
-- right for a ring feeder or hay rolled out — the load and the
-- feeding are the same act. It is wrong for a self feeder, which
-- is how silo 28 is actually run: tipping 4 tonne in empties the
-- silo that day, and the mob eats it down over the next ten weeks.
-- Under 034, recording the delivered tonnage would have zeroed the
-- balance, marked the source exhausted, closed the runs, and blanked
-- days-on-feed for the whole Cottage mob on the spot.
--
-- So the two are separated here:
--
--   feed_source.exhausted_on  the STORE is empty. Nothing more to
--                             feed out of it. Comes off the pick list.
--   feed_event.ended_on       the ANIMALS came off. Set by hand, on
--                             the day the feeder was seen empty.
--
-- Nothing infers the second from the first any more. The estimate
-- below says when it is likely, and the yard says when it is true.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Stop exhaustion from closing runs.
--
-- The trigger stays — dropping it would leave 034-applied databases
-- carrying it — but the body no longer touches feed_event.
-- ------------------------------------------------------------

create or replace function close_feed_runs_on_exhaustion()
returns trigger language plpgsql as $$
begin
  -- Deliberately does nothing. An empty store does not take the
  -- cattle off feed; only feed_run_end() does that. Kept as a no-op
  -- so databases that already ran 034 lose the behaviour on upgrade
  -- rather than keeping a stale definition.
  return null;
end $$;

-- ------------------------------------------------------------
-- 2. How fast it goes out.
--
-- A rate per head per day, editable per load, because a self feeder
-- on grain and a hay ring are nothing alike. Seeded by feed type so
-- there is a working estimate from the first day; override it on the
-- load once you have watched one go down.
-- ------------------------------------------------------------

alter table feed_source
  add column if not exists intake_kg_head_day numeric(6,2);

comment on column feed_source.intake_kg_head_day is
  'Estimated intake per head per day. Drives the projected empty date only — never a stock figure.';

update feed_source
   set intake_kg_head_day = case feed_type
         when 'grain'  then 9.0     -- ad-lib grain, self feeder
         when 'fodder' then 12.0    -- hay, roughly 2.5% of body weight
         else null end
 where intake_kg_head_day is null;

-- ------------------------------------------------------------
-- 3. What a load weighs, in kilograms.
--
-- Amounts are written in whatever unit suits the load — tonnes for
-- grain, bales for hay. Only mass converts, so a load counted in
-- bales gets no estimate rather than a fabricated one.
-- ------------------------------------------------------------

create or replace function feed_qty_kg(qty numeric, unit text)
returns numeric language sql immutable as $$
  select case lower(coalesce(unit, ''))
           when 'kg'     then qty
           when 'kgs'    then qty
           when 't'      then qty * 1000
           when 'tonne'  then qty * 1000
           when 'tonnes' then qty * 1000
           when 'ton'    then qty * 1000
           else null
         end
$$;

-- ------------------------------------------------------------
-- 4. Per load: how long it should last, and when it should be gone.
-- ------------------------------------------------------------

-- Guarded like the views in 034: 036 appends head_unmapped here, and
-- `create or replace view` cannot drop columns. Without the check,
-- re-running 035 after 036 aborts. If the later column is present,
-- 036 owns this view and 035 steps aside.
do $guard$
begin
  if not exists (select 1 from information_schema.columns
                  where table_name = 'v_feed_load'
                    and column_name = 'head_unmapped') then
    execute $v$
create or replace view v_feed_load with (security_invoker = on) as
select
  fe.id                                as feed_event_id,
  fe.feed_source_id,
  fe.fed_on,
  fe.ended_on,
  fs.feedstuff,
  fs.unit,
  fe.qty,
  feed_qty_kg(fe.qty, fs.unit)         as qty_kg,
  fs.intake_kg_head_day                as rate,
  hd.head,
  case when feed_qty_kg(fe.qty, fs.unit) is not null
        and fs.intake_kg_head_day > 0
        and hd.head > 0
       then round(feed_qty_kg(fe.qty, fs.unit)
                  / (hd.head * fs.intake_kg_head_day))
  end                                  as est_days,
  case when feed_qty_kg(fe.qty, fs.unit) is not null
        and fs.intake_kg_head_day > 0
        and hd.head > 0
       then fe.fed_on + (round(feed_qty_kg(fe.qty, fs.unit)
                  / (hd.head * fs.intake_kg_head_day)))::int
  end                                  as est_empty_on,
  (current_date - fe.fed_on)           as days_out
from feed_event fe
join feed_source fs on fs.id = fe.feed_source_id
left join lateral (
  -- Who is actually eating it, by either shape.
  select count(distinct c.animal_id) as head
    from v_feed_cover c where c.feed_event_id = fe.id
) hd on true;
$v$;
  end if;
end $guard$;

-- ------------------------------------------------------------
-- 5. Roll the estimate up to the animal.
--
-- The load an animal is currently on is the most recent open one
-- covering it — a top-up supersedes what was in the feeder before.
-- ------------------------------------------------------------

create or replace view v_animal_feed with (security_invoker = on) as
with runs as (
  select c.animal_id, c.fed_on, c.feed_event_id,
         coalesce(fs.feedstuff, c.ration) as feedstuff
    from v_feed_cover c
    left join feed_source fs on fs.id = c.feed_source_id
   where c.ended_on is null
     and c.fed_on <= current_date
), latest as (
  select distinct on (animal_id) animal_id, feed_event_id
    from runs order by animal_id, fed_on desc
)
select
  r.animal_id,
  min(r.fed_on)                        as on_feed_since,
  (current_date - min(r.fed_on))       as days_on_feed,
  count(*)                             as open_runs,
  string_agg(distinct r.feedstuff, ', ') as feedstuff,
  max(l.est_empty_on)                  as est_empty_on,
  max(l.est_empty_on) - current_date   as est_days_left
from runs r
join latest lt on lt.animal_id = r.animal_id
left join v_feed_load l on l.feed_event_id = lt.feed_event_id
group by r.animal_id;

-- v_animal_current already reads on_feed_since / days_on_feed /
-- feedstuff from this view. `create or replace` can only APPEND, so
-- the list from 034 is reproduced verbatim with the two new columns
-- on the end. Do not reorder it.
-- Guarded like 034's copy: 038 appends the last-finished-run columns
-- here, and `create or replace view` cannot drop columns. If they are
-- already present, 038 owns this view and 035 steps aside.
do $guard$
begin
  if not exists (select 1 from information_schema.columns
                  where table_name = 'v_animal_current'
                    and column_name = 'off_feed_on') then
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
  fd.feedstuff as on_feed_feedstuff,

  fd.est_empty_on,
  fd.est_days_left

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
-- 6. Ending a run, by hand, on a date you choose.
-- ------------------------------------------------------------

create or replace function feed_run_end(p_source uuid, p_on date default current_date)
returns integer language plpgsql security invoker as $$
declare n integer;
begin
  update feed_event
     set ended_on = greatest(p_on, fed_on)
   where feed_source_id = p_source
     and ended_on is null;
  get diagnostics n = row_count;
  return n;
end $$;

comment on function feed_run_end(uuid, date) is
  'Takes the mob off a feed run on the given day. Called when the feeder is seen empty — never inferred.';

notify pgrst, 'reload schema';
