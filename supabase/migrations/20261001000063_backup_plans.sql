-- ============================================================
-- 63. Back-up plans: a dam can carry more than one plan a season.
--
-- The way joining is actually planned here is in order: a first AI,
-- a back-up AI in case she returns, and usually a bull after that.
-- 49 kept one open plan per dam per season, so the back-ups had
-- nowhere to go.
--
-- A plan now carries an attempt, the same 1st / 2nd / 3rd join the
-- joining already has. One open plan per dam, season and attempt; as
-- many attempts as are wanted.
--
-- The joining still closes the plan, but now the one it answers: the
-- plan with the same attempt, else the earliest still open. A plan for
-- an earlier attempt that is still open when a later joining goes in
-- has been passed over, so it is dropped as of that date.
--
-- And a back-up is only needed if she did not hold. When a joining is
-- marked in calf (or calved), any later-attempt plan still open for
-- her that season is dropped as of the test. Nothing is deleted: the
-- change log keeps each one, and a dropped plan can be planned again.
--
-- Safe to run more than once.
-- ============================================================

alter table planned_joining
  add column if not exists attempt smallint not null default 1;

do $$
begin
  alter table planned_joining add constraint planned_joining_attempt_ck
    check (attempt between 1 and 9);
exception when duplicate_object then null;
end $$;

comment on column planned_joining.attempt is
  'Which join this is the plan for: 1 the first choice, 2 the back-up, 3 usually the bull. Same numbering as joining.attempt.';

create unique index if not exists planned_joining_open_attempt_uq
  on planned_joining (dam_id, season, attempt)
  where joining_id is null and cancelled_on is null;

-- ------------------------------------------------------------
-- 1. The view gains the attempt. Appended, so create or replace
--    keeps every column where it was.
-- ------------------------------------------------------------

create or replace view v_planned_joining with (security_invoker = on) as
select
  pj.id, pj.dam_id, d.stock_code as dam_code, d.name as dam_name, d.species,
  pj.method,
  pj.sire_id, coalesce(s.name, s.stock_code, sem.sire_name) as sire_name,
  pj.ai_semen_id, sem.straw_code, sem.tank,
  pj.paddock_id, p.name as paddock_name,
  pj.season, pj.cycle, pj.planned_on,
  pj.gestation_days as nominated_days,
  coalesce(pj.gestation_days, d.gestation_days,
           case when d.species = 'sheep' then 145 else 285 end)::int as gestation_used,
  pj.planned_on + coalesce(pj.gestation_days, d.gestation_days,
           case when d.species = 'sheep' then 145 else 285 end)::int as forecast_on,
  pj.notes, pj.joining_id, pj.cancelled_on,
  case when pj.cancelled_on is not null then 'cancelled'
       when pj.joining_id  is not null then 'joined'
       else 'open' end as status,
  pj.created_at, pj.created_by,
  pj.attempt
from planned_joining pj
join animal d on d.id = pj.dam_id
left join animal   s   on s.id   = pj.sire_id
left join ai_semen sem on sem.id = pj.ai_semen_id
left join paddock  p   on p.id   = pj.paddock_id;

-- ------------------------------------------------------------
-- 2. The joining closes the plan it answers, not every plan she has.
-- ------------------------------------------------------------

create or replace function plan_fulfilled()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  answered uuid;
begin
  select id into answered
    from planned_joining
   where dam_id = new.dam_id
     and season = new.season
     and joining_id is null
     and cancelled_on is null
   order by (attempt = new.attempt) desc, attempt
   limit 1;

  if answered is null then return new; end if;

  update planned_joining set joining_id = new.id where id = answered;

  -- Anything for an earlier join still open has been passed over.
  update planned_joining
     set cancelled_on = coalesce(new.joined_on, farm_today())
   where dam_id = new.dam_id
     and season = new.season
     and attempt < new.attempt
     and joining_id is null
     and cancelled_on is null;
  return new;
end $$;

revoke execute on function plan_fulfilled() from public, anon, authenticated;

-- ------------------------------------------------------------
-- 3. She held: the back-ups are not needed.
-- ------------------------------------------------------------

create or replace function plan_backups_not_needed()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.outcome in ('in_calf', 'calved')
     and old.outcome is distinct from new.outcome then
    update planned_joining
       set cancelled_on = coalesce(new.tested_on, farm_today())
     where dam_id = new.dam_id
       and season = new.season
       and attempt > new.attempt
       and joining_id is null
       and cancelled_on is null;
  end if;
  return new;
end $$;

revoke execute on function plan_backups_not_needed() from public, anon, authenticated;

drop trigger if exists joining_held_drops_backups on joining;
create trigger joining_held_drops_backups
  after update of outcome on joining
  for each row execute function plan_backups_not_needed();

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select dam_code, season, attempt, method, sire_name, planned_on, status
--     from v_planned_joining order by dam_code, season, attempt;
--   -- every existing plan reads attempt 1
--   -- plan attempts 1, 2 and 3 for one cow, record the AI as attempt 1:
--   --   attempt 1 joined, 2 and 3 still open
--   -- mark that joining in calf: 2 and 3 cancelled
-- ------------------------------------------------------------
