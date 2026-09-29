-- ============================================================
-- 60. add_member() said "they need to sign up first".
--
-- There is nowhere to sign up. The pages have a sign-in form and
-- nothing else; a login is made in Supabase Authentication by
-- whoever looks after the app, as Anna's was. The message sent an
-- owner looking for a screen that does not exist. Only the wording
-- changes.
--
-- Safe to run more than once.
-- ============================================================

create or replace function add_member(p_email text, p_role farm_role_t default 'viewer')
returns text
language plpgsql security definer set search_path = public as $$
declare
  uid   uuid;
  fid   uuid := current_farm();
  who   text;
begin
  if fid is null or my_role() <> 'owner' then
    raise exception 'Only an owner can add people to the farm';
  end if;
  select u.id into uid from auth.users u
   where lower(u.email) = lower(trim(p_email));
  if uid is null then
    raise exception 'There is no login for % yet. One has to be created for them first; then add them here.', trim(p_email);
  end if;
  insert into farm_member (farm_id, user_id, role, active)
  values (fid, uid, p_role, true)
  on conflict (farm_id, user_id) do update set role = excluded.role, active = true;
  update farm_user set current_farm_id = coalesce(current_farm_id, fid) where id = uid;
  select display_name into who from farm_user where id = uid;
  return who;
end $$;

revoke execute on function add_member(text, farm_role_t) from public, anon;
grant  execute on function add_member(text, farm_role_t) to authenticated;
