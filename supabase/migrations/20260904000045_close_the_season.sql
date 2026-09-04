-- 45. Lambing is over: the mob comes off Due as a group.
--
-- A mob joining writes one joining per ewe, and one expectation per
-- ewe follows. Lambs are recorded by paddock (44), so no ewe's
-- expectation is ever resolved, and the whole mob sits on Due as
-- overdue until each row is dealt with by hand.
--
-- What is known when lambing finishes is only that the season is over
-- for that mob. Calling every ewe 'calved' claims each one lambed;
-- 'empty' claims she didn't. Neither is the record. So a joining gains
-- an outcome that says exactly that — closed: season over, result not
-- recorded per dam — and close_expectations() sets it on every joining
-- behind the chosen expectations. refresh_expectation() then does what
-- it already does when no live joining remains: the expectation goes.
-- The note lands on the joining, and the joining's change log keeps
-- the before and after.
--
-- Nothing in this file uses the new enum value as an enum. A value
-- added in a transaction cannot be used in that transaction, and the
-- SQL editor runs a paste as one. The function bodies only name it in
-- plpgsql, which is not checked until they run, and the views compare
-- outcome as text — 'closed' as an enum literal in a view definition
-- is exactly the unsafe use Postgres refuses.
--
-- Re-runnable: add value if not exists, create or replace throughout.

alter type joining_outcome_t add value if not exists 'closed';

-- ------------------------------------------------------------
-- 1. A closed joining is finished. refresh_expectation must not pick
--    it as the best live joining and put the expectation straight
--    back. Otherwise identical to 28.
-- ------------------------------------------------------------

create or replace function refresh_expectation(p_dam uuid, p_season text)
returns void language plpgsql security definer set search_path = public as $$
declare best joining%rowtype;
begin
  if exists (select 1 from expected_calving
              where dam_id = p_dam and season = p_season
                and resolved_calving_id is not null) then
    delete from expected_calving
     where dam_id = p_dam and season = p_season and resolved_calving_id is null;
    return;
  end if;

  select j.* into best
    from joining j
   where j.dam_id = p_dam and j.season = p_season
     and j.due_on is not null
     and j.outcome not in ('empty','aborted','lost','calved','closed')
   order by (j.outcome = 'in_calf') desc,
            j.attempt desc,
            j.joined_on desc nulls last
   limit 1;

  delete from expected_calving
   where dam_id = p_dam and season = p_season and resolved_calving_id is null
     and (best.id is null or joining_id is distinct from best.id);

  if best.id is not null then
    insert into expected_calving (joining_id, dam_id, sire_id, season, cycle, due_on)
    values (best.id, best.dam_id, best.sire_id, best.season, best.cycle, best.due_on)
    on conflict (joining_id) do update
       set dam_id  = excluded.dam_id,
           sire_id = excluded.sire_id,
           season  = excluded.season,
           cycle   = excluded.cycle,
           due_on  = excluded.due_on;
  end if;
end $$;

-- ------------------------------------------------------------
-- 2. Closing.
--
-- Takes expectation ids, because that is what the Due screen has in
-- hand. An expectation with no joining behind it (the standalone rows
-- 30 restored, from preg tests rather than services) has nothing to
-- carry the outcome, so those are refused by name rather than
-- deleted: a due date nobody wrote down elsewhere should not vanish
-- on a button.
-- ------------------------------------------------------------

create or replace function close_expectations(
    p_ids  uuid[],
    p_on   date default farm_today(),
    p_note text default null)
returns int language plpgsql security invoker set search_path = public as $$
declare
  n       int;
  orphans text;
  stamp   text;
begin
  if p_ids is null or array_length(p_ids, 1) is null then
    raise exception 'Nothing chosen to close';
  end if;

  select string_agg(coalesce(a.stock_code, a.name, 'an unnamed dam'), ', ' order by a.stock_code)
    into orphans
    from expected_calving e
    join animal a on a.id = e.dam_id
   where e.id = any(p_ids)
     and e.resolved_calving_id is null
     and e.joining_id is null;
  if orphans is not null then
    raise exception 'No joining on file behind the expectation for %. Record the joining, or the calving, and close again.', orphans;
  end if;

  stamp := 'Closed ' || to_char(coalesce(p_on, farm_today()), 'DD Mon YYYY')
        || ': ' || coalesce(nullif(trim(p_note), ''), 'season over, result not recorded per dam');

  update joining j
     set outcome = 'closed',
         notes   = concat_ws(E'\n', nullif(trim(j.notes), ''), stamp)
    from expected_calving e
   where e.id = any(p_ids)
     and e.resolved_calving_id is null
     and e.joining_id = j.id
     and j.outcome not in ('empty','aborted','lost','calved','closed');

  get diagnostics n = row_count;
  return n;
end $$;

comment on function close_expectations(uuid[], date, text) is
  'Season over for these expectations: the joining behind each is marked closed (result not recorded per dam), with the note, and the expectation comes off Due. Returns how many joinings were closed.';

-- ------------------------------------------------------------
-- 3. A closed joining is neither held nor failed. It comes out of the
--    conception-rate denominator with the untested ones, so a mob
--    whose result is recorded by paddock does not read as 0% held.
-- ------------------------------------------------------------

create or replace view v_joining_performance with (security_invoker = on) as
select
  coalesce(s.name, 'Sire not recorded')          as sire,
  j.season,
  count(*)                                       as joinings,
  count(*) filter (where j.outcome in ('in_calf','calved'))  as held,
  count(*) filter (where j.outcome = 'empty')                as empty,
  count(*) filter (where j.outcome in ('aborted','lost'))    as lost,
  count(*) filter (where j.outcome::text in ('unknown','closed'))  as untested,
  case when count(*) filter (where j.outcome::text not in ('unknown','closed')) > 0
       then round(100.0 * count(*) filter (where j.outcome in ('in_calf','calved'))
                  / count(*) filter (where j.outcome::text not in ('unknown','closed')))
  end as pct_held
from joining j
left join animal s on s.id = j.sire_id
group by coalesce(s.name, 'Sire not recorded'), j.season;

create or replace view v_dam_fertility with (security_invoker = on) as
select
  d.id as dam_id, d.stock_code, d.name,
  count(j.id)                                                as joinings,
  count(*) filter (where j.outcome in ('in_calf','calved'))   as held,
  count(*) filter (where j.outcome = 'empty')                 as empty,
  max(j.season) filter (where j.outcome = 'empty')            as last_empty,
  case when count(*) filter (where j.outcome::text not in ('unknown','closed')) > 0
       then round(100.0 * count(*) filter (where j.outcome in ('in_calf','calved'))
                  / count(*) filter (where j.outcome::text not in ('unknown','closed')))
  end as pct_held
from animal d
join joining j on j.dam_id = d.id
group by d.id, d.stock_code, d.name;

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select id, dam_id, season from expected_calving where resolved_calving_id is null;
--   select close_expectations(array['<id>', '<id>']::uuid[], farm_today(), '38 lambs by paddock');
--   select outcome, notes from joining where outcome = 'closed';
--   select * from v_joining_performance;   -- closed sits in untested
-- ------------------------------------------------------------
