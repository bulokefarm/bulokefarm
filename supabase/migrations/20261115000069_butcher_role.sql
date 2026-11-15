-- ============================================================
-- 69. A butcher is on the farm, but not in the herd.
--
-- The butcher gets a login so the cut sheets can be read and printed
-- at the shop instead of being emailed as a spreadsheet. That login
-- must see the sheets and nothing else: not the herd, not the LPA
-- records, not what a customer paid.
--
-- Until now every member of a farm could read all of it — can_read()
-- was "you have a role". A fourth role that is a member and is NOT a
-- reader means can_read() has to say which roles read. Owner, manager
-- and viewer still do; nothing changes for them. A butcher reads
-- through butcher_harvests() and butcher_sheet() (migration 71), which
-- hand back exactly what goes on the printed sheets.
--
-- The enum value is added here and not named as a literal anywhere in
-- this file: `alter type ... add value` cannot be used in the
-- transaction that added it. Roles are compared as text for the same
-- reason, here and in 71.
--
-- Safe to run more than once.
-- ============================================================

alter type farm_role_t add value if not exists 'butcher';

create or replace function can_read() returns boolean
language sql stable set search_path = public as $$
  select coalesce(my_role()::text in ('owner', 'manager', 'viewer'), false)
$$;

comment on function can_read() is
  'Owner, manager or viewer on the session''s farm. A butcher is a member but not a reader.';

-- Who else is on the farm is not the butcher's business either. Your
-- own membership and your own profile stay visible to you whatever
-- your role — v_me and v_my_farms are built on exactly that.
drop policy if exists farm_member_read on farm_member;
create policy farm_member_read on farm_member
  for select to authenticated
  using (user_id = auth.uid()
         or (farm_id = (select current_farm()) and can_read()));

drop policy if exists farm_user_read on farm_user;
create policy farm_user_read on farm_user
  for select to authenticated
  using (id = auth.uid()
         or (can_read()
             and exists (select 1 from farm_member m
                          where m.user_id = farm_user.id
                            and m.farm_id = (select current_farm()))));

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- Giving the butcher a login:
--
--   1. Supabase -> Authentication -> Users -> Add user, auto-confirm.
--   2. Record -> Manage -> Who can see this farm -> their email,
--      role "Butcher". (add_member() takes the role as it always has.)
--
-- They sign in at /butcher.
-- ------------------------------------------------------------
