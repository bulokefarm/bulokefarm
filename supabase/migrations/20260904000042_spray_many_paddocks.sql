-- ============================================================
-- Buloke Farm — one pass, many paddocks
-- Apply after 20260904000041_spray_needs_a_paddock.sql.
-- Safe to run more than once.
--
-- 40 and 41 modelled an application as one paddock. That is wrong for
-- the way the job is done: a boom run crosses three paddocks in an
-- afternoon on one tank, one wind reading, one batch number. Recorded
-- as three events it becomes three chances to type the batch number
-- differently, and correcting the wind afterwards means finding all
-- three.
--
-- So `spray_paddock` joins them, the same shape as
-- `treatment_animal` and `consignment_animal`. Area and the location
-- note move onto it, because they are facts about a paddock and not
-- about the pass — 8 ha of one and 0.3 ha along the fence of another
-- is one run.
--
-- What this costs: NOT NULL on paddock_id went away with the column,
-- and a join table cannot enforce "at least one" the way a column
-- can. `record_spray()` below is the answer — it writes the pass and
-- its paddocks in one transaction and refuses an empty list. Rows
-- written any other way are named on the report instead.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The join.
-- ------------------------------------------------------------

create table if not exists spray_paddock (
  spray_event_id uuid not null references spray_event(id) on delete cascade,
  paddock_id     uuid not null references paddock(id)     on delete restrict,

  -- What was actually covered here. Defaults to the paddock's mapped
  -- area, which is right for a boom run and wrong for spot spraying a
  -- fenceline, so it stays editable.
  area_ha        numeric(8,2) check (area_ha is null or area_ha > 0),
  location_note  text,

  primary key (spray_event_id, paddock_id)
);

create index if not exists spray_paddock_paddock_idx
  on spray_paddock (paddock_id);

comment on table spray_paddock is
  'Which paddocks one pass covered. Area is per paddock, not per pass.';

-- ------------------------------------------------------------
-- 2. Move what is already on file across, then drop the columns.
--
-- The backfill is keyed on the event rather than on values, so a
-- second run finds the rows already there and writes nothing.
-- ------------------------------------------------------------

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema='public' and table_name='spray_event'
                and column_name='paddock_id')
  then
    insert into spray_paddock (spray_event_id, paddock_id, area_ha, location_note)
    select se.id, se.paddock_id, se.area_ha, se.location_note
      from spray_event se
     where se.paddock_id is not null
       and not exists (select 1 from spray_paddock sp where sp.spray_event_id = se.id);

    raise notice 'moved % application(s) onto spray_paddock',
      (select count(*) from spray_paddock);

    -- Views reading these columns must go before the columns do.
    drop view if exists v_spray_report;
    drop view if exists v_paddock_withhold;

    alter table spray_event drop column paddock_id;
    alter table spray_event drop column area_ha;
    alter table spray_event drop column location_note;
  end if;
end $$;

-- ------------------------------------------------------------
-- 3. Same terms as everything else.
-- ------------------------------------------------------------

alter table spray_paddock enable row level security;

drop policy if exists spray_paddock_read   on spray_paddock;
drop policy if exists spray_paddock_insert on spray_paddock;
drop policy if exists spray_paddock_update on spray_paddock;
drop policy if exists spray_paddock_delete on spray_paddock;
create policy spray_paddock_read   on spray_paddock for select to authenticated using (can_read());
create policy spray_paddock_insert on spray_paddock for insert to authenticated with check (can_write());
create policy spray_paddock_update on spray_paddock for update to authenticated using (can_write()) with check (can_write());
create policy spray_paddock_delete on spray_paddock for delete to authenticated using (can_write());

-- Deleting a paddock off a pass is a correction, not a destruction of
-- the record, so managers may do it — unlike deleting the pass itself.

-- ------------------------------------------------------------
-- 4. The report: one line per paddock per product.
--
-- Three paddocks and two products is six lines, which looks like
-- duplication until you read one: "this product, on this paddock, on
-- this date, clear on this date". That is the line an auditor wants
-- and the areas and clearance dates genuinely differ across it.
-- ------------------------------------------------------------

drop view if exists v_spray_report;

create view v_spray_report with (security_invoker = on) as
select
  se.id                                    as event_id,
  sp.id                                    as product_id,
  pk.paddock_id,
  se.applied_on,
  p.name                                   as paddock_name,
  p.colour                                 as paddock_colour,
  p.name                                   as place,
  pk.location_note,
  p.area_ha                                as paddock_area_ha,
  pk.area_ha,
  se.crop_treated,
  se.water_rate_l_ha,
  se.method,
  se.wind_direction,
  se.wind_speed_kmh,
  se.applied_by,
  se.applied_by_contact,
  coalesce(se.applied_by, u.display_name)      as applied_by_shown,
  coalesce(se.applied_by_contact, u.phone)     as contact_shown,
  se.notes                                 as event_notes,

  -- So one line can say how much of the pass it represents.
  (select count(*) from spray_paddock x where x.spray_event_id = se.id) as paddocks_on_pass,

  sp.product_name,
  sp.active_ingredient,
  sp.chemical_rate,
  sp.batch_number,
  sp.graze_withhold_days,
  sp.harvest_withhold_days,
  sp.esi_days,
  sp.notes                                 as product_notes,

  (se.applied_on + sp.graze_withhold_days)   as safe_to_graze,
  (se.applied_on + sp.harvest_withhold_days) as safe_to_harvest,
  (se.applied_on + sp.graze_withhold_days) > farm_today() as graze_withheld,

  (select count(*) from record_change_log l
    where l.table_name = 'spray_event'   and l.row_id = se.id) as event_edits,
  (select count(*) from record_change_log l
    where l.table_name = 'spray_product' and l.row_id = sp.id) as product_edits
from spray_event se
left join spray_paddock pk on pk.spray_event_id = se.id
left join paddock       p  on p.id = pk.paddock_id
left join spray_product sp on sp.spray_event_id = se.id
left join farm_user     u  on u.id = se.recorded_by;

-- ------------------------------------------------------------
-- 5. Withhold and guard, now reading through the join.
-- ------------------------------------------------------------

drop view if exists v_paddock_withhold;

create view v_paddock_withhold with (security_invoker = on) as
with binding as (
  select
    pk.paddock_id,
    se.applied_on,
    sp.product_name,
    se.applied_on + sp.graze_withhold_days as clears_on,
    (sp.graze_withhold_days is null)       as unknown
  from spray_event   se
  join spray_paddock pk on pk.spray_event_id = se.id
  join spray_product sp on sp.spray_event_id = se.id
  where se.applied_on + sp.graze_withhold_days > farm_today()
     or (sp.graze_withhold_days is null and se.applied_on > farm_today() - 60)
)
select
  b.paddock_id,
  p.name                                    as paddock_name,
  max(b.applied_on)                         as last_sprayed,
  max(b.clears_on)                          as safe_to_graze,
  bool_or(b.unknown)                        as withhold_unknown,
  string_agg(distinct b.product_name, ', ') as products
from binding b
join paddock p on p.id = b.paddock_id
group by b.paddock_id, p.name;

create or replace function paddock_graze_block(p_paddock_id uuid, p_on date default farm_today())
returns text language sql stable set search_path = public as $$
  select case when count(*) = 0 then null else
    -- A mix can carry a known withhold AND a product nobody wrote one
    -- down for. Both are true, so both are said: the known date is not
    -- a clearance while an unrecorded product sits beside it.
    format('%s was sprayed with %s on %s.%s%s',
      max(p.name),
      string_agg(distinct sp.product_name, ', '),
      to_char(max(se.applied_on), 'DD Mon YYYY'),
      case when max(se.applied_on + sp.graze_withhold_days) is not null
           then ' Grazing is withheld until '
                || to_char(max(se.applied_on + sp.graze_withhold_days), 'DD Mon YYYY') || '.'
           else '' end,
      case when bool_or(sp.graze_withhold_days is null)
           then ' One of the products has no grazing withholding period recorded.'
           else '' end)
  end
  from spray_event   se
  join spray_paddock pk on pk.spray_event_id = se.id
  join spray_product sp on sp.spray_event_id = se.id
  join paddock       p  on p.id = pk.paddock_id
  where pk.paddock_id = p_paddock_id
    and se.applied_on <= p_on
    and ( se.applied_on + sp.graze_withhold_days > p_on
       or (sp.graze_withhold_days is null and se.applied_on > p_on - 60) )
$$;

-- ------------------------------------------------------------
-- 6. Writing a pass in one go.
--
-- Three tables now, and the browser can only send one statement at a
-- time — so an application, its paddocks and its products could
-- previously half-save, and the operator would be told it failed and
-- enter the whole thing twice. One function, one transaction, and the
-- empty-paddock case is refused rather than described afterwards.
--
-- Products are allowed to be empty here, because the records page
-- deliberately creates the pass first and walks straight into the
-- product form. A pass with nothing in the tank is flagged on the
-- report; a pass over no paddocks is invisible to the grazing guard,
-- which is why only that one is refused.
--
--   select record_spray(
--     '2026-09-04',
--     '[{"paddock_id":"…","area_ha":12.4},{"paddock_id":"…"}]'::jsonb,
--     '[{"product_name":"Nufarm MCPA Amine 750","chemical_rate":"1 L/ha",
--        "batch_number":"N7742231","graze_withhold_days":7}]'::jsonb,
--     p_method => 'Boom spray', p_wind_direction => 'N', p_wind_speed_kmh => 12);
-- ------------------------------------------------------------

create or replace function record_spray(
  p_applied_on          date,
  p_paddocks            jsonb,
  p_products            jsonb default '[]'::jsonb,
  p_crop_treated        text    default null,
  p_water_rate_l_ha     numeric default null,
  p_method              text    default null,
  p_wind_direction      text    default null,
  p_wind_speed_kmh      numeric default null,
  p_applied_by          text    default null,
  p_applied_by_contact  text    default null,
  p_notes               text    default null
) returns uuid
language plpgsql security invoker set search_path = public as $$
declare
  ev uuid;
  n  int;
begin
  if p_paddocks is null or jsonb_array_length(p_paddocks) = 0 then
    raise exception 'A spray record must name at least one paddock.'
      using errcode = 'BF002';
  end if;

  insert into spray_event (applied_on, crop_treated, water_rate_l_ha, method,
                           wind_direction, wind_speed_kmh,
                           applied_by, applied_by_contact, notes)
  values (p_applied_on, p_crop_treated, p_water_rate_l_ha, p_method,
          p_wind_direction, p_wind_speed_kmh,
          p_applied_by, p_applied_by_contact, p_notes)
  returning id into ev;

  -- An area not given falls back to the paddock's mapped hectares,
  -- which is the whole-paddock case and the common one. Nothing is
  -- invented: if the paddock has no boundary yet it stays null and
  -- the report says so.
  insert into spray_paddock (spray_event_id, paddock_id, area_ha, location_note)
  select ev, x.paddock_id, coalesce(x.area_ha, p.area_ha), x.location_note
    from jsonb_to_recordset(p_paddocks)
           as x(paddock_id uuid, area_ha numeric, location_note text)
    join paddock p on p.id = x.paddock_id
  on conflict (spray_event_id, paddock_id) do nothing;

  get diagnostics n = row_count;

  -- The join above silently writes nothing for an id that is not a
  -- paddock, so the length check at the top can pass and still leave
  -- the pass covering nowhere. Count what actually landed. Raising
  -- rolls the whole function back, event included.
  if n = 0 then
    raise exception 'None of those paddocks exist.'
      using errcode = 'BF002';
  end if;

  if coalesce(jsonb_array_length(p_products), 0) > 0 then
    insert into spray_product (spray_event_id, product_name, active_ingredient,
                               chemical_rate, batch_number, graze_withhold_days,
                               harvest_withhold_days, esi_days, notes)
    select ev, y.product_name, y.active_ingredient, y.chemical_rate, y.batch_number,
           y.graze_withhold_days, y.harvest_withhold_days, y.esi_days, y.notes
      from jsonb_to_recordset(p_products)
             as y(product_name text, active_ingredient text, chemical_rate text,
                  batch_number text, graze_withhold_days int,
                  harvest_withhold_days int, esi_days int, notes text)
     where coalesce(trim(y.product_name), '') <> '';
  end if;

  return ev;
end $$;

comment on function record_spray is
  'Write one spray pass, its paddocks and its products in a single transaction.';

-- ------------------------------------------------------------
-- 7. Verification:
--
--   select * from v_spray_report order by applied_on;
--   select * from v_paddock_withhold;
--   select record_spray(farm_today(), '[]'::jsonb);   -- refused
-- ------------------------------------------------------------

notify pgrst, 'reload schema';
