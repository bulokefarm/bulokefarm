-- ============================================================
-- Buloke Farm — users, roles, attribution
-- Apply after 01_schema.sql
-- ============================================================

create type farm_role_t as enum ('owner', 'manager', 'viewer');

-- Profile mirrors auth.users. Supabase owns identity; this owns
-- what that identity is allowed to do on the farm.
create table farm_user (
  id            uuid primary key references auth.users(id) on delete cascade,
  display_name  text not null,
  role          farm_role_t not null default 'viewer',
  phone         text,                      -- for LPA 'treated by' contact
  active        boolean not null default true,
  created_at    timestamptz not null default now()
);

alter table farm_user enable row level security;

-- New signups land as inactive viewers. Access is granted deliberately,
-- not by whoever finds the login page.
create function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into farm_user (id, display_name, role, active)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), 'viewer', false);
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ------------------------------------------------------------
-- Helpers. STABLE so the planner caches them per statement.
-- ------------------------------------------------------------

create function my_role() returns farm_role_t
language sql stable security definer set search_path = public as $$
  select role from farm_user where id = auth.uid() and active
$$;

create function can_write() returns boolean
language sql stable set search_path = public as $$
  select my_role() in ('owner', 'manager')
$$;

create function can_read() returns boolean
language sql stable set search_path = public as $$
  select my_role() is not null
$$;

-- ------------------------------------------------------------
-- Attribution. Who recorded this, and when.
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array[
    'animal','animal_status','weight_event','treatment','joining',
    'calving','expected_calving','feeding_period','movement'
  ] loop
    execute format(
      'alter table %I add column recorded_by uuid references farm_user(id) default auth.uid()', t);
  end loop;
end $$;

-- LPA Section 2 wants the operator's name and contact. Derive it from
-- the login rather than asking someone to type it every time.
create view v_treatment_lpa with (security_invoker = on) as
select
  t.treated_on,
  t.description,
  t.product_name,
  t.batch_number,
  t.product_expiry,
  t.dose_rate,
  t.withholding_days,
  t.esi_days,
  t.safe_for_slaughter,
  coalesce(t.treated_by, u.display_name)        as treated_by,
  coalesce(t.treated_by_contact, u.phone)       as treated_by_contact,
  t.adverse_reaction,
  t.broken_needle,
  count(ta.animal_id)                           as head_count
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
group by t.id, u.display_name, u.phone;

-- ------------------------------------------------------------
-- Replace the placeholder policies with role-aware ones.
-- Viewers read. Managers write. Only owners delete.
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array[
    'property','heritage','animal','animal_status','weight_event',
    'treatment','treatment_animal','joining','calving','expected_calving',
    'feeding_period','movement','movement_animal'
  ] loop
    execute format('drop policy if exists %I_authenticated on %I', t, t);

    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format($f$create policy %I_delete on %I for delete to authenticated using (my_role() = 'owner')$f$, t, t);
  end loop;
end $$;

-- Everyone can see who's on the farm; only owners change roles.
create policy farm_user_read on farm_user
  for select to authenticated using (can_read());
create policy farm_user_manage on farm_user
  for all to authenticated using (my_role() = 'owner') with check (my_role() = 'owner');

-- ------------------------------------------------------------
-- Bootstrap: promote yourself after first signup, then flip Dad on.
--
--   update farm_user set role = 'owner', active = true
--   where id = (select id from auth.users where email = 'you@example.com');
--
-- Run once via the SQL editor. Deliberately not automated — the first
-- owner should be a decision, not a race condition.
-- ------------------------------------------------------------
