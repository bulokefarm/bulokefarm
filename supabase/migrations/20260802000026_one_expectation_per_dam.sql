-- ============================================================
-- Buloke Farm — one expectation per dam per season
-- Apply after 20260802000025_expected_calving_sync.sql.
--
-- 025 put a row on the Due list for every open joining. A dam who was
-- joined twice in a season has two open joinings — a first service and
-- a re-join — so she appeared twice, with two different due dates.
--
-- She can only be carrying one. A second attempt supersedes the first:
-- the earlier joining stays on the record as what was tried, but it is
-- no longer what is expected.
-- ============================================================

-- ------------------------------------------------------------
-- Clear the duplicates 025 created. Keep the latest attempt, and
-- the later joining where the attempt numbers tie.
-- ------------------------------------------------------------

delete from expected_calving e
 where e.resolved_calving_id is null
   and e.joining_id is not null
   and exists (
     select 1
       from joining mine
       join joining better
         on better.dam_id = mine.dam_id
        and better.season = mine.season
        and better.id <> mine.id
        and better.due_on is not null
        and better.outcome not in ('empty','aborted','lost','calved')
        and (better.attempt, coalesce(better.joined_on, '1900-01-01'::date))
          > (mine.attempt,   coalesce(mine.joined_on,   '1900-01-01'::date))
      where mine.id = e.joining_id);

-- Now it can be enforced rather than merely intended.
create unique index if not exists expected_calving_open_uq
  on expected_calving (dam_id, season) where resolved_calving_id is null;

-- ------------------------------------------------------------
-- The trigger takes the same view: writing an expectation clears any
-- other open one for that dam and season.
-- ------------------------------------------------------------

create or replace function sync_expected_calving()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.due_on is null
     or new.outcome in ('empty','aborted','lost','calved') then
    delete from expected_calving where joining_id = new.id;
    return new;
  end if;

  -- A re-join replaces the expectation from the earlier service. The
  -- earlier joining is left alone; it is still a record of what was
  -- tried, it just is not what she is due to.
  delete from expected_calving e
   where e.dam_id = new.dam_id
     and e.season = new.season
     and e.resolved_calving_id is null
     and e.joining_id is distinct from new.id;

  insert into expected_calving (joining_id, dam_id, sire_id, season, cycle, due_on)
  values (new.id, new.dam_id, new.sire_id, new.season, new.cycle, new.due_on)
  on conflict (joining_id) do update
     set dam_id  = excluded.dam_id,
         sire_id = excluded.sire_id,
         season  = excluded.season,
         cycle   = excluded.cycle,
         due_on  = excluded.due_on;
  return new;
end $$;

notify pgrst, 'reload schema';
