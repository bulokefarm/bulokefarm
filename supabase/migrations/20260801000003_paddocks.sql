-- ============================================================
-- Buloke Farm — paddocks, boundaries, grazing history
-- Apply after 04_auth_roles.sql
--
-- NOTE ON POSTGIS: deliberately not used. Storing boundaries as
-- GeoJSON in jsonb avoids adding the extension to a 500MB free-tier
-- database, and the only geometry maths we need (polygon area) is a
-- dozen lines of client-side arithmetic. Revisit if you ever need
-- real spatial queries — containment, buffers, nearest-neighbour.
-- ============================================================

create table paddock (
  id          uuid primary key default gen_random_uuid(),
  property_id uuid references property(id),
  name        text not null,
  code        text,                       -- short label drawn on the map
  colour      text default '#4F7A1F',
  geometry    jsonb,                      -- GeoJSON Polygon, [[lng,lat],...]
  area_ha     numeric(8,2),
  sort_order  int default 0,
  notes       text,
  active      boolean not null default true,
  recorded_by uuid references farm_user(id) default auth.uid(),
  created_at  timestamptz not null default now(),
  unique (property_id, name)
);

-- Where an animal is, and where it has been. moved_out null = still there.
create table paddock_stay (
  id         uuid primary key default gen_random_uuid(),
  animal_id  uuid not null references animal(id) on delete cascade,
  paddock_id uuid not null references paddock(id) on delete cascade,
  moved_in   date not null default current_date,
  moved_out  date,
  reason     text,
  recorded_by uuid references farm_user(id) default auth.uid(),
  created_at timestamptz not null default now(),
  check (moved_out is null or moved_out >= moved_in)
);

create index paddock_stay_animal_idx  on paddock_stay (animal_id, moved_in desc);
create index paddock_stay_paddock_idx on paddock_stay (paddock_id) where moved_out is null;

-- One animal can only be in one paddock at a time.
create unique index paddock_stay_one_current
  on paddock_stay (animal_id) where moved_out is null;

-- ------------------------------------------------------------
-- Moving stock: close the old stay, open a new one, atomically.
-- ------------------------------------------------------------

create function move_animals(p_animal_ids uuid[], p_paddock_id uuid,
                             p_on date default current_date, p_reason text default null)
returns int language plpgsql security invoker set search_path = public as $$
declare n int;
begin
  update paddock_stay set moved_out = p_on
   where animal_id = any(p_animal_ids) and moved_out is null and moved_in <= p_on;

  insert into paddock_stay (animal_id, paddock_id, moved_in, reason)
  select unnest(p_animal_ids), p_paddock_id, p_on, p_reason;

  get diagnostics n = row_count;
  return n;
end $$;

-- ------------------------------------------------------------
-- Views
-- ------------------------------------------------------------

-- Paddock with who's in it right now.
create view v_paddock_current with (security_invoker = on) as
select
  p.id, p.name, p.code, p.colour, p.geometry, p.area_ha, p.notes,
  p.sort_order, p.active,
  count(s.animal_id)                                        as head,
  case when p.area_ha > 0
       then round(count(s.animal_id) / p.area_ha, 2) end    as head_per_ha,
  min(s.moved_in)                                           as grazing_since
from paddock p
left join paddock_stay s on s.paddock_id = p.id and s.moved_out is null
where p.active
group by p.id;

-- Rebuild the herd view with location included.
drop view if exists v_animal_current;

create view v_animal_current with (security_invoker = on) as
select
  a.id, a.stock_code, a.name, a.sex, a.dob, a.breed, a.nlis_tag,
  dam.stock_code as dam_code, dam.name as dam_name, sire.name as sire_name,
  (current_date - a.dob)                       as age_days,
  round((current_date - a.dob) / 30.4375, 2)   as age_months,
  round((current_date - a.dob) / 365.25, 2)    as age_years,
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
  st.moved_in as in_paddock_since
from animal a
left join animal dam  on dam.id  = a.dam_id
left join animal sire on sire.id = a.sire_id
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
where a.origin <> 'reference';

-- ------------------------------------------------------------
-- RLS, matching the pattern in 04.
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['paddock','paddock_stay'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format($f$create policy %I_delete on %I for delete to authenticated using (my_role() = 'owner')$f$, t, t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- The home property, so paddocks have something to hang off.
-- ------------------------------------------------------------

update property
   set name = 'Buloke Farm', address = '267 North Canal Rd, Trafalgar VIC 3824'
 where pic = '3BWWY089';
