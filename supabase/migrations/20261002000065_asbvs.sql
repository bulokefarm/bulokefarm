-- ============================================================
-- 65. Breeding values from Sheep Genetics.
--
-- A stud that records with MERINOSELECT gets an ASBV for each trait,
-- each animal, every analysis run: a value and an accuracy. Toland
-- Merino records as flock 601082. The values arrive as a member
-- export from Sheep Genetics; there is no public API to pull from.
--
-- Sheep Genetics knows an animal by a sixteen-digit ID: the flock,
-- the drop year, then the six-digit tag. Toland's BU 230040, dropped
-- 2023, is 6010822023230040. A farm that records says so with its
-- flock number, and its sheep get that ID filled in from what is
-- already on file. The DOB of a Toland ewe is 1 June of her tag year,
-- so her drop year is right even though her birthday is not.
-- The derived ID is a guess until the first export confirms it: the
-- import matches by ID first, then by EID, then by tag, and writes
-- the ID it was given onto any animal it found another way.
--
-- One row per animal, trait and run, rather than a column per
-- trait: Sheep Genetics adds and renames traits and indexes (DP+,
-- MP+, the wool and carcase traits), and a new one needs no
-- migration. A later run never overwrites an earlier one;
-- v_asbv_latest reads the newest.
--
-- Not in the change log: a run is a file, and loading the file
-- again gives it back. Deleting the run deletes its values.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Who records, and as what
-- ------------------------------------------------------------

alter table farm add column if not exists sg_flock_id text;

do $$
begin
  alter table farm add constraint farm_sg_flock_id_ck check (sg_flock_id ~ '^\d{6}$');
exception when duplicate_object then null;
end $$;

comment on column farm.sg_flock_id is
  'The six digits Sheep Genetics (MERINOSELECT, LAMBPLAN) knows this flock by, the front of every animal''s Sheep Genetics ID. Null if the farm does not record.';

update farm set sg_flock_id = '601082' where slug = 'toland' and sg_flock_id is null;

alter table animal add column if not exists sg_id text;

do $$
begin
  alter table animal add constraint animal_sg_id_ck check (sg_id ~ '^[0-9A-Z]{16}$');
exception when duplicate_object then null;
end $$;

comment on column animal.sg_id is
  'Sheep Genetics ID: flock (6), drop year (4), tag (6). Filled from the farm''s flock number and the tag; an ASBV import overwrites it with the one Sheep Genetics sent.';

create unique index if not exists animal_sg_id_uq on animal (farm_id, sg_id) where sg_id is not null;

-- The values below name their animal and farm together, so a value
-- can never sit on one farm against another farm's sheep.
create unique index if not exists animal_farm_id_uq on animal (farm_id, id);

-- Fill in what can be worked out: a sheep of a recording farm, its
-- own (not a reference), with a six-digit tag and a date of birth.
update animal a
   set sg_id = f.sg_flock_id || extract(year from a.dob)::int || lpad(a.herd_number::text, 6, '0')
  from farm f
 where f.id = a.farm_id
   and f.sg_flock_id is not null
   and a.species = 'sheep'
   and a.origin <> 'reference'
   and a.sg_id is null
   and a.dob is not null
   and a.herd_number between 100000 and 999999
   and not exists (
     select 1 from animal o
      where o.farm_id = a.farm_id
        and o.sg_id = f.sg_flock_id || extract(year from a.dob)::int || lpad(a.herd_number::text, 6, '0'));

-- ------------------------------------------------------------
-- 2. A run: one analysis, one file
-- ------------------------------------------------------------

create table if not exists asbv_run (
  id           uuid primary key default gen_random_uuid(),
  farm_id      uuid not null default current_farm() references farm(id) on delete cascade,
  analysis_on  date not null,                -- the Sheep Genetics run date on the report
  source       text not null default 'MERINOSELECT',
  file_name    text,
  rows_in      int  not null default 0,      -- rows in the file
  matched      int  not null default 0,      -- rows that found an animal
  imported_by  uuid references farm_user(id) default auth.uid(),
  imported_at  timestamptz not null default now(),
  unique (farm_id, id)
);

create index if not exists asbv_run_farm_idx on asbv_run (farm_id, analysis_on desc);

comment on table asbv_run is
  'One Sheep Genetics analysis run as loaded from its export. Delete it and its values go with it.';

-- ------------------------------------------------------------
-- 3. The values
-- ------------------------------------------------------------

create table if not exists asbv (
  farm_id    uuid not null,
  run_id     uuid not null,
  animal_id  uuid not null,
  trait      text not null,                  -- as Sheep Genetics writes it: WWT, YCFW, DP+
  value      numeric(9,3) not null,
  accuracy   smallint check (accuracy between 0 and 100),
  primary key (run_id, animal_id, trait),
  foreign key (farm_id, run_id)    references asbv_run (farm_id, id) on delete cascade,
  foreign key (farm_id, animal_id) references animal   (farm_id, id) on delete cascade,
  constraint asbv_trait_ck check (trait ~ '^[A-Za-z0-9+_-]{1,16}$')
);

create index if not exists asbv_animal_idx on asbv (animal_id, trait);
create index if not exists asbv_farm_idx   on asbv (farm_id);

comment on table asbv is
  'An Australian Sheep Breeding Value: one trait of one animal in one run. Accuracy is the percent Sheep Genetics gives with it.';

-- Said out loud rather than left to default privileges (as in 53).
grant select, insert, update, delete on asbv_run to authenticated;
grant select, insert, update, delete on asbv     to authenticated;

alter table asbv_run enable row level security;
alter table asbv     enable row level security;

do $$
declare t text;
begin
  foreach t in array array['asbv_run', 'asbv'] loop
    execute format('drop policy if exists %I on %I', t || '_read',   t);
    execute format('drop policy if exists %I on %I', t || '_insert', t);
    execute format('drop policy if exists %I on %I', t || '_update', t);
    execute format('drop policy if exists %I on %I', t || '_delete', t);
    execute format($p$create policy %I on %I for select to authenticated
      using (farm_id = (select current_farm()) and can_read())$p$, t || '_read', t);
    execute format($p$create policy %I on %I for insert to authenticated
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_insert', t);
    execute format($p$create policy %I on %I for update to authenticated
      using      (farm_id = (select current_farm()) and can_write())
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_update', t);
    execute format($p$create policy %I on %I for delete to authenticated
      using (farm_id = (select current_farm()) and my_role() = 'owner')$p$, t || '_delete', t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 4. The newest value of each trait, per animal
-- ------------------------------------------------------------

create or replace view v_asbv_latest with (security_invoker = on) as
select distinct on (v.animal_id, v.trait)
  v.animal_id, v.trait, v.value, v.accuracy, r.analysis_on, r.id as run_id
from asbv v
join asbv_run r on r.id = v.run_id
order by v.animal_id, v.trait, r.analysis_on desc, r.imported_at desc;

grant select on v_asbv_latest to authenticated;

-- ------------------------------------------------------------
-- 5. Loading a run
--
-- p_rows is the file as JSON, one object per animal:
--   {"sg_id": "6010822023230040", "eid": "940 110012345678",
--    "values": {"WWT": [3.1, 72], "DP+": [155.2, 68], ...}}
-- each value a pair of ASBV and accuracy (accuracy may be null).
-- seed/tools/import_sg_asbv.py turns an export into this.
--
-- An animal is found by Sheep Genetics ID, then by EID, then by the
-- last six digits of the ID against a tag (or a reference animal of
-- that name, so old dams on file only as a name get theirs too). The
-- tag match only trusts an ID that starts with the farm's own flock
-- number, and for a sheep with a birthday, one whose drop year is
-- hers: an export carries outside sires, and another flock's 200400
-- is not our 200400. Two candidates is no match. Runs as the caller,
-- so it only ever sees and writes the caller's farm.
-- ------------------------------------------------------------

create or replace function import_asbv(
  p_analysis_on date,
  p_rows        jsonb,
  p_file_name   text default null,
  p_source      text default 'MERINOSELECT'
) returns jsonb
language plpgsql set search_path = public as $$
declare
  run       uuid;
  farm      uuid := current_farm();
  flock     text;
  n_rows    int;
  n_matched int;
  n_values  int;
  unmatched jsonb;
begin
  -- A signed-in caller must be able to write. Run from the SQL editor or a
  -- seed (no sign-in), the farm comes from app.farm, as the seeds name it.
  if auth.uid() is not null and not can_write() then
    raise exception 'Only an owner or manager can load breeding values'
      using errcode = 'insufficient_privilege';
  end if;
  if farm is null then
    raise exception 'No farm: sign in, or set app.farm to the farm id first';
  end if;
  if jsonb_typeof(p_rows) <> 'array' then
    raise exception 'p_rows must be a JSON array';
  end if;
  select f.sg_flock_id into flock from farm f where f.id = farm;

  insert into asbv_run (analysis_on, source, file_name)
  values (p_analysis_on, p_source, p_file_name)
  returning id into run;

  if to_regclass('pg_temp._sg') is not null then drop table _sg; end if;
  create temp table _sg on commit drop as
  select r.ord,
         nullif(upper(regexp_replace(r.row ->> 'sg_id', '[^0-9A-Za-z]', '', 'g')), '') as sg_id,
         nullif(regexp_replace(r.row ->> 'eid',   '\D', '', 'g'), '') as eid,
         r.row -> 'values' as vals,
         null::uuid as animal_id
    from jsonb_array_elements(p_rows) with ordinality as r(row, ord);

  -- 1. By Sheep Genetics ID
  update _sg s set animal_id = a.id
    from animal a
   where a.farm_id = farm and a.sg_id = s.sg_id;

  -- 2. By EID, spaces aside
  update _sg s set animal_id = m.id
    from (select s2.ord, min(a.id::text)::uuid as id, count(*) as n
            from _sg s2
            join animal a on a.farm_id = farm
                         and a.nlis_tag is not null
                         and regexp_replace(a.nlis_tag, '\D', '', 'g') = s2.eid
           where s2.animal_id is null and s2.eid is not null
           group by s2.ord) m
   where s.ord = m.ord and m.n = 1;

  -- 3. By tag: the last six digits of the ID
  update _sg s set animal_id = m.id
    from (select s2.ord, min(a.id::text)::uuid as id, count(*) as n
            from _sg s2
            join animal a on a.farm_id = farm
                         and a.species = 'sheep'
                         and ((a.origin <> 'reference' and a.herd_number = right(s2.sg_id, 6)::int
                               and (a.dob is null
                                    or extract(year from a.dob)::int = substr(s2.sg_id, 7, 4)::int))
                           or (a.origin =  'reference' and a.name = right(s2.sg_id, 6)))
           where s2.animal_id is null and s2.sg_id ~ '^\d{16}$'
             and left(s2.sg_id, 6) = flock
           group by s2.ord) m
   where s.ord = m.ord and m.n = 1;

  -- An animal found by EID or tag takes the ID Sheep Genetics gave it,
  -- unless another animal on the farm already holds it. One animal per
  -- ID, should the file name the same ID twice.
  update animal a set sg_id = s.sg_id
    from (select distinct on (sg_id) sg_id, animal_id
            from _sg
           where animal_id is not null and sg_id ~ '^[0-9A-Z]{16}$'
           order by sg_id, ord) s
   where a.id = s.animal_id
     and a.sg_id is distinct from s.sg_id
     and not exists (select 1 from animal o where o.farm_id = farm and o.sg_id = s.sg_id);

  insert into asbv (farm_id, run_id, animal_id, trait, value, accuracy)
  select distinct on (s.animal_id, upper(v.key))
         farm, run, s.animal_id, upper(v.key),
         (v.value ->> 0)::numeric,
         nullif(v.value ->> 1, '')::numeric::smallint
    from _sg s
    cross join lateral jsonb_each(s.vals) v
   where s.animal_id is not null
     and jsonb_typeof(v.value -> 0) = 'number'
   order by s.animal_id, upper(v.key), s.ord desc;
  get diagnostics n_values = row_count;

  select count(*), count(animal_id),
         coalesce(jsonb_agg(coalesce(sg_id, eid) order by ord) filter (where animal_id is null), '[]')
    into n_rows, n_matched, unmatched
    from _sg;

  update asbv_run set rows_in = n_rows, matched = n_matched where id = run;

  return jsonb_build_object(
    'run_id', run, 'rows', n_rows, 'matched', n_matched,
    'values', n_values, 'unmatched', unmatched);
end $$;

comment on function import_asbv is
  'Loads one Sheep Genetics run for the caller''s farm. Returns the run id, rows, matched, values written and the IDs it could not place.';

revoke execute on function import_asbv(date, jsonb, text, text) from public, anon;
grant  execute on function import_asbv(date, jsonb, text, text) to authenticated;

-- Check:
--   select sg_id, stock_code from animal where stock_code = 'BU 230040';
--     -- 6010822023230040
--   select import_asbv('2026-09-15',
--     '[{"sg_id":"6010822023230040","values":{"WWT":[3.1,72],"DP+":[155,68]}}]');
--   select * from v_asbv_latest;
