-- ============================================================
-- 53. The farm: the layer above the PIC.
--
-- One farm has lived in this database since August. Every policy
-- asks one question — is this login an active viewer, manager or
-- owner — and answers it from a single global role on farm_user, so
-- anyone active sees everything. Right for one farm, wrong for two.
--
-- This is the groundwork: the farm, who belongs to it, and the two
-- helpers the policies will be built on. Nothing reads any of it
-- yet except my_role(), which now takes its answer from farm_member
-- instead of farm_user — same answer, new source. 54 puts farm_id on
-- every table and 55 makes the policies look at it.
--
-- A farm is not a PIC. Richard and Dad run two PICs on one farm,
-- stock run as one mob across every paddock, and animal.property_id
-- says whose each beast is. That stays. The farm is who runs the app
-- on this land; the property is which registration each animal and
-- each paddock sits under. See farm_scope_plan.md.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The farm
-- ------------------------------------------------------------

create table if not exists farm (
  id           uuid primary key default gen_random_uuid(),
  slug         text unique not null,     -- 'buloke'. URL-safe, never changes
  name         text not null,            -- 'Buloke Farm'. The app chrome once signed in
  address      text,
  hostname     text unique,              -- which site name shows this farm before sign-in
  logo_url     text,                     -- the farm's mark inside the app; null shows the app's own
  timezone     text not null default 'Australia/Melbourne',
  created_at   timestamptz not null default now(),
  constraint farm_slug_ck check (slug ~ '^[a-z0-9-]{2,40}$')
);

comment on table farm is
  'Who runs the app on this land. Above property (a PIC): one farm may trade under several PICs.';
comment on column farm.hostname is
  'The site name that shows this farm''s name and logo on the login screen. After sign-in the farm comes from membership, not the hostname.';
comment on column farm.timezone is
  'Recorded for the day this farm needs; nothing reads it yet. farm_today() is Melbourne until a farm elsewhere exists to test against.';

-- ------------------------------------------------------------
-- 2. Who belongs to it. Role and active move here from farm_user,
--    which becomes a plain profile (55 drops the old columns).
-- ------------------------------------------------------------

create table if not exists farm_member (
  farm_id      uuid not null references farm(id) on delete cascade,
  user_id      uuid not null references farm_user(id) on delete cascade,
  role         farm_role_t not null default 'viewer',
  active       boolean not null default false,
  created_at   timestamptz not null default now(),
  primary key (farm_id, user_id)
);

comment on table farm_member is
  'One row per login per farm. A login with no active row belongs nowhere and sees nothing.';

-- Which farm this login is working in. Almost everyone has one
-- membership and this is redundant; it exists so a second membership
-- is a column update rather than a redesign.
alter table farm_user add column if not exists current_farm_id uuid references farm(id);

-- ------------------------------------------------------------
-- 3. Buloke, and everyone already here
-- ------------------------------------------------------------

insert into farm (slug, name, address, hostname)
values ('buloke', 'Buloke Farm', '267 North Canal Rd, Trafalgar VIC 3824',
        'admin.bulokefarm.com.au')
on conflict (slug) do nothing;

-- The old columns exist until 55 drops them; a re-run after that
-- must not name them.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'farm_user'
                and column_name = 'role') then
    insert into farm_member (farm_id, user_id, role, active)
    select f.id, u.id, u.role, u.active
      from farm_user u cross join farm f
     where f.slug = 'buloke'
    on conflict (farm_id, user_id) do nothing;
  end if;
end $$;

update farm_user
   set current_farm_id = (select id from farm where slug = 'buloke')
 where current_farm_id is null
   and exists (select 1 from farm_member m
                where m.user_id = farm_user.id
                  and m.farm_id = (select id from farm where slug = 'buloke'));

-- ------------------------------------------------------------
-- 4. The helpers
-- ------------------------------------------------------------

-- The farm this session works in.
--
-- For a signed-in user: the farm they chose, provided they are an
-- active member of it; otherwise their one active membership.
-- Security definer because farm_member has RLS of its own and this
-- is what that RLS is built from.
--
-- For a session with no JWT — the SQL editor, a seed, a migration —
-- there is no membership to consult, so the farm can be named with
--   select set_config('app.farm', '<farm uuid>', false);
-- at the top of the script. That setting is ignored the moment a
-- JWT is present, so nothing coming through the API can use it.
create or replace function current_farm() returns uuid
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select u.current_farm_id
       from farm_user u
       join farm_member m on m.farm_id = u.current_farm_id
                         and m.user_id = u.id and m.active
      where u.id = auth.uid()),
    (select m.farm_id
       from farm_member m
      where m.user_id = auth.uid() and m.active
      order by m.created_at
      limit 1),
    case when auth.uid() is null
         then nullif(current_setting('app.farm', true), '')::uuid
    end)
$$;

revoke execute on function current_farm() from public, anon;
grant  execute on function current_farm() to authenticated;

comment on function current_farm() is
  'The farm this session works in: membership for a signed-in user, the app.farm setting for a script with no JWT.';

-- Same name, same callers — can_read(), can_write(), every *_delete
-- policy — new source of truth. Grants from 48 carry over.
create or replace function my_role() returns farm_role_t
language sql stable security definer set search_path = public as $$
  select m.role
    from farm_member m
   where m.user_id = auth.uid()
     and m.farm_id = current_farm()
     and m.active
$$;

-- New sign-ups get a profile and nothing else. Membership is granted
-- by an owner, as it always was — the bootstrap in 02 is now an
-- insert into farm_member.
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into farm_user (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email))
  on conflict (id) do nothing;
  return new;
end $$;

-- The old columns are still there until 55; make sure a profile
-- inserted without them lands inactive, as it did before.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'farm_user'
                and column_name = 'active') then
    alter table farm_user alter column active set default false;
  end if;
end $$;

-- ------------------------------------------------------------
-- 5. Policies on the new tables, and farm_user narrowed
-- ------------------------------------------------------------

alter table farm        enable row level security;
alter table farm_member enable row level security;

-- Your farm, readable; editable by its owners; created and deleted
-- in SQL only.
drop policy if exists farm_read   on farm;
drop policy if exists farm_update on farm;
create policy farm_read on farm
  for select to authenticated using (id = (select current_farm()));
create policy farm_update on farm
  for update to authenticated
  using      (id = (select current_farm()) and my_role() = 'owner')
  with check (id = (select current_farm()) and my_role() = 'owner');

-- Members of your farm, readable; managed by its owners.
drop policy if exists farm_member_read   on farm_member;
drop policy if exists farm_member_manage on farm_member;
create policy farm_member_read on farm_member
  for select to authenticated using (farm_id = (select current_farm()));
create policy farm_member_manage on farm_member
  for all to authenticated
  using      (farm_id = (select current_farm()) and my_role() = 'owner')
  with check (farm_id = (select current_farm()) and my_role() = 'owner');

-- farm_user: "everyone can see who's on the farm" becomes "who is on
-- *my* farm", plus yourself. v_treatment_lpa joins this for the
-- operator's name; the operator is a co-member, so it still resolves.
drop policy if exists farm_user_read   on farm_user;
drop policy if exists farm_user_manage on farm_user;
drop policy if exists farm_user_update on farm_user;
create policy farm_user_read on farm_user
  for select to authenticated
  using (id = auth.uid()
         or exists (select 1 from farm_member m
                     where m.user_id = farm_user.id
                       and m.farm_id = (select current_farm())));
create policy farm_user_update on farm_user
  for update to authenticated
  using (id = auth.uid()
         or (my_role() = 'owner'
             and exists (select 1 from farm_member m
                          where m.user_id = farm_user.id
                            and m.farm_id = (select current_farm()))))
  with check (id = auth.uid()
         or (my_role() = 'owner'
             and exists (select 1 from farm_member m
                          where m.user_id = farm_user.id
                            and m.farm_id = (select current_farm()))));

-- ------------------------------------------------------------
-- 6. What the pages read
-- ------------------------------------------------------------

-- Me, on this farm: replaces the pages' select on farm_user for role
-- and active, and carries the farm's name and mark with it.
create or replace view v_me with (security_invoker = on) as
select m.user_id        as id,
       u.display_name,
       u.phone,
       m.role,
       m.active,
       m.farm_id,
       f.slug,
       f.name            as farm_name,
       f.address         as farm_address,
       f.logo_url,
       f.timezone
  from farm_member m
  join farm_user u on u.id = m.user_id
  join farm      f on f.id = m.farm_id
 where m.user_id = auth.uid()
   and m.farm_id = current_farm();

-- The login screen, before anyone has signed in: which farm does this
-- site name belong to. Definer view, deliberately: anon cannot read
-- farm, and should not be able to read more of it than this. Names
-- and marks are on the letterhead of every report already.
create or replace view v_farm_public as
select slug, name, logo_url, hostname from farm;

revoke all on v_farm_public from public;
grant select on v_farm_public to anon, authenticated;

-- Said out loud rather than left to default privileges. On the cloud
-- project everything postgres creates is granted to anon and
-- authenticated by default; a local CLI stack grants nothing, and the
-- pages got 403 on v_me there. RLS is what actually decides who sees
-- what; these grants just let the API ask.
grant select                         on farm        to authenticated;
grant update                         on farm        to authenticated;
grant select, insert, update, delete on farm_member to authenticated;
grant select                         on v_me        to authenticated;

-- ------------------------------------------------------------
-- 7. Adding someone to the farm
--
-- A new sign-up is a profile with no membership, and an owner cannot
-- see profiles that are not on their farm — so there is no way from
-- the pages to find the person you want to add. This looks them up
-- by the email they signed up with, as owner, and adds them to the
-- caller's farm. Owners only; the check is inside, not in a policy,
-- because the function runs as owner and policies do not apply.
-- The one function besides beat() that the API may call.
-- ------------------------------------------------------------

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
    raise exception 'Nobody has signed up with %. They need to sign up first, then you add them.', trim(p_email);
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

-- ------------------------------------------------------------
-- 8. Somewhere for the marks to live
-- ------------------------------------------------------------

do $$
begin
  if to_regclass('storage.buckets') is not null then
    insert into storage.buckets (id, name, public)
    values ('farm-logos', 'farm-logos', true)
    on conflict (id) do nothing;
  end if;
end $$;

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- Adding a farm, once this is in:
--
--   insert into farm (slug, name, address, hostname)
--   values ('toland', 'Toland Merino', '…', 'admin.tolandmerino.com.au');
--
--   insert into farm_member (farm_id, user_id, role, active)
--   select f.id, u.id, 'owner', true
--     from farm f, auth.users u
--    where f.slug = 'toland' and u.email = 'them@example.com';
--
-- Their PICs go in property with farm_id set (54), one is_primary.
-- ------------------------------------------------------------
