-- ============================================================
-- Buloke Farm — joining method: AI or bull out
-- Apply after 20260801000012_heartbeat.sql. Safe to run more than once.
--
-- Two events were sharing one word. AI is one cow, one straw, one
-- day. A bull out is one bull and whoever is standing in the paddock,
-- over several weeks. Same outcome, different evidence, so the record
-- has to be able to hold both.
--
-- `confidence` is not added here — it already exists on joining as
-- numeric(3,2) from 0 to 1, and the seed uses it. It was simply never
-- surfaced in the app. The UI now shows it as a percentage.
-- ============================================================

-- ------------------------------------------------------------
-- Gestation length belongs to the cow, not to the joining.
--
-- A cow that runs long runs long every year. Carrying it on her
-- record means it's offered next season instead of retyped. Null
-- means she's never shown otherwise: use the 285 default that
-- joining.gestation_days already carries.
-- ------------------------------------------------------------

alter table animal add column if not exists gestation_days smallint
  check (gestation_days between 250 and 310);

comment on column animal.gestation_days is
  'This cow''s own gestation length, learnt from her calvings. Null = use 285.';

-- ------------------------------------------------------------
-- The semen register.
--
-- Straws on hand. How many are left is derived from the joinings
-- that used them, never stored — the same reasoning as feed stock.
-- ------------------------------------------------------------

create table if not exists ai_semen (
  id            uuid primary key default gen_random_uuid(),
  sire_id       uuid references animal(id),     -- when the bull is on file
  sire_name     text not null,                  -- always, even when he isn't
  breed         text,
  straw_code    text,                           -- what's printed on the straw
  batch_code    text,
  tank          text,                           -- which flask it's in
  supplier      text,
  collected_on  date,
  straws_in     int check (straws_in >= 0),
  notes         text,
  retired_on    date,                           -- used up, or thrown out
  created_at    timestamptz not null default now(),
  created_by    uuid references farm_user(id) default auth.uid()
);
create index if not exists ai_semen_sire_idx on ai_semen (sire_id);

-- ------------------------------------------------------------
-- Which kind of joining it was.
-- ------------------------------------------------------------

do $$
begin
  if not exists (select 1 from pg_type where typname='joining_method_t') then
    create type joining_method_t as enum ('natural','ai');
  end if;
end $$;

alter table joining add column if not exists method      joining_method_t not null default 'natural';
alter table joining add column if not exists ai_semen_id uuid references ai_semen(id);
alter table joining add column if not exists paddock_id  uuid references paddock(id);

-- A straw belongs to an AI joining; a paddock belongs to a bull out.
-- Crossing them means something went wrong upstream.
do $$
begin
  alter table joining add constraint joining_method_fields_ck check (
        (method = 'ai'      and paddock_id  is null)
     or (method = 'natural' and ai_semen_id is null));
exception when duplicate_object then null;
end $$;

create index if not exists joining_semen_idx   on joining (ai_semen_id);
create index if not exists joining_paddock_idx on joining (paddock_id);

comment on column joining.paddock_id is
  'Bull out only: the mob he ran with. Kept after the paddock is retired.';
comment on column joining.gestation_days is
  'What was used to work out due_on, copied from the dam at the time. Historical, not current.';

-- ------------------------------------------------------------
-- Straws left. Derived: a recount corrects straws_in, usage is
-- whatever the joinings say, and the two cannot drift apart.
-- ------------------------------------------------------------

create or replace view v_ai_semen with (security_invoker = on) as
select
  s.*,
  coalesce(u.used, 0)               as straws_used,
  s.straws_in - coalesce(u.used, 0) as straws_left,
  coalesce(a.stock_code, a.name, s.sire_name) as sire_label
from ai_semen s
left join animal a on a.id = s.sire_id
left join lateral (
  select count(*) as used from joining j where j.ai_semen_id = s.id
) u on true;

-- ------------------------------------------------------------
-- Joining results, with the method, the straw and the paddock.
--
-- Dropped rather than replaced: `create or replace view` can only
-- append columns, and method belongs beside the sire rather than
-- bolted on the end. Every column the old view had is kept — the
-- animal detail screen and the family tree read this.
--
-- sire_name falls back to the straw, so an AI to a bull who isn't on
-- the register still names him.
-- ------------------------------------------------------------

drop view if exists v_joining_result;

create view v_joining_result with (security_invoker = on) as
select
  j.id, j.dam_id, d.stock_code as dam_code, d.name as dam_name,
  j.method,
  j.sire_id, coalesce(s.name, sem.sire_name) as sire_name,
  j.ai_semen_id, sem.straw_code, sem.tank,
  j.paddock_id, p.name as paddock_name,
  j.season, j.cycle, j.attempt, j.joined_on, j.bull_out, j.tested_on,
  j.gestation_days, j.due_on, j.confidence, j.outcome, j.notes,
  c.calved_on, c.outcome as calving_outcome,
  calf.stock_code as calf_code,
  (select count(*) from record_change_log l
    where l.table_name='joining' and l.row_id=j.id) as edits
from joining j
join animal d on d.id = j.dam_id
left join animal   s    on s.id    = j.sire_id
left join ai_semen sem  on sem.id  = j.ai_semen_id
left join paddock  p    on p.id    = j.paddock_id
left join calving  c    on c.joining_id = j.id
left join animal   calf on calf.id = c.calf_id;

-- ------------------------------------------------------------
-- Viewers read. Managers write. Only owners delete.
-- Same shape as every other table.
-- ------------------------------------------------------------

alter table ai_semen enable row level security;

drop policy if exists ai_semen_read   on ai_semen;
drop policy if exists ai_semen_insert on ai_semen;
drop policy if exists ai_semen_update on ai_semen;
drop policy if exists ai_semen_delete on ai_semen;

create policy ai_semen_read   on ai_semen for select to authenticated using (can_read());
create policy ai_semen_insert on ai_semen for insert to authenticated with check (can_write());
create policy ai_semen_update on ai_semen for update to authenticated
  using (can_write()) with check (can_write());
create policy ai_semen_delete on ai_semen for delete to authenticated
  using (my_role() = 'owner');

-- Nothing is silently rewritten.
drop trigger if exists ai_semen_changed on ai_semen;
create trigger ai_semen_changed after update or delete on ai_semen
  for each row execute function log_record_change();

-- PostgREST serves a 404 that reads like a missing table without this.
notify pgrst, 'reload schema';
