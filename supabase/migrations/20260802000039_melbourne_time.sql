-- ============================================================
-- Buloke Farm — the farm is in Melbourne time, not UTC
-- Apply after 20260802000038_last_feed_run.sql.
-- Safe to run more than once.
--
-- A Postgres session defaults to UTC, and Supabase does not change
-- it. `current_date` therefore returns the UTC date, which between
-- midnight and 10am AEST (11am AEDT) is YESTERDAY here. Every
-- derived figure in the app is a day short for that whole window:
--
--   days on feed        72 when it is 73
--   est. days left       2 when it is 1
--   age in days/months/years
--   withholding and export intervals in v_animal_clearance
--   head counts as at a date, in the trading account
--
-- The withholding one is the reason this is not cosmetic. An animal
-- clearing its WHP today reads as still inside it until mid-morning,
-- and the LPA declaration is generated off that view.
--
-- 76 uses of current_date across 20 migrations, so this fixes the
-- session rather than rewriting every view. timestamptz values are
-- stored as UTC internally and are NOT altered — only the zone they
-- are read back in changes. Verified: the epoch is identical before
-- and after.
--
-- Role settings override the database setting, so both are set. Any
-- role we are not allowed to alter is skipped rather than aborting
-- the migration.
--
-- TAKES EFFECT ON NEW SESSIONS ONLY. Pooled connections keep UTC
-- until they recycle. See the verification block at the bottom.
-- ============================================================

do $$
declare
  r text;
  zone constant text := 'Australia/Melbourne';
begin
  begin
    execute format('alter database %I set timezone = %L', current_database(), zone);
    raise notice 'database % set to %', current_database(), zone;
  exception when insufficient_privilege then
    raise notice 'could not set database timezone — check the roles below took';
  end;

  foreach r in array array['authenticator','anon','authenticated',
                           'service_role','postgres'] loop
    if exists (select 1 from pg_roles where rolname = r) then
      begin
        execute format('alter role %I set timezone = %L', r, zone);
        raise notice 'role % set to %', r, zone;
      exception when others then
        raise notice 'role % skipped: %', r, sqlerrm;
      end;
    end if;
  end loop;
end $$;

-- ------------------------------------------------------------
-- The farm's today, independent of whatever the session is set to.
--
-- The setting above fixes all 76 existing uses of current_date at
-- once, which is why they were not rewritten. Use this in NEW views
-- where being wrong by a day would matter — anything feeding a
-- withholding period, a declaration or a days-on-feed figure — so
-- they stay right even if a connection turns up on UTC.
-- ------------------------------------------------------------

create or replace function farm_today()
returns date language sql stable as $$
  select (current_timestamp at time zone 'Australia/Melbourne')::date
$$;

comment on function farm_today() is
  'Today at the farm. Correct regardless of session timezone; prefer over current_date in new views.';

-- ------------------------------------------------------------
-- Verify, in a NEW session (open a fresh SQL editor tab):
--
--   show timezone;                      -- Australia/Melbourne
--   select current_date, farm_today();  -- must match
--
-- If they differ, the pooler handed back a session that predates
-- this migration, or a role setting did not take. Check the notices
-- raised above.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- Due dates that may be a day early.
--
-- The app computed due_on in JavaScript as
--   new Date(joined_on); d.setDate(d.getDate() + gestation);
--   d.toISOString().slice(0,10)
-- which anchors at UTC midnight, steps in LOCAL days, then reads the
-- UTC date back. Where the joining and the due date sit on opposite
-- sides of a daylight-saving change the offset shifts by an hour and
-- the answer lands a day early. A June joining due in March — the
-- ordinary autumn-calving pattern here — is exactly that case:
--   7 Jun 2026 + 285 gave 18 Mar 2027, when it is the 19th.
--
-- due_on is a stored column, so the wrong values are on file. They
-- are NOT rewritten here, because a due date may also have been
-- adjusted deliberately after a vet check and this migration cannot
-- tell the two apart. The view names them instead:
--
--   select * from v_due_date_check;
--
-- A `drift` of exactly 1 is the bug. Anything else was a decision.
-- To accept the arithmetic for the one-day cases only:
--
--   update joining set due_on = joined_on + gestation_days
--    where id in (select id from v_due_date_check where drift = 1);
--
-- The expected_calving trigger fires on due_on and will refresh.
-- ------------------------------------------------------------

create or replace view v_due_date_check with (security_invoker = on) as
select
  j.id,
  j.joined_on,
  j.gestation_days,
  j.due_on                                as due_on_recorded,
  (j.joined_on + j.gestation_days)        as due_on_calculated,
  (j.joined_on + j.gestation_days) - j.due_on as drift
from joining j
where j.joined_on is not null
  and j.gestation_days is not null
  and j.due_on is not null
  and j.due_on <> j.joined_on + j.gestation_days
order by j.joined_on;

notify pgrst, 'reload schema';
