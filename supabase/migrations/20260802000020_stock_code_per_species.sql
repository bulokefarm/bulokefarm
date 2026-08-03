-- ============================================================
-- Buloke Farm — stock codes are unique within a species
-- Apply after 20260802000019_sheep.sql, before the sheep import.
--
-- The year-letter system runs independently for each mob. R 97 is a
-- cow and R 97 is also a ewe; both are correct, and in the yards
-- nobody has ever confused the two. The unique index was written when
-- cattle were the only thing on the books, so it read the tag as
-- unique on its own.
--
-- Rebuilt on (species, stock_code). Cattle-to-cattle and sheep-to-
-- sheep collisions are still caught, which is the case that matters.
-- ============================================================

drop index if exists animal_stock_code_resident_uq;

create unique index animal_stock_code_resident_uq
  on animal (species, stock_code)
  where origin <> 'reference' and stock_code is not null;

comment on index animal_stock_code_resident_uq is
  'Stock codes recycle on a 26-year letter cycle and run separately per species. Unique per species among non-reference animals.';

notify pgrst, 'reload schema';
