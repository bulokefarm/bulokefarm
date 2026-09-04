-- ============================================================
-- Buloke Farm — LPA Section 3B: crop, pasture and paddock treatment
-- Apply after 20260802000039_melbourne_time.sql.
-- Safe to run more than once.
--
-- The gap this fills: every chemical record in the database so far is
-- animal-facing. `treatment` is Section 2 — it hangs off a list of
-- animals and derives a slaughter clearance. Spraying a paddock has
-- no animals attached at the time and the withholding period that
-- matters is a GRAZING one, against the ground. Forcing it through
-- `treatment` would mean inventing an animal list and misreading the
-- withhold, so it gets its own pair of tables.
--
-- Two tables, not one, because a tank mix is one pass over the
-- paddock with two or three products in it, each with its own batch
-- number and its own withholding period. That is exactly how the LPA
-- template is laid out: one application header, product rows beneath.
--
-- Nothing here stores a "safe to graze" date. It is applied_on +
-- withhold per product, and the binding one is the latest across the
-- mix — arithmetic, so it is done in a view. A stored date would go
-- stale the moment someone corrected a withholding period.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The application: one pass over one piece of country.
-- ------------------------------------------------------------

create table if not exists spray_event (
  id                uuid primary key default gen_random_uuid(),
  applied_on        date not null,

  -- Where. A mapped paddock when there is one, free text when there
  -- isn't — spot spraying blackberry down a laneway or along a
  -- boundary is still a 3B record. Only the paddock case can drive
  -- the grazing guard, which is the honest trade-off for allowing
  -- the text case at all.
  paddock_id        uuid references paddock(id) on delete set null,
  paddock_desc      text,

  crop_treated      text,                      -- 'Pasture', 'Oats'
  area_ha           numeric(8,2) check (area_ha is null or area_ha > 0),
  water_rate_l_ha   numeric(8,2),              -- total spray volume, L/ha
  method            text,                      -- boom spray, spot spray, weed wiper

  -- Wind is the whole point of 3B. It is what proves the chemical
  -- went where it was aimed. Left nullable rather than enforced,
  -- because a NOT NULL here would block recording a pass you are
  -- writing up after the fact — the same call already made for batch
  -- numbers on `treatment`. The report names the gap instead.
  wind_direction    text,
  wind_speed_kmh    numeric(5,1) check (wind_speed_kmh is null or wind_speed_kmh >= 0),

  applied_by        text,                      -- contractor, or blank for you
  applied_by_contact text,
  notes             text,

  recorded_by       uuid references farm_user(id) default auth.uid(),
  created_at        timestamptz not null default now(),

  -- A treatment record that does not say where is not a record.
  constraint spray_event_has_a_place
    check (paddock_id is not null or paddock_desc is not null)
);

create index if not exists spray_event_paddock_idx
  on spray_event (paddock_id, applied_on desc);
create index if not exists spray_event_date_idx
  on spray_event (applied_on desc);

comment on table spray_event is
  'LPA Section 3B — one application of chemical to a paddock or crop.';
comment on column spray_event.water_rate_l_ha is
  'Total spray volume per hectare. The chemical rate lives on each product.';
comment on column spray_event.paddock_desc is
  'Where, when it is not a mapped paddock. No grazing guard applies to these.';

-- ------------------------------------------------------------
-- 2. The products in the tank.
--
-- Three withholding figures, because they are three different
-- questions and a herbicide label answers them separately:
--   graze   — when stock may go back on
--   harvest — when it may be cut for hay or silage
--   ESI     — export slaughter interval, if the label carries one
-- ------------------------------------------------------------

create table if not exists spray_product (
  id                    uuid primary key default gen_random_uuid(),
  spray_event_id        uuid not null references spray_event(id) on delete cascade,

  product_name          text not null,         -- 'Nufarm MCPA Amine 750'
  active_ingredient     text,                  -- '750 g/L MCPA present as the dimethylamine salt'
  chemical_rate         text,                  -- as written: '1 L/ha'
  batch_number          text,                  -- off the drum — the field an auditor chases

  graze_withhold_days   int check (graze_withhold_days   is null or graze_withhold_days   >= 0),
  harvest_withhold_days int check (harvest_withhold_days is null or harvest_withhold_days >= 0),
  esi_days              int check (esi_days              is null or esi_days              >= 0),

  notes                 text,
  created_at            timestamptz not null default now()
);

create index if not exists spray_product_event_idx
  on spray_product (spray_event_id);

comment on table spray_product is
  'One product in one pass. A tank mix is several rows against one spray_event.';
comment on column spray_product.graze_withhold_days is
  'Label days before stock may graze. NULL means unknown, which is NOT the same as zero.';

-- ------------------------------------------------------------
-- 3. Row level security and the change log, same terms as the rest.
-- ------------------------------------------------------------

alter table spray_event   enable row level security;
alter table spray_product enable row level security;

do $$
declare t text;
begin
  foreach t in array array['spray_event','spray_product'] loop
    execute format('drop policy if exists %I_read   on %I', t, t);
    execute format('drop policy if exists %I_insert on %I', t, t);
    execute format('drop policy if exists %I_update on %I', t, t);
    execute format('drop policy if exists %I_delete on %I', t, t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format('create policy %I_delete on %I for delete to authenticated using (my_role() = ''owner'')', t, t);

    execute format('drop trigger if exists %I_changed on %I', t, t);
    execute format('create trigger %I_changed after update or delete on %I
                    for each row execute function log_record_change()', t, t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 4. The report view: one row per product, event details carried.
--
-- Left join, so an application recorded with no product yet still
-- appears — as an obviously incomplete record rather than as nothing
-- at all.
-- ------------------------------------------------------------

drop view if exists v_spray_report;

create view v_spray_report with (security_invoker = on) as
select
  se.id                                    as event_id,
  sp.id                                    as product_id,
  se.applied_on,
  se.paddock_id,
  p.name                                   as paddock_name,
  p.colour                                 as paddock_colour,
  coalesce(p.name, se.paddock_desc)        as place,
  p.area_ha                                as paddock_area_ha,
  se.crop_treated,
  se.area_ha,
  se.water_rate_l_ha,
  se.method,
  se.wind_direction,
  se.wind_speed_kmh,
  se.applied_by,
  se.applied_by_contact,
  coalesce(se.applied_by, u.display_name)      as applied_by_shown,
  coalesce(se.applied_by_contact, u.phone)     as contact_shown,
  se.notes                                 as event_notes,

  sp.product_name,
  sp.active_ingredient,
  sp.chemical_rate,
  sp.batch_number,
  sp.graze_withhold_days,
  sp.harvest_withhold_days,
  sp.esi_days,
  sp.notes                                 as product_notes,

  -- Derived, never stored. NULL when the withhold is unknown, which
  -- reads on the report as a gap rather than as "safe today".
  (se.applied_on + sp.graze_withhold_days)   as safe_to_graze,
  (se.applied_on + sp.harvest_withhold_days) as safe_to_harvest,
  (se.applied_on + sp.graze_withhold_days) > farm_today() as graze_withheld,

  (select count(*) from record_change_log l
    where l.table_name = 'spray_event'   and l.row_id = se.id) as event_edits,
  (select count(*) from record_change_log l
    where l.table_name = 'spray_product' and l.row_id = sp.id) as product_edits
from spray_event se
left join spray_product sp on sp.spray_event_id = se.id
left join paddock       p  on p.id = se.paddock_id
left join farm_user     u  on u.id = se.recorded_by;

-- ------------------------------------------------------------
-- 5. Which paddocks are currently under a grazing withhold.
--
-- The 60-day window on unknowns needs saying out loud: a product
-- with no withholding period on file cannot be cleared by
-- arithmetic, so it can't be aged out honestly either. Sixty days
-- covers every common pasture herbicide's grazing withhold with room
-- to spare, and is short enough that one unfilled record from last
-- season doesn't lock a paddock forever. Fill the days in and the
-- paddock clears properly on the real date.
-- ------------------------------------------------------------

drop view if exists v_paddock_withhold;

create view v_paddock_withhold with (security_invoker = on) as
with binding as (
  select
    se.paddock_id,
    se.applied_on,
    sp.product_name,
    se.applied_on + sp.graze_withhold_days as clears_on,
    (sp.graze_withhold_days is null)       as unknown
  from spray_event se
  join spray_product sp on sp.spray_event_id = se.id
  where se.paddock_id is not null
    and ( se.applied_on + sp.graze_withhold_days > farm_today()
       or (sp.graze_withhold_days is null and se.applied_on > farm_today() - 60) )
)
select
  b.paddock_id,
  p.name                                    as paddock_name,
  max(b.applied_on)                         as last_sprayed,
  -- max() skips NULLs, so a mix of a known 7-day and an unrecorded
  -- one gives the 7-day date AND raises the unknown flag. Both are
  -- true and both need showing.
  max(b.clears_on)                          as safe_to_graze,
  bool_or(b.unknown)                        as withhold_unknown,
  string_agg(distinct b.product_name, ', ') as products
from binding b
join paddock p on p.id = b.paddock_id
group by b.paddock_id, p.name;

comment on view v_paddock_withhold is
  'Paddocks stock should not be grazing yet. Empty is the normal state.';

-- ------------------------------------------------------------
-- 6. The guard.
--
-- A record that only prints is a second spreadsheet. This is the
-- part that earns the table: putting stock into a paddock inside its
-- grazing withhold is refused, with the reason, and can be overridden
-- deliberately — the override is written onto the stay so there is a
-- trail either way.
-- ------------------------------------------------------------

create or replace function paddock_graze_block(p_paddock_id uuid, p_on date default farm_today())
returns text language sql stable set search_path = public as $$
  select case when count(*) = 0 then null else
    format('%s was sprayed with %s on %s. %s',
      max(p.name),
      string_agg(distinct sp.product_name, ', '),
      to_char(max(se.applied_on), 'DD Mon YYYY'),
      case when bool_or(sp.graze_withhold_days is null)
           then 'No grazing withholding period is recorded against it.'
           else 'Grazing is withheld until '
                || to_char(max(se.applied_on + sp.graze_withhold_days), 'DD Mon YYYY') || '.'
      end)
  end
  from spray_event se
  join spray_product sp on sp.spray_event_id = se.id
  join paddock       p  on p.id = se.paddock_id
  where se.paddock_id = p_paddock_id
    and se.applied_on <= p_on
    and ( se.applied_on + sp.graze_withhold_days > p_on
       or (sp.graze_withhold_days is null and se.applied_on > p_on - 60) )
$$;

comment on function paddock_graze_block(uuid, date) is
  'Why stock should not go into this paddock on this date, or NULL if they can.';

-- The old four-argument form must be DROPPED, not left alongside.
-- Adding a fifth argument with a default creates a second function,
-- and a four-argument call then matches both — Postgres refuses it as
-- ambiguous rather than picking one. Dropping first is the only way
-- to change an argument list.
drop function if exists move_animals(uuid[], uuid, date, text);
drop function if exists move_animals(uuid[], uuid, date, text, boolean);

create function move_animals(p_animal_ids uuid[], p_paddock_id uuid,
                             p_on date default farm_today(),
                             p_reason text default null,
                             p_ignore_withhold boolean default false)
returns int language plpgsql security invoker set search_path = public as $$
declare
  n       int;
  blocked text;
begin
  blocked := paddock_graze_block(p_paddock_id, p_on);

  if blocked is not null and not p_ignore_withhold then
    raise exception 'Spray withholding period. %', blocked
      using errcode = 'BF001',
            hint    = 'Call again with p_ignore_withhold => true to move them anyway.';
  end if;

  -- An override is a decision, so it goes on the record next to the
  -- reason someone typed, not into a log nobody reads.
  if blocked is not null then
    p_reason := trim(both ' ' from coalesce(p_reason, '') ||
                     ' [moved inside spray withholding period]');
  end if;

  update paddock_stay set moved_out = p_on
   where animal_id = any(p_animal_ids) and moved_out is null and moved_in <= p_on;

  insert into paddock_stay (animal_id, paddock_id, moved_in, reason)
  select unnest(p_animal_ids), p_paddock_id, p_on, p_reason;

  get diagnostics n = row_count;
  return n;
end $$;

comment on function move_animals(uuid[], uuid, date, text, boolean) is
  'Move stock, closing the old stay. Refuses a paddock under a spray grazing withhold unless overridden.';

-- ------------------------------------------------------------
-- 7. Verification, once applied:
--
--   select * from v_paddock_withhold;         -- empty until something is sprayed
--   select paddock_graze_block(<paddock>);    -- NULL means clear
--
-- And the guard, end to end — spray a paddock 7 days out, then try
-- to move something in:
--
--   select move_animals(array[<animal>]::uuid[], <paddock>);
--   ERROR:  Spray withholding period. Home Paddock was sprayed with ...
-- ------------------------------------------------------------

notify pgrst, 'reload schema';
