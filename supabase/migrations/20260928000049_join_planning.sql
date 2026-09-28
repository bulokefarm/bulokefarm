-- ============================================================
-- 49. Join planning: who goes to which bull or straw, and when.
--
-- A plan is not a joining. A joining says a straw went in or a bull
-- went out, and everything downstream treats it as evidence: the Due
-- list, the conception-rate views, the straw count, which joining a
-- calving answers. Putting a plan on that table would mean either a
-- new outcome that every one of those readers has to know to skip, or
-- a plan that reads as a mating that happened. So it gets a table of
-- its own, the same shape as a joining minus the things only a real
-- joining has — attempt, bull-out date, confidence, outcome.
--
-- The forecast is not stored. It is planned_on plus a gestation, and
-- the gestation is the plan's own nominated figure, else the dam's,
-- else the species default — worked out in v_planned_joining on read,
-- so correcting a cow's gestation moves every open forecast for her.
-- A nominated figure on a plan does not rewrite the cow: the joining
-- form does that because a joining is her being measured, and a plan
-- is not.
--
-- A plan is done when the joining happens. A trigger on joining marks
-- any open plan for that dam and season with the joining's id, so the
-- joining is recorded exactly as it always was and the plan closes
-- itself. Dropping a plan sets cancelled_on; nothing is deleted.
--
-- Safe to run more than once.
-- ============================================================

create table if not exists planned_joining (
  id             uuid primary key default gen_random_uuid(),
  dam_id         uuid not null references animal(id) on delete cascade,
  method         joining_method_t not null default 'natural',
  sire_id        uuid references animal(id),
  ai_semen_id    uuid references ai_semen(id),
  paddock_id     uuid references paddock(id),
  season         text not null,
  cycle          cycle_t,
  planned_on     date,
  gestation_days smallint check (gestation_days between 130 and 310),
  notes          text,
  joining_id     uuid references joining(id) on delete set null,
  cancelled_on   date,
  created_at     timestamptz not null default now(),
  created_by     uuid references farm_user(id) default auth.uid()
);

comment on table planned_joining is
  'Who is to go to which bull or straw, and when. Not a mating: nothing here counts on Due, in conception rates or against the tank. joining_id is set by trigger when the joining is recorded; cancelled_on when the plan is dropped.';
comment on column planned_joining.gestation_days is
  'Nominated for this plan only. Null = the dam''s own figure, else the species default. Does not rewrite the dam.';
comment on column planned_joining.planned_on is
  'When it is meant to happen. Null is allowed: the who can be decided before the when.';

-- A straw belongs to an AI, a paddock to a bull out. Same rule as joining.
do $$
begin
  alter table planned_joining add constraint planned_joining_method_fields_ck check (
        (method = 'ai'      and paddock_id  is null)
     or (method = 'natural' and ai_semen_id is null));
exception when duplicate_object then null;
end $$;

create index if not exists planned_joining_dam_idx  on planned_joining (dam_id);
create index if not exists planned_joining_open_idx on planned_joining (dam_id, season)
  where joining_id is null and cancelled_on is null;

-- ------------------------------------------------------------
-- 1. The plan with its forecast. gestation_used is the figure the
--    forecast rests on, and nominated_days says whether it was this
--    plan's own or came from the dam. The species defaults here are
--    the same 285 and 145 the phone app uses.
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
  pj.created_at, pj.created_by
from planned_joining pj
join animal d on d.id = pj.dam_id
left join animal   s   on s.id   = pj.sire_id
left join ai_semen sem on sem.id = pj.ai_semen_id
left join paddock  p   on p.id   = pj.paddock_id;

-- ------------------------------------------------------------
-- 2. The joining closes the plan. Dam and season are what the two
--    have in common; which bull or straw was actually used is the
--    joining's business, and a plan for one bull followed by a
--    joining to another is still a plan that was acted on.
-- ------------------------------------------------------------

create or replace function plan_fulfilled()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update planned_joining
     set joining_id = new.id
   where dam_id = new.dam_id
     and season = new.season
     and joining_id is null
     and cancelled_on is null;
  return new;
end $$;

revoke execute on function plan_fulfilled() from public, anon, authenticated;

drop trigger if exists joining_fulfils_plan on joining;
create trigger joining_fulfils_plan
  after insert on joining for each row execute function plan_fulfilled();

-- ------------------------------------------------------------
-- 3. Viewers read. Managers write. Only owners delete. Nothing is
--    silently rewritten.
-- ------------------------------------------------------------

alter table planned_joining enable row level security;

drop policy if exists planned_joining_read   on planned_joining;
drop policy if exists planned_joining_insert on planned_joining;
drop policy if exists planned_joining_update on planned_joining;
drop policy if exists planned_joining_delete on planned_joining;

create policy planned_joining_read   on planned_joining for select to authenticated using (can_read());
create policy planned_joining_insert on planned_joining for insert to authenticated with check (can_write());
create policy planned_joining_update on planned_joining for update to authenticated
  using (can_write()) with check (can_write());
create policy planned_joining_delete on planned_joining for delete to authenticated
  using (my_role() = 'owner');

drop trigger if exists planned_joining_changed on planned_joining;
create trigger planned_joining_changed after update or delete on planned_joining
  for each row execute function log_record_change();

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select dam_code, method, sire_name, planned_on, gestation_used, forecast_on, status
--     from v_planned_joining order by planned_on;
--   -- record a joining for a planned dam and season, then:
--   select dam_code, status, joining_id from v_planned_joining;   -- joined
-- ------------------------------------------------------------
