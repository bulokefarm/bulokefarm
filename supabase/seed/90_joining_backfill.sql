-- ============================================================
-- Buloke Farm — joining outcome backfill  (SEED, not a migration)
-- Run after the seed files. Depends on imported data, so it must
-- come after 02_seed.sql and 14_historical.sql, not before.
-- Idempotent: only touches joinings still marked 'unknown'.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- Backfill from what's already recorded.
-- Confidence in the spreadsheet was a pregnancy-test result:
-- 1 meant in calf, 0.05 meant almost certainly not.
-- ------------------------------------------------------------

update joining j set outcome = 'calved'
 where outcome = 'unknown'
   and exists (select 1 from calving c where c.joining_id = j.id);

update joining set outcome = 'in_calf'
 where outcome = 'unknown' and confidence >= 0.9;

update joining set outcome = 'empty'
 where outcome = 'unknown' and confidence <= 0.1;

-- ------------------------------------------------------------
-- The two empty joinings from the historical file.
-- T-drop season, Wagyu bull, neither cow held.
-- ------------------------------------------------------------

insert into joining (dam_id, sire_id, season, cycle, attempt, outcome, notes)
select d.id,
       (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1),
       '2022-2023', 'spring', 1, 'empty',
       'Recorded as Empty on the historical sheet; no join date kept'
  from animal d
 where d.stock_code in ('N 82','R 10') and d.origin <> 'reference'
   and not exists (select 1 from joining j
                   where j.dam_id = d.id and j.season = '2022-2023' and j.attempt = 1);


commit;
