-- ============================================================
-- Buloke Farm — paddock lifecycle: retirement, lineage, geometry history
-- Apply after 05_paddocks.sql
--
-- Safe to run more than once: every step guards itself, so it does not
-- matter how far a previous attempt got before it failed.
--
-- Paddocks get subdivided, amalgamated, and have fences shifted.
-- None of that should destroy the record of what grazed where.
-- The rule here: a paddock is never deleted once it has history,
-- only retired. Its boundary at the time is kept.
-- ============================================================

-- ------------------------------------------------------------
-- 0. Drop dependent views FIRST. Rebuilt in section 6.
-- ------------------------------------------------------------

drop view if exists v_paddock_current;
drop view if exists v_paddock_all;

-- ------------------------------------------------------------
-- 1. Stop deletes from taking grazing history with them.
-- ------------------------------------------------------------

alter table paddock_stay drop constraint if exists paddock_stay_paddock_id_fkey;
alter table paddock_stay
  add constraint paddock_stay_paddock_id_fkey
  foreign key (paddock_id) references paddock(id) on delete restrict;

-- ------------------------------------------------------------
-- 2. Retirement replaces the active flag.
--    active was a boolean with no memory; retired_on says when.
-- ------------------------------------------------------------

alter table paddock add column if not exists retired_on     date;
alter table paddock add column if not exists retired_reason text;

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_name='paddock' and column_name='active') then
    update paddock set retired_on = null where active;
    alter table paddock drop column active;
  end if;
end $$;

-- Names can be reused after retirement ("Back gully" splits into two,
-- one of which you later call "Back gully" again).
alter table paddock drop constraint if exists paddock_property_id_name_key;
create unique index if not exists paddock_name_live_uq
  on paddock (property_id, name) where retired_on is null;

-- ------------------------------------------------------------
-- 3. Lineage. Handles both directions:
--    split  = one parent, several children
--    merge  = several parents, one child
-- ------------------------------------------------------------

do $$
begin
  if not exists (select 1 from pg_type where typname='paddock_change_t') then
    create type paddock_change_t as enum ('split','merge','reshape','rename');
  end if;
end $$;

create table if not exists paddock_lineage (
  id          uuid primary key default gen_random_uuid(),
  parent_id   uuid not null references paddock(id) on delete restrict,
  child_id    uuid not null references paddock(id) on delete restrict,
  change      paddock_change_t not null,
  changed_on  date not null default current_date,
  notes       text,
  recorded_by uuid references farm_user(id) default auth.uid(),
  unique (parent_id, child_id)
);
create index if not exists paddock_lineage_parent_idx on paddock_lineage (parent_id);
create index if not exists paddock_lineage_child_idx  on paddock_lineage (child_id);

-- ------------------------------------------------------------
-- 4. Geometry history. Shifting a fence changes the area, which
--    changes every stocking rate you ever calculated for it.
--    Keep the old boundary so historical figures stay honest.
-- ------------------------------------------------------------

create table if not exists paddock_geometry_log (
  id          uuid primary key default gen_random_uuid(),
  paddock_id  uuid not null references paddock(id) on delete cascade,
  geometry    jsonb,
  area_ha     numeric(8,2),
  valid_from  timestamptz,
  valid_to    timestamptz not null default now(),
  changed_by  uuid references farm_user(id) default auth.uid()
);
create index if not exists paddock_geometry_log_idx on paddock_geometry_log (paddock_id, valid_to desc);

create or replace function log_paddock_geometry() returns trigger
language plpgsql security invoker set search_path = public as $$
begin
  if old.geometry is distinct from new.geometry then
    insert into paddock_geometry_log (paddock_id, geometry, area_ha, valid_from)
    values (old.id, old.geometry, old.area_ha, old.created_at);
  end if;
  return new;
end $$;

drop trigger if exists paddock_geometry_changed on paddock;
create trigger paddock_geometry_changed
  before update on paddock
  for each row execute function log_paddock_geometry();

-- ------------------------------------------------------------
-- 5. Splitting, as one atomic operation.
--
--    select split_paddock(
--      '<parent-uuid>',
--      '[{"name":"Back gully north","code":"BGN","colour":"#4F7A1F",
--         "geometry":{...},"area_ha":11.2},
--       {"name":"Back gully south","code":"BGS","colour":"#1F6FB2",
--         "geometry":{...},"area_ha":9.4}]'::jsonb,
--      '<uuid of the child that inherits current stock, or null>');
-- ------------------------------------------------------------

create or replace function split_paddock(p_parent uuid, p_children jsonb,
                              p_stock_to_index int default 0,
                              p_on date default current_date)
returns setof uuid language plpgsql security invoker set search_path = public as $$
declare
  c          jsonb;
  new_id     uuid;
  ids        uuid[] := '{}';
  parent_prop uuid;
  movers     uuid[];
begin
  if jsonb_array_length(p_children) < 2 then
    raise exception 'A split needs at least two new paddocks';
  end if;

  select property_id into parent_prop from paddock where id = p_parent;
  if not found then raise exception 'Parent paddock not found'; end if;

  -- Retire the parent first so its name is free for reuse.
  update paddock set retired_on = p_on,
         retired_reason = coalesce(retired_reason, 'Subdivided')
   where id = p_parent and retired_on is null;

  for c in select * from jsonb_array_elements(p_children) loop
    insert into paddock (property_id, name, code, colour, geometry, area_ha, notes)
    values (parent_prop, c->>'name', c->>'code',
            coalesce(c->>'colour', '#4F7A1F'), c->'geometry',
            (c->>'area_ha')::numeric, c->>'notes')
    returning id into new_id;

    insert into paddock_lineage (parent_id, child_id, change, changed_on)
    values (p_parent, new_id, 'split', p_on);

    ids := ids || new_id;
  end loop;

  -- Carry any stock currently in the parent into the nominated child.
  if p_stock_to_index is not null and p_stock_to_index < array_length(ids,1) then
    select array_agg(animal_id) into movers
      from paddock_stay where paddock_id = p_parent and moved_out is null;
    if movers is not null then
      perform move_animals(movers, ids[p_stock_to_index + 1], p_on, 'Paddock subdivided');
    end if;
  end if;

  return query select unnest(ids);
end $$;

-- ------------------------------------------------------------
-- 6. Rebuild the views for retired_on, and expose whether a
--    paddock can safely be deleted outright.
-- ------------------------------------------------------------

create view v_paddock_current with (security_invoker = on) as
select
  p.id, p.name, p.code, p.colour, p.geometry, p.area_ha, p.notes,
  p.sort_order, p.retired_on,
  count(s.animal_id)                                     as head,
  case when p.area_ha > 0
       then round(count(s.animal_id) / p.area_ha, 2) end as head_per_ha,
  min(s.moved_in)                                        as grazing_since,
  exists (select 1 from paddock_stay h where h.paddock_id = p.id)
    or exists (select 1 from paddock_lineage l
               where l.parent_id = p.id or l.child_id = p.id)    as has_history
from paddock p
left join paddock_stay s on s.paddock_id = p.id and s.moved_out is null
where p.retired_on is null
group by p.id;

-- Every paddock ever, for historical reporting.
create view v_paddock_all with (security_invoker = on) as
select p.id, p.name, p.code, p.colour, p.area_ha, p.retired_on, p.retired_reason,
       p.created_at::date as opened_on,
       (select string_agg(pp.name, ', ')
          from paddock_lineage l join paddock pp on pp.id = l.parent_id
         where l.child_id = p.id)  as replaced,
       (select string_agg(cp.name, ', ')
          from paddock_lineage l join paddock cp on cp.id = l.child_id
         where l.parent_id = p.id) as became
from paddock p;

-- ------------------------------------------------------------
-- 7. RLS for the new tables.
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['paddock_lineage','paddock_geometry_log'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists %I_read on %I', t, t);
    execute format('drop policy if exists %I_insert on %I', t, t);
    execute format('drop policy if exists %I_delete on %I', t, t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format($f$create policy %I_delete on %I for delete to authenticated using (my_role() = 'owner')$f$, t, t);
  end loop;
end $$;
