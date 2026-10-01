-- ============================================================
-- 64. A season is the financial year the calf or lamb is due in.
--
-- Seasons run July to June, named for the financial year: a calving
-- due 21 Sept 2027 is 2027-2028, a lambing due 28 Aug 2026 is
-- 2026-2027. Until now the season was typed, defaulting to this
-- calendar year, and it drifted: the April ewe joining went in as
-- 2025-2026 for an August 2026 lambing, and a back-up plan went in a
-- season apart from the plan it backed up, where the joining that
-- answers it would never have found it.
--
-- So it is worked out, not typed. A joining with a due date takes
-- the season of that date; a plan with a planned date takes the
-- season of its forecast (planned date plus the plan's gestation,
-- else the dam's, else 285 or 145). Move the date or the gestation
-- and the season follows — including a correction to the dam's own
-- gestation, which moves the forecast of every open plan for her.
-- Without a date the season is still what was entered: the who can
-- be decided before the when.
--
-- A joining's expectation already follows its season (sync on update
-- of season), so the ewes' Due entries move with them.
--
-- Safe to run more than once.
-- ============================================================

create or replace function season_of(d date)
returns text language sql immutable set search_path = public as $$
  select case when d is null then null
              when extract(month from d) >= 7
                then extract(year from d)::int || '-' || (extract(year from d)::int + 1)
              else (extract(year from d)::int - 1) || '-' || extract(year from d)::int end
$$;

comment on function season_of(date) is
  'The season a birth on this date falls in: the July–June financial year, as 2027-2028.';

-- ------------------------------------------------------------
-- 1. Joinings: the season of the due date.
-- ------------------------------------------------------------

create or replace function joining_season()
returns trigger language plpgsql set search_path = public as $$
begin
  if new.due_on is not null then
    new.season := season_of(new.due_on);
  end if;
  return new;
end $$;

revoke execute on function joining_season() from public, anon, authenticated;

drop trigger if exists joining_season on joining;
create trigger joining_season
  before insert or update of due_on, season on joining
  for each row execute function joining_season();

-- ------------------------------------------------------------
-- 2. Plans: the season of the forecast.
-- ------------------------------------------------------------

create or replace function planned_joining_season()
returns trigger language plpgsql set search_path = public as $$
declare g int;
begin
  if new.planned_on is not null then
    select coalesce(new.gestation_days, d.gestation_days,
                    case when d.species = 'sheep' then 145 else 285 end)
      into g from animal d where d.id = new.dam_id;
    new.season := season_of(new.planned_on + coalesce(g, 285));
  end if;
  return new;
end $$;

revoke execute on function planned_joining_season() from public, anon, authenticated;

drop trigger if exists planned_joining_season on planned_joining;
create trigger planned_joining_season
  before insert or update of planned_on, gestation_days, dam_id, season on planned_joining
  for each row execute function planned_joining_season();

-- Her gestation corrected: her open plans' forecasts move, so their
-- season is worked out again.
create or replace function dam_gestation_moves_plans()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.gestation_days is distinct from old.gestation_days then
    update planned_joining set planned_on = planned_on
     where dam_id = new.id and planned_on is not null
       and joining_id is null and cancelled_on is null;
  end if;
  return new;
end $$;

revoke execute on function dam_gestation_moves_plans() from public, anon, authenticated;

drop trigger if exists animal_gestation_moves_plans on animal;
create trigger animal_gestation_moves_plans
  after update of gestation_days on animal
  for each row execute function dam_gestation_moves_plans();

-- ------------------------------------------------------------
-- 3. What is on file now. The triggers do the work; these only touch
--    rows whose season is not already the right one. The change log
--    keeps the season each had.
-- ------------------------------------------------------------

update joining set due_on = due_on
 where due_on is not null and season is distinct from season_of(due_on);

update planned_joining set planned_on = planned_on
 where id in (select id from v_planned_joining
               where status = 'open' and forecast_on is not null
                 and season is distinct from season_of(forecast_on));

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select count(*) from joining
--    where due_on is not null and season <> season_of(due_on);      -- 0
--   select count(*) from v_planned_joining
--    where forecast_on is not null and season <> season_of(forecast_on); -- 0
--   select season, count(*) from expected_calving
--    where resolved_calving_id is null group by 1;   -- the ewes under 2026-2027
-- ------------------------------------------------------------
