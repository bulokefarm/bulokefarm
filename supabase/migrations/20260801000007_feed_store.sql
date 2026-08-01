-- ============================================================
-- Buloke Farm — feed store, quantities, and a fix for 09
-- Apply after 09_audit.sql. Safe to run more than once.
--
-- FIX: 09 used `create or replace view` to add `id` at the front of
-- two views. Postgres can only APPEND columns that way, so those
-- replacements failed and the report kept serving rows with no id —
-- hence "invalid input syntax for type uuid: undefined".
-- Dropping and recreating is the only way to reshape a view.
-- ============================================================

drop view if exists v_treatment_report;
drop view if exists v_feed_event;
drop view if exists v_feed_store;

-- ------------------------------------------------------------
-- 1. Feed store: what it is, how much came in, how much is left.
-- ------------------------------------------------------------

alter table feed_source add column if not exists feed_type text;
alter table feed_source add column if not exists quantity  numeric(10,2);
alter table feed_source add column if not exists unit      text;

alter table feed_event  add column if not exists qty numeric(10,2);

-- Classify what's already there, and treat straight fodder as RAM free.
update feed_source
   set feed_type = coalesce(feed_type,
         case when feedstuff ~* 'hay|silage|straw|fodder|lucerne|pasture' then 'fodder'
              when feedstuff ~* 'grain|barley|wheat|oats|sorghum|optimiser|pellet' then 'grain'
              else 'other' end);

update feed_source
   set ram_free = true
 where ram_free is null and feed_type = 'fodder';

-- ------------------------------------------------------------
-- 2. Views, rebuilt properly.
-- ------------------------------------------------------------

create view v_treatment_report with (security_invoker = on) as
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
    where l.table_name='treatment' and l.row_id=t.id) as edits
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
left join animal a on a.id = ta.animal_id
group by t.id, u.display_name, u.phone;

create view v_feed_event with (security_invoker = on) as
select
  fe.id, fe.fed_on, fe.ended_on, fe.amount, fe.qty, fe.method, fe.notes,
  fe.feed_source_id, fe.ration,
  coalesce(fs.feedstuff, fe.ration)  as feedstuff,
  fs.feed_type, fs.batch_ref, fs.origin, fs.cvd_ref,
  fs.ram_free, fs.home_grown, fs.unit,
  fe.paddock_id, p.name    as paddock_name,
  p.colour                 as paddock_colour,
  u.display_name           as fed_by,
  (select count(*) from feed_event_animal fa where fa.feed_event_id = fe.id)
  + case when fe.paddock_id is null then 0 else
      (select count(*) from paddock_stay s
        where s.paddock_id = fe.paddock_id
          and s.moved_in <= fe.fed_on
          and (s.moved_out is null or s.moved_out >= fe.fed_on)) end   as head,
  (select count(*) from record_change_log l
    where l.table_name='feed_event' and l.row_id=fe.id)                as edits
from feed_event fe
left join feed_source fs on fs.id = fe.feed_source_id
left join paddock     p  on p.id  = fe.paddock_id
left join farm_user   u  on u.id  = fe.recorded_by;

-- What's in the shed, and what's left of it.
create view v_feed_store with (security_invoker = on) as
select
  fs.id, fs.feedstuff, fs.feed_type, fs.batch_ref, fs.received_on,
  fs.quantity, fs.unit, fs.amount, fs.origin, fs.home_grown,
  fs.cvd_ref, fs.residue_cert, fs.ram_free, fs.storage,
  fs.signed_by, fs.exhausted_on, fs.notes,
  coalesce(sum(fe.qty), 0)                                as used,
  case when fs.quantity is not null
       then round(fs.quantity - coalesce(sum(fe.qty),0), 2) end as remaining,
  count(fe.id)                                            as feed_outs,
  max(fe.fed_on)                                          as last_fed
from feed_source fs
left join feed_event fe on fe.feed_source_id = fs.id
group by fs.id;
