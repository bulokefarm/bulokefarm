-- ============================================================
-- 68. A lamb turns one and moves on by itself.
--
-- On its first birthday a sheep still classed as a lamb becomes a
-- yearling, or harvest if it is a ram or wether lamb. Nobody has to
-- remember: the WH ewe lambs turned one on 2026-09-15 and were still
-- lambs six weeks later.
--
-- The change is an ordinary animal_status row, dated the birthday and
-- reasoned 'Turned one', so the class history and the financial-year
-- livestock counts read it like any hand-made change. Only animals
-- that are alive and still 'lamb' today are touched: a ram lamb kept
-- for breeding and set back to ram, or a ewe lamb already made a
-- breeder, is left alone, and so is anything sold or dead.
--
-- If a lamb already has a status row dated after its birthday (still
-- saying lamb), the new row goes the day after that one, so it isn't
-- hidden behind it.
--
-- pg_cron runs it ten past midnight AEST (14:10 UTC; 01:10 in
-- daylight saving). This migration runs it once as well, to catch up.
--
-- Safe to run more than once.
-- ============================================================

create extension if not exists pg_cron;

create or replace function promote_lambs_turned_one() returns integer
  language plpgsql
  set search_path to 'public'
as $$
declare n int;
begin
  insert into animal_status (animal_id, effective_on, life_state, class, reason)
  select a.id,
         greatest((a.dob + interval '1 year')::date, cur.effective_on + 1),
         'alive',
         case when a.sex in ('male','wether') then 'harvest' else 'yearling' end::animal_class_t,
         'Turned one'
    from animal a
    join lateral (
      select effective_on, life_state, class from animal_status
       where animal_id = a.id and effective_on <= current_date
       order by effective_on desc limit 1) cur on true
   where a.species = 'sheep'
     and a.dob is not null
     and (a.dob + interval '1 year')::date <= current_date
     and cur.life_state = 'alive'
     and cur.class = 'lamb'
  on conflict (animal_id, effective_on) do nothing;

  get diagnostics n = row_count;
  return n;
end $$;

comment on function promote_lambs_turned_one() is
  'Nightly (pg_cron): a sheep still classed lamb on its first birthday becomes yearling, or harvest if male or wether. Returns rows written.';

-- Not something to call from the app.
revoke execute on function promote_lambs_turned_one() from public, anon, authenticated;

select cron.schedule('lambs-turn-one', '10 14 * * *', 'select public.promote_lambs_turned_one()');

select promote_lambs_turned_one();
