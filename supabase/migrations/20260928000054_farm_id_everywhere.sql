-- ============================================================
-- 54. farm_id on every table.
--
-- Added nullable, backfilled to Buloke, then made not null, indexed,
-- and given a way to fill itself so that no page ever has to send
-- it. The policies do not look at the column until 55, so after this
-- the app behaves exactly as it did.
--
-- Two kinds of table:
--
--   Root tables default farm_id from current_farm(): the session's
--   farm for a signed-in user, the app.farm setting for a script.
--
--   Child tables take farm_id from their parent by trigger, before
--   insert or update, whatever the client sent. The trigger runs as
--   the caller, so its lookup is under RLS: a row pointing at another
--   farm's parent finds nothing and is refused by name. That matters
--   because foreign-key checks run as the table owner and bypass
--   RLS — without this, a user holding one of Buloke's uuids could
--   hang a treatment on Buloke's cow from their own farm.
--
-- Uniqueness that was really "one per database" becomes one per
-- farm: stock codes, NLIS tags, NVD serials, lineage names, the
-- address book of PICs, and above all *which PIC is primary* — that
-- index said one primary in the whole database, and would have
-- refused the second farm's.
--
-- The seeds: they run as postgres, where current_farm() has no
-- membership to consult, so each one now starts with
--   select set_config('app.farm', (select id::text from farm where slug='buloke'), false);
-- and property/heritage upserts name (farm_id, pic) and
-- (farm_id, name) as their conflict target.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The trigger: every link a row makes must be to this farm
--
-- Arguments come in pairs: a scoped table, and the column holding
-- one of its ids. Every non-null one is looked up. A linked row that
-- is not visible is an error, not a null; two linked rows on
-- different farms is an error. The row's farm is the farm they all
-- share; a row that links to nothing takes the session's farm.
--
-- Every pair is checked, not just the first. treatment_animal names
-- a treatment *and* an animal: the treatment being ours says nothing
-- about the cow, and a row hung on another farm's cow through our
-- own treatment is exactly the leak this exists to stop.
-- ------------------------------------------------------------

create or replace function farm_id_from_parent() returns trigger
language plpgsql set search_path = public as $$   -- invoker: the lookups are under RLS
declare
  i   int := 0;
  ref uuid;
  f   uuid;
  found_farm uuid;
begin
  while i < tg_nargs loop
    ref := (to_jsonb(new) ->> tg_argv[i + 1])::uuid;
    if ref is not null then
      execute format('select farm_id from %I where id = $1', tg_argv[i])
         into f using ref;
      if f is null then
        raise exception 'No % on this farm for %', tg_argv[i], tg_argv[i + 1]
          using errcode = 'foreign_key_violation';
      end if;
      if found_farm is not null and f <> found_farm then
        raise exception '% belongs to another farm', tg_argv[i + 1]
          using errcode = 'foreign_key_violation';
      end if;
      found_farm := f;
    end if;
    i := i + 2;
  end loop;

  new.farm_id := coalesce(found_farm, new.farm_id, current_farm());
  if new.farm_id is null then
    raise exception 'No farm for this %', tg_table_name;
  end if;
  return new;
end $$;

revoke execute on function farm_id_from_parent() from public, anon, authenticated;

-- ------------------------------------------------------------
-- 2. Which tables, and where the value comes from
-- ------------------------------------------------------------

do $$
declare
  buloke uuid := (select id from farm where slug = 'buloke');
  roots  text[] := array[
    'property', 'heritage', 'animal', 'paddock', 'treatment', 'feed_source',
    'consignment', 'shearing', 'ai_semen', 'embryo', 'spray_event'
  ];
  -- table => every scoped table it links to, as (table, column) pairs.
  -- Children take their farm from these; roots have a default as well,
  -- and are listed so that their links are checked too — a calf's dam,
  -- a paddock's PIC, a straw's bull.
  kids   jsonb := '{
    "animal":               ["animal", "dam_id", "animal", "sire_id", "property", "property_id",
                             "property", "origin_property_id", "heritage", "heritage_id"],
    "paddock":              ["property", "property_id"],
    "ai_semen":             ["animal", "sire_id"],
    "embryo":               ["animal", "donor_id", "animal", "sire_id"],
    "animal_status":        ["animal", "animal_id"],
    "weight_event":         ["animal", "animal_id"],
    "joining":              ["animal", "dam_id", "animal", "sire_id", "ai_semen", "ai_semen_id", "paddock", "paddock_id"],
    "calving":              ["animal", "dam_id", "joining", "joining_id", "animal", "calf_id"],
    "expected_calving":     ["animal", "dam_id", "joining", "joining_id", "animal", "sire_id"],
    "planned_joining":      ["animal", "dam_id", "animal", "sire_id", "ai_semen", "ai_semen_id",
                             "paddock", "paddock_id", "joining", "joining_id"],
    "treatment_animal":     ["treatment", "treatment_id", "animal", "animal_id"],
    "consignment_animal":   ["consignment", "consignment_id", "animal", "animal_id"],
    "shearing_animal":      ["shearing", "shearing_id", "animal", "animal_id"],
    "paddock_stay":         ["paddock", "paddock_id", "animal", "animal_id"],
    "paddock_lineage":      ["paddock", "parent_id", "paddock", "child_id"],
    "paddock_geometry_log": ["paddock", "paddock_id"],
    "feed_event":           ["feed_source", "feed_source_id", "paddock", "paddock_id"],
    "feed_adjustment":      ["feed_source", "feed_source_id"],
    "feed_event_animal":    ["feed_event", "feed_event_id", "animal", "animal_id"],
    "feed_event_ref":       ["feed_event", "feed_event_id"],
    "spray_product":        ["spray_event", "spray_event_id"],
    "spray_paddock":        ["spray_event", "spray_event_id", "paddock", "paddock_id"],
    "cryo_txn":             ["ai_semen", "ai_semen_id", "embryo", "embryo_id", "animal", "female_id", "joining", "joining_id"]
  }'::jsonb;
  t     text;
  args  text;
begin
  if buloke is null then
    raise exception 'Run 53 first: no farm with slug buloke';
  end if;

  -- Column, backfill, not null, index — every table alike.
  --
  -- The backfill runs with the row triggers off. Otherwise every
  -- audited table logs "farm_id: null → Buloke" for every row it has
  -- — 824 change-log entries on the first run — and the reports that
  -- show when a record last changed would all say today. The column
  -- is bookkeeping, not a correction, and the log is for corrections.
  for t in select unnest(roots) union select jsonb_object_keys(kids) union select 'record_change_log' loop
    execute format('alter table %I add column if not exists farm_id uuid references farm(id)', t);
    execute format('alter table %I disable trigger user', t);
    execute format('update %I set farm_id = $1 where farm_id is null', t) using buloke;
    execute format('alter table %I enable trigger user', t);
    execute format('alter table %I alter column farm_id set not null', t);
    execute format('create index if not exists %I on %I (farm_id)', t || '_farm_idx', t);
  end loop;

  -- Roots: the session's farm.
  foreach t in array roots loop
    execute format('alter table %I alter column farm_id set default current_farm()', t);
  end loop;

  -- Children: the parent's farm, before insert or update.
  for t in select jsonb_object_keys(kids) loop
    select string_agg(quote_literal(x), ', ') into args
      from jsonb_array_elements_text(kids -> t) x;
    execute format('drop trigger if exists %I on %I', t || '_farm', t);
    execute format(
      'create trigger %I before insert or update on %I for each row execute function farm_id_from_parent(%s)',
      t || '_farm', t, args);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 3. The change log carries the farm of the row it logged
--
-- log_record_change() runs as owner, so it cannot lean on the
-- session; it takes farm_id off the row. Every audited table has one
-- after section 2. The default is a net for a table that does not.
-- ------------------------------------------------------------

alter table record_change_log alter column farm_id set default current_farm();

create or replace function log_record_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' then
    if to_jsonb(old) - 'created_at' = to_jsonb(new) - 'created_at' then
      return new;
    end if;
    insert into record_change_log (table_name, row_id, action, old_row, new_row, farm_id)
    values (tg_table_name, old.id, 'update', to_jsonb(old), to_jsonb(new),
            coalesce((to_jsonb(old) ->> 'farm_id')::uuid, current_farm()));
    return new;
  else
    insert into record_change_log (table_name, row_id, action, old_row, farm_id)
    values (tg_table_name, old.id, 'delete', to_jsonb(old),
            coalesce((to_jsonb(old) ->> 'farm_id')::uuid, current_farm()));
    return old;
  end if;
end $$;

-- ------------------------------------------------------------
-- 4. One per farm, not one per database
-- ------------------------------------------------------------

-- Lineages: two farms can both have a Garratt line.
alter table heritage drop constraint if exists heritage_name_key;
create unique index if not exists heritage_farm_name_uq on heritage (farm_id, name);

-- The address book: two farms can both sell to the same abattoir PIC.
alter table property drop constraint if exists property_pic_key;
create unique index if not exists property_farm_pic_uq on property (farm_id, pic);

-- Stock codes: R 97 on both farms.
drop index if exists animal_stock_code_resident_uq;
create unique index if not exists animal_stock_code_resident_uq
  on animal (farm_id, species, stock_code)
  where origin <> 'reference' and stock_code is not null;

-- NLIS tags: an animal sold from one farm on the app to another is
-- legitimately on both.
drop index if exists animal_nlis_uq;
create unique index if not exists animal_nlis_uq
  on animal (farm_id, nlis_tag) where nlis_tag is not null;

-- NVD books are per business.
drop index if exists consignment_nvd_uq;
create unique index if not exists consignment_nvd_uq
  on consignment (farm_id, nvd_serial) where nvd_serial is not null;

-- The one that mattered: one primary PIC *per farm*. Richard's and
-- Dad's PICs are both is_own under Buloke; exactly one is primary
-- there, and Toland gets a primary of their own.
drop index if exists property_one_primary;
create unique index if not exists property_one_primary
  on property (farm_id) where is_primary;

comment on column property.is_primary is
  'The registration this farm itself trades under. Drives page letterheads and where new paddocks are attached. Exactly one per farm.';

-- Left alone, already per farm through their keys: paddock_name_live_uq
-- (property_id, name), paddock_stay_one_current, the joining and
-- expected_calving uniques.

notify pgrst, 'reload schema';
