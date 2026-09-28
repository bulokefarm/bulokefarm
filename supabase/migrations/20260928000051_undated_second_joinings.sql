-- ============================================================
-- 51. The undated second joinings for 2027-2028 go.
--
-- Beside the ten AI joinings that 50 turned into plans sat ten more
-- rows for the same cows, same season, attempt 2, method natural, no
-- date, no due date, no sire on three of them. They were the fallback
-- bull written down in August as a second column on the spreadsheet,
-- not a service and not yet a decision. A plan that is not a decision
-- is not worth a row either, so these are removed rather than
-- converted; if a second joining is wanted it can be planned when it
-- is decided. The change log keeps each one.
--
-- Keyed on the spreadsheet shape — seeded before this migration,
-- attempt 2, no service date, nothing tested, nothing calved — so a
-- re-run finds nothing and a dated second joining is never touched.
-- ============================================================

delete from joining j
 where j.season = '2027-2028'
   and j.attempt = 2
   and j.joined_on is null
   and j.due_on is null
   and j.outcome = 'unknown'
   and j.created_at < date '2026-09-28'
   and not exists (select 1 from calving c where c.joining_id = j.id);

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- Verification, once applied:
--
--   select count(*) from joining where season = '2027-2028';   -- 0
--   select count(*) from record_change_log
--    where table_name = 'joining' and action = 'delete';        -- ten more than before
-- ------------------------------------------------------------
