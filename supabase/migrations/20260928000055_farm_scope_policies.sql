-- ============================================================
-- 55. The policies look at the farm.
--
-- The cutover. Every policy from 02, 03, 04, 05, 06, 08, 09, 13, 19,
-- 31, 36, 40, 42 and 49 is re-created with one added predicate:
-- the row's farm is the session's farm. Role checks are unchanged.
-- The views need nothing — all 34 run as the caller, so once the
-- base tables are scoped, so are they.
--
-- For Buloke the visible effect is none: one farm, every row in it,
-- every member of it. The proof is farm_scope_plan.md §8 — the same
-- checksum of every view before 54 and after this.
--
-- Also here, because this is the first point at which nothing reads
-- them: farm_user.role and farm_user.active go. And a policy nobody
-- wrote down, ai_semen_write — "for all, to public, if you are an
-- active user" — goes with them; it let a viewer edit the semen
-- register, and its four named siblings already say who may.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The standard four, on every scoped table
--
-- (select current_farm()) rather than current_farm() so the planner
-- evaluates it once per statement as an init-plan, not once per row.
-- ------------------------------------------------------------

do $$
declare
  t text;
  standard text[] := array[
    'property', 'heritage', 'animal', 'animal_status', 'weight_event',
    'treatment', 'treatment_animal', 'joining', 'calving', 'expected_calving',
    'planned_joining', 'paddock', 'paddock_stay',
    'feed_source', 'feed_event', 'feed_event_animal', 'feed_event_ref', 'feed_adjustment',
    'consignment', 'consignment_animal', 'shearing', 'shearing_animal',
    'ai_semen', 'embryo', 'cryo_txn', 'spray_event', 'spray_product'
  ];
begin
  foreach t in array standard loop
    execute format('drop policy if exists %I on %I', t || '_read',   t);
    execute format('drop policy if exists %I on %I', t || '_insert', t);
    execute format('drop policy if exists %I on %I', t || '_update', t);
    execute format('drop policy if exists %I on %I', t || '_delete', t);

    execute format($p$create policy %I on %I for select to authenticated
      using (farm_id = (select current_farm()) and can_read())$p$, t || '_read', t);
    execute format($p$create policy %I on %I for insert to authenticated
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_insert', t);
    execute format($p$create policy %I on %I for update to authenticated
      using      (farm_id = (select current_farm()) and can_write())
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_update', t);
    execute format($p$create policy %I on %I for delete to authenticated
      using (farm_id = (select current_farm()) and my_role() = 'owner')$p$, t || '_delete', t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 2. The ones that were never quite the standard four
-- ------------------------------------------------------------

-- Paddock history: read, insert, delete; never updated (04).
do $$
declare t text;
begin
  foreach t in array array['paddock_lineage', 'paddock_geometry_log'] loop
    execute format('drop policy if exists %I on %I', t || '_read',   t);
    execute format('drop policy if exists %I on %I', t || '_insert', t);
    execute format('drop policy if exists %I on %I', t || '_update', t);
    execute format('drop policy if exists %I on %I', t || '_delete', t);
    execute format($p$create policy %I on %I for select to authenticated
      using (farm_id = (select current_farm()) and can_read())$p$, t || '_read', t);
    execute format($p$create policy %I on %I for insert to authenticated
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_insert', t);
    execute format($p$create policy %I on %I for delete to authenticated
      using (farm_id = (select current_farm()) and my_role() = 'owner')$p$, t || '_delete', t);
  end loop;
end $$;

-- Taking a paddock off a pass is an edit, so a manager may (42).
drop policy if exists spray_paddock_read   on spray_paddock;
drop policy if exists spray_paddock_insert on spray_paddock;
drop policy if exists spray_paddock_update on spray_paddock;
drop policy if exists spray_paddock_delete on spray_paddock;
create policy spray_paddock_read on spray_paddock
  for select to authenticated using (farm_id = (select current_farm()) and can_read());
create policy spray_paddock_insert on spray_paddock
  for insert to authenticated with check (farm_id = (select current_farm()) and can_write());
create policy spray_paddock_update on spray_paddock
  for update to authenticated
  using      (farm_id = (select current_farm()) and can_write())
  with check (farm_id = (select current_farm()) and can_write());
create policy spray_paddock_delete on spray_paddock
  for delete to authenticated using (farm_id = (select current_farm()) and can_write());

-- The change log: readable by anyone who can read the records,
-- writable by nobody but the triggers (06).
drop policy if exists record_change_log_read on record_change_log;
create policy record_change_log_read on record_change_log
  for select to authenticated using (farm_id = (select current_farm()) and can_read());

-- The policy nobody wrote down.
drop policy if exists ai_semen_write on ai_semen;

-- Unchanged, and said so: heartbeat_anon (global), user_pref_own (per
-- login). farm, farm_member, farm_user were done in 53.

-- ------------------------------------------------------------
-- 3. An animal's PIC is one of this farm's
--
-- The address book is per farm now, so the check is simply "can I
-- see that property row" — under RLS that is only this farm's.
-- ------------------------------------------------------------

drop policy if exists animal_insert on animal;
drop policy if exists animal_update on animal;
create policy animal_insert on animal
  for insert to authenticated
  with check (farm_id = (select current_farm()) and can_write()
              and (property_id        is null or exists (select 1 from property p where p.id = property_id))
              and (origin_property_id is null or exists (select 1 from property p where p.id = origin_property_id)));
create policy animal_update on animal
  for update to authenticated
  using      (farm_id = (select current_farm()) and can_write())
  with check (farm_id = (select current_farm()) and can_write()
              and (property_id        is null or exists (select 1 from property p where p.id = property_id))
              and (origin_property_id is null or exists (select 1 from property p where p.id = origin_property_id)));

-- Likewise a paddock's.
drop policy if exists paddock_insert on paddock;
drop policy if exists paddock_update on paddock;
create policy paddock_insert on paddock
  for insert to authenticated
  with check (farm_id = (select current_farm()) and can_write()
              and (property_id is null or exists (select 1 from property p where p.id = property_id)));
create policy paddock_update on paddock
  for update to authenticated
  using      (farm_id = (select current_farm()) and can_write())
  with check (farm_id = (select current_farm()) and can_write()
              and (property_id is null or exists (select 1 from property p where p.id = property_id)));

-- ------------------------------------------------------------
-- 4. The old columns go
-- ------------------------------------------------------------

alter table farm_user drop column if exists role;
alter table farm_user drop column if exists active;

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- Not changed here, and why:
--
--   record_calving(), record_drop() — their fallback "the primary
--   property" is already this farm's under RLS, because they run as
--   the caller. year_letter()'s herd vote, the same.
--
--   refresh_expectation() and the other owner-run triggers insert
--   into child tables, whose farm_id the 54 trigger takes from the
--   parent row; nothing for them to add.
--
--   farm_today() is still Melbourne. farm.timezone waits for a farm
--   elsewhere to test against.
-- ------------------------------------------------------------
