-- ============================================================
-- Buloke Farm — the Due list actually follows the joinings
-- Apply after 20260802000024_sire_code.sql.
--
-- Nothing has ever written to expected_calving. The ten rows on the
-- Due screen are the ones the original seed inserted by hand, and
-- every joining recorded through the app since — cattle included —
-- has gone into joining and never appeared. The sheep only made it
-- obvious because they arrived as 31 at once.
--
-- Nothing has ever set resolved_calving_id either, so a cow that
-- calved would have stayed on the list indefinitely.
--
-- Two triggers. The expected calving is derived from the joining and
-- kept in step with it, rather than being a second thing to remember
-- to type.
-- ============================================================

-- ------------------------------------------------------------
-- One expected calving per joining. The seed rows predate this and
-- have no joining_id, so they are matched up first — otherwise the
-- backfill below would sit a second row beside each of them.
-- ------------------------------------------------------------

update expected_calving e
   set joining_id = j.id
  from joining j
 where e.joining_id is null
   and j.dam_id = e.dam_id
   and j.season  = e.season
   and j.due_on is not distinct from e.due_on;

-- Anything still unlinked but duplicating a joining is the seed's
-- version of a row the trigger is about to own.
delete from expected_calving e
 where e.joining_id is null
   and exists (select 1 from joining j
                where j.dam_id = e.dam_id and j.season = e.season);

-- Plain, not partial. ON CONFLICT can only infer from a partial index
-- if the statement restates its predicate, and the predicate buys
-- nothing here: Postgres already treats nulls as distinct, so any seed
-- rows left without a joining are unconstrained either way.
create unique index if not exists expected_calving_joining_uq
  on expected_calving (joining_id);

-- ------------------------------------------------------------
-- A joining that is expected to produce something puts a row on the
-- Due list. One that is known not to takes it off again — recording
-- an empty should clear her, not leave her showing as due.
-- ------------------------------------------------------------

create or replace function sync_expected_calving()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.due_on is null
     or new.outcome in ('empty','aborted','lost','calved') then
    delete from expected_calving where joining_id = new.id;
    return new;
  end if;

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

drop trigger if exists joining_expects on joining;
create trigger joining_expects
  after insert or update of due_on, outcome, dam_id, sire_id, season, cycle
  on joining for each row execute function sync_expected_calving();

-- ------------------------------------------------------------
-- A calf on the ground closes it off. Matched by joining where the
-- calving names one, otherwise by the dam's nearest open expectation
-- — which is the one a person would have meant.
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
       or (new.joining_id is null and e.dam_id = new.dam_id)
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
-- Catch up on everything already recorded.
-- ------------------------------------------------------------

insert into expected_calving (joining_id, dam_id, sire_id, season, cycle, due_on)
select j.id, j.dam_id, j.sire_id, j.season, j.cycle, j.due_on
  from joining j
 where j.due_on is not null
   and j.outcome not in ('empty','aborted','lost','calved')
on conflict (joining_id) do nothing;

-- And close off any that already calved.
update expected_calving e
   set resolved_calving_id = c.id
  from calving c
 where e.resolved_calving_id is null
   and (c.joining_id = e.joining_id
        or (c.joining_id is null and c.dam_id = e.dam_id));

notify pgrst, 'reload schema';
