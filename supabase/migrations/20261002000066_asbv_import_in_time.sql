-- ============================================================
-- 66. Loading breeding values in time.
--
-- Toland's first results file (21 Sep 2026: 505 animals on file,
-- 36,712 values) was refused by production with "canceling statement
-- due to statement timeout". Nothing was kept.
--
-- import_asbv (65) runs as the caller, so the row rules apply to
-- every row it reads and writes. The rules call can_read() and
-- can_write() bare, and Postgres runs a bare call once a ROW: about
-- 0.8 ms each on production (515 Toland animals read in 0.43 s).
-- 36,712 inserts is half a minute of rule checks against the 8 s
-- limit on a signed-in request.
--
-- Written as (select can_write()), the same call is run once a
-- STATEMENT and its answer used for every row. Nothing about who may
-- do what changes: same functions, same farm, same roles. Only how
-- often the question is asked. The rules below are the ones 65 wrote
-- for asbv and asbv_run, and the read and update rules on animal the
-- import goes through; their other conditions are kept as they are.
--
-- import_asbv also analyzes its scratch table, so the planner joins
-- 505 rows by hash rather than looping over them.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The rules, asked once a statement
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['asbv_run', 'asbv'] loop
    execute format($p$alter policy %I on %I
      using (farm_id = (select current_farm()) and (select can_read()))$p$, t || '_read', t);
    execute format($p$alter policy %I on %I
      with check (farm_id = (select current_farm()) and (select can_write()))$p$, t || '_insert', t);
    execute format($p$alter policy %I on %I
      using      (farm_id = (select current_farm()) and (select can_write()))
      with check (farm_id = (select current_farm()) and (select can_write()))$p$, t || '_update', t);
    execute format($p$alter policy %I on %I
      using (farm_id = (select current_farm()) and (select my_role()) = 'owner')$p$, t || '_delete', t);
  end loop;
end $$;

alter policy animal_read on animal
  using (farm_id = (select current_farm()) and (select can_read()));

alter policy animal_update on animal
  using (farm_id = (select current_farm()) and (select can_write()))
  with check (farm_id = (select current_farm()) and (select can_write())
    and (property_id is null
         or exists (select 1 from property p where p.id = animal.property_id))
    and (origin_property_id is null
         or exists (select 1 from property p where p.id = animal.origin_property_id)));

-- ------------------------------------------------------------
-- 2. import_asbv, as in 65, with its scratch table analyzed
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
  if auth.uid() is not null and not coalesce(can_write(), false) then
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
  -- A fresh table has no statistics; without them every match is a loop.
  analyze _sg;

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

  -- 3. By tag: the last six digits of the ID, our own flock only
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

revoke execute on function import_asbv(date, jsonb, text, text) from public, anon;
grant  execute on function import_asbv(date, jsonb, text, text) to authenticated;

-- Check:
--   select policyname, qual, with_check from pg_policies
--    where tablename in ('asbv', 'asbv_run', 'animal');
--     -- can_read() / can_write() / my_role() each inside (select …)
--   Then in the app, as Toland's owner: Record -> Manage -> Breeding
--   values, drop in 601082_21Sep26.xml, Load. 505 of 505 found,
--   36,712 values.
