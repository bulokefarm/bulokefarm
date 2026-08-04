-- ============================================================
-- Buloke Farm — a calving only resolves the calving it belongs to
-- Apply after 20260802000028_refresh_expectation.sql.
--
-- The catch-up step in 025 closed off an expectation whenever the dam
-- had any calving on record, with no date test. Every breeder has
-- calved before, so a calf born in 2022 marked a 2027 expectation as
-- already delivered. The rows were there the whole time; the Due
-- screen filters on resolved_calving_id, so they were invisible, and
-- refresh_expectation then treated the season as finished and left
-- them alone.
--
-- A calving belongs to an expectation if it names the same joining,
-- or if it happened near the due date. Sixty days either side is
-- generous — the point is to exclude a calving from a different year,
-- not to police a fortnight.
-- ============================================================

-- ------------------------------------------------------------
-- 0. The unique index has to come off first.
--
-- Un-resolving is what creates the duplicates: two rows that were both
-- hiding behind resolved_calving_id become two open rows for the same
-- dam and season at the moment they are freed. The constraint is
-- correct — it just cannot hold while the data is mid-repair. It goes
-- back on at the end, which is also the proof the repair worked.
-- ------------------------------------------------------------

drop index if exists expected_calving_open_uq;

-- ------------------------------------------------------------
-- 1. Undo the resolutions that can't be right.
-- ------------------------------------------------------------

update expected_calving e
   set resolved_calving_id = null
  from calving c
 where e.resolved_calving_id = c.id
   and c.joining_id is distinct from e.joining_id
   and (e.due_on is null or abs(c.calved_on - e.due_on) > 60);

-- ------------------------------------------------------------
-- 2. Same rule in the trigger, so it can't happen again.
-- ------------------------------------------------------------

create or replace function resolve_expected_calving()
returns trigger language plpgsql security definer set search_path = public as $$
declare target uuid;
begin
  select e.id into target
    from expected_calving e
   where e.resolved_calving_id is null
     and (
       (new.joining_id is not null and e.joining_id = new.joining_id)
       or (new.joining_id is null
           and e.dam_id = new.dam_id
           and e.due_on is not null
           and abs(new.calved_on - e.due_on) <= 60)
     )
   order by abs(coalesce(e.due_on, new.calved_on) - new.calved_on)
   limit 1;

  if target is not null then
    update expected_calving set resolved_calving_id = new.id where id = target;
  end if;
  return new;
end $$;

drop trigger if exists calving_resolves on calving;
create trigger calving_resolves
  after insert on calving for each row execute function resolve_expected_calving();

-- ------------------------------------------------------------
-- 3. Clear out the duplicates the wrongly-resolved rows were hiding.
--    The unique index only constrains open rows, so while these were
--    all marked resolved a dam could hold several.
-- ------------------------------------------------------------

delete from expected_calving e
 where e.resolved_calving_id is null
   and e.joining_id is null;

-- ------------------------------------------------------------
-- 4. Recompute every dam and season through the one rule. This is
--    what collapses the duplicates: refresh_expectation keeps the one
--    best joining and drops every other open row for that pair.
-- ------------------------------------------------------------

do $$
declare r record;
begin
  for r in select distinct dam_id, season from joining loop
    perform refresh_expectation(r.dam_id, r.season);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 5. Back on. If this fails, the repair above did not finish and the
--    error names the dam still holding two.
-- ------------------------------------------------------------

create unique index expected_calving_open_uq
  on expected_calving (dam_id, season) where resolved_calving_id is null;

notify pgrst, 'reload schema';
