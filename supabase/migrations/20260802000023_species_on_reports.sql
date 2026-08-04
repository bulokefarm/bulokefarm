-- ============================================================
-- Buloke Farm — species on the reports
-- Apply after 20260802000022_stock_year_by_species.sql.
--
-- The joining register says a joining was 'natural' and the page
-- renders that as "bull". For a ewe it was a ram. The view had no way
-- to tell the page which, because species never made it here.
--
-- Joinings take a single species column: a joining has one dam, so
-- there is exactly one right answer.
--
-- Treatments and consignments take a list. One drench run covers both
-- mobs and one truck can carry both, so the honest answer is which
-- species were involved, not which species it was. The report filters
-- on "involved" rather than pretending otherwise.
-- ============================================================

drop view if exists v_joining_result;

create view v_joining_result with (security_invoker = on) as
select
  j.id, j.dam_id, d.stock_code as dam_code, d.name as dam_name,
  j.method,
  j.sire_id, coalesce(s.name, sem.sire_name) as sire_name,
  j.ai_semen_id, sem.straw_code, sem.tank,
  j.paddock_id, p.name as paddock_name,
  j.season, j.cycle, j.attempt, j.joined_on, j.bull_out, j.tested_on,
  j.gestation_days, j.due_on, j.confidence, j.outcome, j.notes,
  c.calved_on, c.outcome as calving_outcome,
  calf.stock_code as calf_code,
  (select count(*) from record_change_log l
    where l.table_name='joining' and l.row_id=j.id) as edits,
  d.property_id, dpr.pic,
  d.species
from joining j
join animal d on d.id = j.dam_id
left join property dpr  on dpr.id  = d.property_id
left join animal   s    on s.id    = j.sire_id
left join ai_semen sem  on sem.id  = j.ai_semen_id
left join paddock  p    on p.id    = j.paddock_id
left join calving  c    on c.joining_id = j.id
left join animal   calf on calf.id = c.calf_id;

-- Which species were on the run. Appended, so nothing reading these
-- views today changes.
create or replace view v_treatment_report with (security_invoker = on) as
select
  t.id,
  t.treated_on, t.description, t.product_name, t.batch_number,
  t.product_expiry, t.dose_rate, t.route,
  t.withholding_days, t.esi_days, t.safe_for_slaughter,
  t.treated_by, t.treated_by_contact,
  coalesce(t.treated_by, u.display_name)  as treated_by_shown,
  coalesce(t.treated_by_contact, u.phone) as contact_shown,
  t.adverse_reaction, t.broken_needle, t.notes,
  count(ta.animal_id)                     as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags,
  (select count(*) from record_change_log l
    where l.table_name='treatment' and l.row_id=t.id) as edits,
  string_agg(distinct pr.pic, ', ')       as pics,
  string_agg(distinct a.species::text, ', ') as species
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
left join animal a on a.id = ta.animal_id
left join property pr on pr.id = a.property_id
group by t.id, u.display_name, u.phone;

create or replace view v_consignment with (security_invoker = on) as
select
  c.*,
  u.display_name                                   as recorded_by_name,
  count(ca.animal_id)                              as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags,
  sum(ca.sale_weight_kg)                           as total_kg,
  sum(ca.amount_ex_gst)                            as total_ex_gst,
  (select count(*) from record_change_log l
    where l.table_name='consignment' and l.row_id=c.id) as edits,
  string_agg(distinct a.species::text, ', ')       as species
from consignment c
left join farm_user u on u.id = c.recorded_by
left join consignment_animal ca on ca.consignment_id = c.id
left join animal a on a.id = ca.animal_id
group by c.id, u.display_name;

notify pgrst, 'reload schema';
