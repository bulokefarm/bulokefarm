-- ============================================================
-- Buloke Farm — full animal detail, display preferences, bulk edits
-- Apply after 12_consignment.sql. Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Per-user display preferences.
--    Kept in its own table rather than a column on farm_user, so
--    someone saving a preference can never touch their own role.
-- ------------------------------------------------------------

create table if not exists user_pref (
  user_id    uuid primary key references farm_user(id) on delete cascade,
  prefs      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table user_pref enable row level security;
drop policy if exists user_pref_own on user_pref;
create policy user_pref_own on user_pref
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ------------------------------------------------------------
-- 2. The herd view, carrying every animal column so the app can
--    show and edit any of them.
-- ------------------------------------------------------------

drop view if exists v_animal_current;

create view v_animal_current with (security_invoker = on) as
select
  a.id, a.stock_code, a.year_letter, a.herd_number, a.name, a.nlis_tag,
  a.origin, a.sex, a.dob, a.breed, a.grade, a.coat_colour, a.polled,
  a.marking_code, a.birth_weight_kg, a.weaned_on, a.notes,
  a.purchased_on, a.purchase_note,
  a.heritage_id,  h.name  as heritage_name,
  a.property_id,  pr.pic  as pic,
  a.origin_property_id, opr.pic as origin_pic,
  a.sire_id, sire.name as sire_name,
  a.dam_id,  dam.stock_code as dam_code, dam.name as dam_name,

  (current_date - a.dob)                     as age_days,
  round((current_date - a.dob) / 30.4375, 2) as age_months,
  round((current_date - a.dob) / 365.25, 2)  as age_years,

  s.life_state, s.class,
  w.weight_kg  as last_weight_kg,
  w.weighed_on as last_weighed_on,
  case when w.weight_kg is not null and a.birth_weight_kg is not null
            and w.weighed_on > a.dob
       then round((w.weight_kg - a.birth_weight_kg) / (w.weighed_on - a.dob), 4)
  end as adg_kg_per_day,

  pk.id       as paddock_id,
  pk.name     as paddock_name,
  pk.colour   as paddock_colour,
  st.moved_in as in_paddock_since,

  cl.clear_domestic, cl.within_whp
from animal a
left join animal dam   on dam.id  = a.dam_id
left join animal sire  on sire.id = a.sire_id
left join heritage h   on h.id    = a.heritage_id
left join property pr  on pr.id   = a.property_id
left join property opr on opr.id  = a.origin_property_id
left join lateral (
  select life_state, class from animal_status
  where animal_id = a.id and effective_on <= current_date
  order by effective_on desc limit 1) s on true
left join lateral (
  select weight_kg, weighed_on from weight_event
  where animal_id = a.id order by weighed_on desc limit 1) w on true
left join lateral (
  select paddock_id, moved_in from paddock_stay
  where animal_id = a.id and moved_out is null limit 1) st on true
left join paddock pk on pk.id = st.paddock_id
left join v_animal_clearance cl on cl.animal_id = a.id
where a.origin <> 'reference';

-- ------------------------------------------------------------
-- 3. Bulk status change — promoting a cohort, marking losses.
--    One dated transition per animal, so history stays intact.
-- ------------------------------------------------------------

create or replace function set_animal_status(
    p_animal_ids uuid[],
    p_life_state life_state_t default null,
    p_class      animal_class_t default null,
    p_on         date default current_date,
    p_reason     text default null)
returns int language plpgsql security invoker set search_path = public as $$
declare n int;
begin
  if p_life_state is null and p_class is null then
    raise exception 'Nothing to change';
  end if;

  insert into animal_status (animal_id, effective_on, life_state, class, reason)
  select a.id, p_on,
         coalesce(p_life_state, prev.life_state, 'alive'),
         coalesce(p_class, prev.class),
         p_reason
    from unnest(p_animal_ids) as a(id)
    left join lateral (
      select life_state, class from animal_status
       where animal_id = a.id and effective_on <= p_on
       order by effective_on desc limit 1) prev on true
  on conflict (animal_id, effective_on) do update
     set life_state = excluded.life_state,
         class      = excluded.class,
         reason     = coalesce(excluded.reason, animal_status.reason);

  get diagnostics n = row_count;
  return n;
end $$;

-- ------------------------------------------------------------
-- 4. Sires and dams available to choose from.
-- ------------------------------------------------------------

create or replace view v_breeding_stock with (security_invoker = on) as
select a.id, a.name, a.stock_code, a.sex, a.origin,
       coalesce(nullif(trim(concat_ws(' ', a.stock_code, a.name)), ''), 'Unnamed') as label
from animal a
where a.origin = 'reference' or a.sex in ('female','male');
