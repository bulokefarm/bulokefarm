-- ============================================================
-- Buloke Farm — restoring the expectations 029 deleted
-- Apply after 20260802000029_resolve_needs_a_date.sql.
--
-- Step 3 of 029 deleted every open expectation with no joining behind
-- it, on the assumption that such a row was a leftover the trigger was
-- about to own. Eight of them weren't. Those cows are due in spring
-- 2026, and the only joinings on file for them are for the season
-- after — recorded in November for spring 2027. There was never a
-- joining to link to, because the due dates came from preg testing
-- rather than from a recorded service.
--
-- So a standalone expectation is a legitimate thing to hold, not an
-- orphan. Restored here from the original seed values, with the
-- sires named as they were.
--
-- refresh_expectation only runs for dam and season pairs that have a
-- joining, so these are left alone until a real joining is recorded
-- for that same season — at which point the derived one should win,
-- which is what it already does.
-- ============================================================

insert into expected_calving (dam_id, sire_id, season, cycle, due_on)
select a.id, s.id, v.season, v.cycle, v.due_on
  from (values
  ('S 16', 'Peppermil G Wgyu', '2026-2027', 'spring'::cycle_t, '2026-09-08'::date),
  ('L 74', 'MJB United 333U?PP', '2026-2027', 'spring'::cycle_t, '2026-09-10'::date),
  ('S 05', 'MJB United 333U?PP', '2026-2027', 'spring'::cycle_t, '2026-09-10'::date),
  ('S 15', 'Peppermil G Wgyu', '2026-2027', 'spring'::cycle_t, '2026-09-21'::date),
  ('N 82', 'Peppermil G Wgyu', '2026-2027', 'spring'::cycle_t, '2026-10-01'::date),
  ('Q 32', 'Peppermil G Wgyu', '2026-2027', 'spring'::cycle_t, '2026-10-06'::date),
  ('N 84', 'Peppermil G Wgyu', '2026-2027', 'spring'::cycle_t, '2026-10-16'::date),
  ('T 02', 'M. Umberto U3', '2026-2027', 'spring'::cycle_t, '2026-11-21'::date),
  ('T 43', 'Yulong Trifecta T30', '2026-2027', 'autumn'::cycle_t, '2027-02-26'::date),
  ('U 18', 'Peppermil G Wgyu', '2026-2027', 'autumn'::cycle_t, '2027-02-13'::date),
  ('T 14', 'Davelle Cool Beau N51', '2026-2027', 'autumn'::cycle_t, '2027-02-20'::date)
  ) as v(dam_code, sire_name, season, cycle, due_on)
  join animal a on a.stock_code = v.dam_code
               and a.origin <> 'reference' and a.species = 'cattle'
  left join animal s on s.name = v.sire_name and s.origin = 'reference'
 where not exists (
   select 1 from expected_calving e
    where e.dam_id = a.id and e.season = v.season
      and e.resolved_calving_id is null);

notify pgrst, 'reload schema';
