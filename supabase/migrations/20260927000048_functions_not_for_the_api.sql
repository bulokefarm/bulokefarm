-- ============================================================
-- 48. Functions that were never meant for the API.
--
-- Supabase's security advisor, read for the first time after 47, had
-- two things to say about functions.
--
-- Every security definer function was executable by anon, so PostgREST
-- offered each one at /rest/v1/rpc/<name>. Most are trigger functions,
-- which Postgres refuses to run outside a trigger, so nobody could do
-- anything with them — but the grant was still there, and a grant that
-- exists for no reason is a grant nobody checked. The app calls no
-- functions through rpc at all (grep public/*.html for rpc( — nothing),
-- so the only function that should be callable from outside is beat().
--
-- Triggers do not need EXECUTE at firing time — only when the trigger
-- is created — so revoking from anon and authenticated cannot break a
-- write. refresh_expectation is called only from the two joining
-- triggers, which are security definer and run as the owner, so it can
-- go too. my_role() is different: can_read(), can_write() and every
-- *_delete policy call it as the signed-in user, so authenticated keeps
-- it. anon never had a policy that needed it. The advisor will go on
-- flagging my_role() for signed-in users; that one is intentional.
--
-- Ten older functions also had no fixed search_path, which lets a caller
-- with a schema of their own shadow a table name. Pinning it to public
-- costs nothing here: nothing in them names another schema.
--
-- Safe to run more than once.
-- ============================================================

-- Trigger functions: no role outside the owner needs to call these.
revoke execute on function handle_new_user()           from public, anon, authenticated;
revoke execute on function log_record_change()         from public, anon, authenticated;
revoke execute on function resolve_expected_calving()  from public, anon, authenticated;
revoke execute on function sync_expected_calving()     from public, anon, authenticated;
revoke execute on function sync_expected_calving_del() from public, anon, authenticated;
revoke execute on function rls_auto_enable()           from public, anon, authenticated;

-- Called only from the two triggers above, as their owner.
revoke execute on function refresh_expectation(uuid, text) from public, anon, authenticated;

-- Policies need this as the signed-in user. Nobody else does.
revoke execute on function my_role() from public, anon;
grant  execute on function my_role() to authenticated;

-- Pin the search path.
alter function animal_code_parts()                    set search_path = public;
alter function close_feed_runs_on_exhaustion()        set search_path = public;
alter function cryo_ref_code(text)                    set search_path = public;
alter function farm_today()                           set search_path = public;
alter function feed_line_changed()                    set search_path = public;
alter function feed_qty_kg(numeric, text)             set search_path = public;
alter function feed_resolve_refs()                    set search_path = public;
alter function feed_run_end(uuid, date)               set search_path = public;
alter function feed_source_close_if_empty(uuid)       set search_path = public;
alter function feed_source_quantity_changed()         set search_path = public;

notify pgrst, 'reload schema';
