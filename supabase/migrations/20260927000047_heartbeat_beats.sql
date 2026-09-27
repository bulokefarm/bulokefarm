-- ============================================================
-- 47. The heartbeat writes.
--
-- Supabase warned the project would be paused for "insufficient
-- activity" while `Keep database awake` was running every weekday and
-- returning 200. One one-row read a day, and none at the weekend, is
-- below the bar they now apply ("a few user requests to the database
-- each day"). Reads of a one-row table are also the cheapest thing
-- Postgres does, and may be served without touching much at all.
--
-- So the heartbeat gets a timestamp, and the job now also calls beat(),
-- which writes it. A write is unambiguous activity. The function is
-- security definer so the anon key can run it without any insert or
-- update policy on the table — it can do exactly one thing.
--
-- Still contains nothing, still exposes nothing. Drop with the rest of
-- the heartbeat once the project is on a paid plan.
-- ============================================================

alter table heartbeat add column if not exists beat_at timestamptz;

create or replace function beat()
returns timestamptz
language sql
security definer
set search_path = public
as $$
  update heartbeat set beat_at = now() where ok returning beat_at;
$$;

revoke all on function beat() from public;
grant execute on function beat() to anon, authenticated;

notify pgrst, 'reload schema';
