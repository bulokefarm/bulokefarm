-- ============================================================
-- Buloke Farm — a bale rolled out is not a feeding run
-- Apply after 20260802000036_irwins_feed_repair.sql.
-- Safe to run more than once.
--
-- 034 treated every feed_event with no ended_on as an open run, so
-- days-on-feed counted from the first one. That is right for the
-- self feeder — the grain sits there and the mob eats it for weeks.
-- It is wrong for hay: rolling out a bale on 2 August feeds them
-- that day, and the app has no field for an end date, so the row
-- stays open forever. On the live data that put every cow in Top
-- and Bottom Paddock on feed since 31 July, climbing daily and
-- never stopping. Eighty head wearing a finishing-ration badge
-- because they got a bale.
--
-- So the two are separated. A RUN is continuous feeding the animals
-- stay on. A DROP is a single feed-out on the day. Both are Section
-- 3C records and both count toward the store balance; only a run
-- accrues days on feed.
--
-- Backfilled from the method already recorded rather than guessed:
-- 'Self feeder' is a run, everything else is a drop. Anything with
-- an ended_on already set was someone describing a period, so that
-- counts as a run too.
-- ============================================================

alter table feed_event
  add column if not exists is_run boolean not null default false;

comment on column feed_event.is_run is
  'True when the animals stay on this feed (self feeder, ad lib). False for a single feed-out. Only a run accrues days on feed.';

update feed_event
   set is_run = true
 where is_run = false
   and (method ilike '%self feeder%'
        or method ilike '%ad lib%'
        or ended_on is not null);

-- ------------------------------------------------------------
-- Days on feed counts runs only.
--
-- v_feed_cover is left alone — v_feed_load still needs every event
-- to work out head counts for the estimate — so the filter is a
-- join here rather than a column there. That also keeps 034's
-- definition of v_feed_cover replaceable, instead of adding another
-- append-only view to the chain.
-- ------------------------------------------------------------

create or replace view v_animal_feed with (security_invoker = on) as
with runs as (
  select c.animal_id, c.fed_on, c.feed_event_id,
         coalesce(fs.feedstuff, c.ration) as feedstuff
    from v_feed_cover c
    join feed_event fe on fe.id = c.feed_event_id and fe.is_run
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

notify pgrst, 'reload schema';
