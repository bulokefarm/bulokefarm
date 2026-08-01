-- ============================================================
-- Health treatments and feeding, autumn/winter 2026
-- Generated from the paper health record.
--
-- Animals not on the register (your father's) are skipped silently:
-- each insert matches on stock_code, so unknown codes simply find
-- nothing. Re-running this file will not duplicate anything.
--
-- TO DO BEFORE THIS IS LPA-COMPLETE: set who administered each
-- treatment. Run once at the end:
--   update treatment set treated_by = 'Your Name', treated_by_contact = '04xx xxx xxx'
--    where treated_by is null and treated_on >= '2026-03-01';
-- ============================================================

begin;


-- ── Drenches ────────────────────────────────────────────────

-- 2026-04-20 · Cows · 9 listed on paper
insert into treatment (treated_on, description, product_name, batch_number,
  product_expiry, dose_rate, route, withholding_days, esi_days, adverse_reaction, broken_needle)
select '2026-04-20', 'Cows', 'Cydectin pour-on', '2404001',
       '2027-07-31', '1 mL/10 kg', 'pour-on',
       0, 7, 'Nil noted', false
where not exists (select 1 from treatment
  where treated_on='2026-04-20' and product_name='Cydectin pour-on' and description='Cows');

insert into treatment_animal (treatment_id, animal_id)
select t.id, a.id
  from treatment t
  join animal a on a.stock_code = any (array['S 06','R 44','U 02','U 04','U 08','U 20','U 18','T 14','T 43'])
                and a.origin <> 'reference'
 where t.treated_on='2026-04-20' and t.product_name='Cydectin pour-on' and t.description='Cows'
on conflict do nothing;

-- 2026-04-21 · Heifers · 4 listed on paper
insert into treatment (treated_on, description, product_name, batch_number,
  product_expiry, dose_rate, route, withholding_days, esi_days, adverse_reaction, broken_needle)
select '2026-04-21', 'Heifers', 'Cydectin pour-on', '2404001',
       '2027-07-31', '1 mL/10 kg', 'pour-on',
       0, 7, 'Nil noted', false
where not exists (select 1 from treatment
  where treated_on='2026-04-21' and product_name='Cydectin pour-on' and description='Heifers');

insert into treatment_animal (treatment_id, animal_id)
select t.id, a.id
  from treatment t
  join animal a on a.stock_code = any (array['U 10','V 04','V 19','V 22'])
                and a.origin <> 'reference'
 where t.treated_on='2026-04-21' and t.product_name='Cydectin pour-on' and t.description='Heifers'
on conflict do nothing;

-- 2026-04-22 · Steers · 5 listed on paper
insert into treatment (treated_on, description, product_name, batch_number,
  product_expiry, dose_rate, route, withholding_days, esi_days, adverse_reaction, broken_needle)
select '2026-04-22', 'Steers', 'Cydectin pour-on', '2404001',
       '2027-07-31', '1 mL/10 kg', 'pour-on',
       0, 7, 'Nil noted', false
where not exists (select 1 from treatment
  where treated_on='2026-04-22' and product_name='Cydectin pour-on' and description='Steers');

insert into treatment_animal (treatment_id, animal_id)
select t.id, a.id
  from treatment t
  join animal a on a.stock_code = any (array['V 11','V 17','W 05','V 23','V 25'])
                and a.origin <> 'reference'
 where t.treated_on='2026-04-22' and t.product_name='Cydectin pour-on' and t.description='Steers'
on conflict do nothing;

-- 2026-05-15 · Bull and steers · 4 listed on paper
insert into treatment (treated_on, description, product_name, batch_number,
  product_expiry, dose_rate, route, withholding_days, esi_days, adverse_reaction, broken_needle)
select '2026-05-15', 'Bull and steers', 'Cydectin pour-on', '2404001',
       '2027-07-31', '1 mL/10 kg', 'pour-on',
       0, 7, 'Nil noted', false
where not exists (select 1 from treatment
  where treated_on='2026-05-15' and product_name='Cydectin pour-on' and description='Bull and steers');

insert into treatment_animal (treatment_id, animal_id)
select t.id, a.id
  from treatment t
  join animal a on a.stock_code = any (array['V 07','V 21','V 27','W 01'])
                and a.origin <> 'reference'
 where t.treated_on='2026-05-15' and t.product_name='Cydectin pour-on' and t.description='Bull and steers'
on conflict do nothing;

-- 2026-06-10 · Weaners · 14 listed on paper
insert into treatment (treated_on, description, product_name, batch_number,
  product_expiry, dose_rate, route, withholding_days, esi_days, adverse_reaction, broken_needle)
select '2026-06-10', 'Weaners', 'Cydectin pour-on', '2404001',
       '2027-07-31', '1 mL/10 kg', 'pour-on',
       0, 7, 'Nil noted', false
where not exists (select 1 from treatment
  where treated_on='2026-06-10' and product_name='Cydectin pour-on' and description='Weaners');

insert into treatment_animal (treatment_id, animal_id)
select t.id, a.id
  from treatment t
  join animal a on a.stock_code = any (array['W 06','W 08','W 07','W 09','W 10','W 11','W 12','W 14','W 16','W 18','W 20','W 15','W 22','W 24'])
                and a.origin <> 'reference'
 where t.treated_on='2026-06-10' and t.product_name='Cydectin pour-on' and t.description='Weaners'
on conflict do nothing;


-- ── Stock feed ──────────────────────────────────────────────
-- These are feeding records, not veterinary treatments: they belong to
-- LPA Section 3C/3D, not Section 2. The "certified safe, zero RAM"
-- declaration is the part that matters at sale time.

insert into feeding_period (animal_id, started_on, ration, location, notes)
select a.id, '2026-03-17', 'Irwins Grain Free Optimiser', 'Self feeder, silo 28',
       '3.95 tonne. Certified safe, zero restricted animal material (RAM).'
  from animal a
 where a.stock_code = any (array['V 11','V 17','W 05','V 23','V 25'])
   and a.origin <> 'reference'
   and not exists (select 1 from feeding_period f
                   where f.animal_id=a.id and f.started_on='2026-03-17'
                     and f.ration='Irwins Grain Free Optimiser');

insert into feeding_period (animal_id, started_on, ration, location, notes)
select a.id, '2026-06-07', 'Irwins Grain Free Optimiser', 'Self feeder',
       '4.00 tonne. Certified safe, zero restricted animal material (RAM).'
  from animal a
 where a.stock_code = any (array['V 17','W 01','V 16','V 20','V 06','V 10'])
   and a.origin <> 'reference'
   and not exists (select 1 from feeding_period f
                   where f.animal_id=a.id and f.started_on='2026-06-07'
                     and f.ration='Irwins Grain Free Optimiser');


commit;

-- ── Check what landed ───────────────────────────────────────────
-- select t.treated_on, t.description, t.product_name, t.safe_for_slaughter,
--        count(ta.animal_id) as head
--   from treatment t left join treatment_animal ta on ta.treatment_id = t.id
--  where t.treated_on >= '2026-03-01'
--  group by t.id order by t.treated_on;
