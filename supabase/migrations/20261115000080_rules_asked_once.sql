-- ============================================================
-- 80. The row rules on the sales tables, asked once a statement.
--
-- The mailing list stopped opening: "canceling statement due to
-- statement timeout". Nothing was wrong with the list. It is 424
-- addresses, and for each one v_subscriber looks through the customers
-- for the same address, to say who has ordered. That is 424 x 46 rows
-- read, and the rule on `customer` was asked of every one of them:
-- 19,500 calls of can_read() at about 0.9 ms each, 17 seconds against
-- the 8 a signed-in request is allowed.
--
-- This is the fault migration 66 found when a breeding-values file was
-- refused: a rule that calls can_read(), can_write() or my_role() bare
-- is run once a ROW; written as (select can_read()) it is run once a
-- STATEMENT and its answer used for every row. 66 rewrote the rules it
-- needed (asbv, asbv_run, animal). On production the other herd tables
-- are in that form too, though no migration here put them so — and
-- the tables added since, everything to do with selling (69, 70, 73,
-- 76), were written the old way again: 49 rules on 15 tables, which
-- worked while the tables were empty.
--
-- So this does every rule in the public schema: the 49 on production,
-- and on a database rebuilt from these migrations the herd tables as
-- well (169), which brings a rebuild into line with production.
--
-- Nothing about who may do what changes: the same functions, the same
-- farm, the same roles. Only how often the question is asked.
--
-- Done by reading each rule back and wrapping the bare calls, rather
-- than by writing 49 rules out again, so that it cannot miss one and
-- cannot change one by a slip of the hand; and it ends by refusing to
-- finish if a bare call is left anywhere in the public schema.
--
-- New tables: write the rule wrapped in the first place —
--   using (farm_id = (select current_farm()) and (select can_read()))
--
-- Safe to run more than once: a rule already wrapped is left alone.
-- ============================================================

do $$
declare
  r      record;
  bare   constant text := '(?<!SELECT )\m(can_read|can_write|my_role)\(\)';
  q      text;
  w      text;
  n      int := 0;
  left_  int;
begin
  for r in
    select schemaname, tablename, policyname, qual, with_check
      from pg_policies
     where schemaname = 'public'
       and (coalesce(qual, '') ~ bare or coalesce(with_check, '') ~ bare)
     order by tablename, policyname
  loop
    q := regexp_replace(r.qual,       bare, '(select \1())', 'g');
    w := regexp_replace(r.with_check, bare, '(select \1())', 'g');
    execute format('alter policy %I on %I.%I', r.policyname, r.schemaname, r.tablename)
         || case when q is not null then format(' using (%s)', q) else '' end
         || case when w is not null then format(' with check (%s)', w) else '' end;
    n := n + 1;
  end loop;

  select count(*) into left_
    from pg_policies
   where schemaname = 'public'
     and (coalesce(qual, '') ~ bare or coalesce(with_check, '') ~ bare);
  if left_ > 0 then
    raise exception '% row rule(s) still call can_read(), can_write() or my_role() once a row', left_;
  end if;

  raise notice 'Row rules rewritten to ask once a statement: %', n;
end $$;
