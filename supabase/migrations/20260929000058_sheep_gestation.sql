-- ============================================================
-- 58. A ewe's gestation is not a cow's.
--
-- Migration 13 put a check on animal.gestation_days: between 250 and
-- 310. That is a cow. Sheep arrived in 19 and default to 145 days,
-- and both joining forms write an edited gestation back to the dam
-- when it differs from the default — so for a ewe that update broke
-- the check, and it broke it after the joining row was already
-- written: the joining saved, the form said it failed, and the same
-- joining got entered twice.
--
-- The range becomes 130 to 310, the one planned_joining has used
-- since 49. It is a guard against a typo — 28 for 285 — not a
-- statement about biology, so one range across both species is
-- enough. joining.gestation_days carries no check and needs none.
--
-- Safe to run more than once.
-- ============================================================

alter table animal drop constraint if exists animal_gestation_days_check;

alter table animal add constraint animal_gestation_days_check
  check (gestation_days between 130 and 310);

comment on column animal.gestation_days is
  'This dam''s own gestation length where it is known to differ from the species default (cattle 285, sheep 145). 130 to 310.';
