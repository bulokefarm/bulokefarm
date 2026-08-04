-- ============================================================
-- Buloke Farm — the expectation is recomputed, not deleted
-- Apply after 20260802000027_due_needs_joined.sql.
--
-- 026 was wrong twice.
--
-- It deleted the losing row and never wrote the winning one, because
-- the trigger only fires on a write to joining and nothing was
-- written. So the autumn calvings disappeared entirely rather than
-- being replaced.
--
-- And "latest attempt wins" is the wrong rule. U 18's first service
-- tested in calf; the second is a later, untested one. A confirmed
-- pregnancy is what she is due to, whatever was recorded after it.
--
-- Replaced with a single function that works out the expectation for
-- a dam and season from scratch. The trigger calls it, and so does the
-- rebuild at the bottom, so there is one rule in one place.
-- ============================================================

create or replace function refresh_expectation(p_dam uuid, p_season text)
returns void language plpgsql security definer set search_path = public as $$
declare best joining%rowtype;
begin
  -- She calved: that season is finished, and a later joining record
  -- does not reopen it.
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
     and j.outcome not in ('empty','aborted','lost','calved')
   order by (j.outcome = 'in_calf') desc,      -- tested beats untested
            j.attempt desc,                    -- then the later service
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
-- The trigger now just says "this dam, this season, work it out" —
-- and handles a joining being moved to a different season.
-- ------------------------------------------------------------

create or replace function sync_expected_calving()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' and (old.dam_id, old.season) is distinct from (new.dam_id, new.season) then
    perform refresh_expectation(old.dam_id, old.season);
  end if;
  perform refresh_expectation(new.dam_id, new.season);
  return new;
end $$;

drop trigger if exists joining_expects on joining;
create trigger joining_expects
  after insert or update of due_on, outcome, dam_id, sire_id, season, cycle, attempt, joined_on
  on joining for each row execute function sync_expected_calving();

-- A joining being deleted should take its expectation with it.
create or replace function sync_expected_calving_del()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  perform refresh_expectation(old.dam_id, old.season);
  return old;
end $$;

drop trigger if exists joining_expects_del on joining;
create trigger joining_expects_del
  after delete on joining for each row execute function sync_expected_calving_del();

-- ------------------------------------------------------------
-- Rebuild everything through the one rule.
-- ------------------------------------------------------------

do $$
declare r record;
begin
  for r in select distinct dam_id, season from joining loop
    perform refresh_expectation(r.dam_id, r.season);
  end loop;
end $$;

notify pgrst, 'reload schema';
