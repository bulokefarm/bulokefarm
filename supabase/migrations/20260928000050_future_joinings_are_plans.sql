-- ============================================================
-- 50. Joinings dated in the future become plans.
--
-- Ten AI joinings were recorded on 1 August 2026 for dates in November
-- and December 2026, season 2027-2028. They are intentions, not
-- matings: no straw was drawn, no outcome can exist yet, and each one
-- put a cow on Due for a calving that rests on a service that has not
-- happened. Before 49 there was nowhere else to write them.
--
-- Each becomes a planned_joining: same dam, sire, season, cycle; the
-- joined date as planned_on. The gestation is carried as the plan's
-- nominated figure only where it differs from what the dam would give
-- anyway, so the forecast follows her record from here.
--
-- Then the joinings go. The change log keeps every one of them as it
-- was, and refresh_expectation() takes the expectations off Due as it
-- does for any deleted joining.
--
-- Keyed on when they were recorded and when they were dated — rows
-- written before this migration for a date after it — so a re-run
-- finds nothing, and a joining someone later records ahead of its date
-- is left for them to decide about.
-- ============================================================

insert into planned_joining (dam_id, method, sire_id, ai_semen_id, paddock_id,
                             season, cycle, planned_on, gestation_days, notes)
select j.dam_id, j.method::text::joining_method_t, j.sire_id, j.ai_semen_id, j.paddock_id,
       j.season, j.cycle, j.joined_on,
       nullif(j.gestation_days, coalesce(d.gestation_days, 285))::smallint,
       'Recorded as a joining on ' || to_char(j.created_at, 'DD Mon YYYY')
         || ' ahead of the date; made a plan by migration 50'
  from joining j
  join animal d on d.id = j.dam_id
 where j.created_at < date '2026-09-28'
   and j.joined_on  > date '2026-09-28'
   and j.outcome = 'unknown'
   and not exists (select 1 from calving c where c.joining_id = j.id)
   and not exists (select 1 from planned_joining p
                    where p.dam_id = j.dam_id and p.season = j.season
                      and p.joining_id is null and p.cancelled_on is null);

delete from joining j
 where j.created_at < date '2026-09-28'
   and j.joined_on  > date '2026-09-28'
   and j.outcome = 'unknown'
   and not exists (select 1 from calving c where c.joining_id = j.id)
   and exists (select 1 from planned_joining p
                where p.dam_id = j.dam_id and p.season = j.season
                  and p.joining_id is null and p.cancelled_on is null);

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- Verification, once applied:
--
--   select dam_code, sire_name, planned_on, gestation_used, nominated_days, forecast_on
--     from v_planned_joining where status = 'open' order by planned_on;   -- ten rows
--   select count(*) from joining where joined_on > farm_today();          -- 0
--   select count(*) from expected_calving where season = '2027-2028';    -- 0
--   select count(*) from record_change_log
--    where table_name = 'joining' and action = 'delete';                  -- ten more than before
-- ------------------------------------------------------------
