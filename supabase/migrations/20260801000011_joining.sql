-- ============================================================
-- Buloke Farm — joining outcomes
-- Apply after 14_historical.sql. Safe to run more than once.
--
-- A cow that didn't get in calf is not an animal and not a calving,
-- so it had nowhere to live. It belongs on the joining: the mating
-- happened, the outcome was empty. Without it, conception rate is
-- unknowable, because the failures leave no trace.
-- ============================================================

do $$
begin
  if not exists (select 1 from pg_type where typname='joining_outcome_t') then
    create type joining_outcome_t as enum
      ('unknown','in_calf','empty','calved','aborted','lost');
  end if;
end $$;

alter table joining add column if not exists outcome   joining_outcome_t not null default 'unknown';
alter table joining add column if not exists tested_on date;
alter table joining add column if not exists bull_out  date;

-- ------------------------------------------------------------
-- Performance. Empties are the whole point: a conception rate
-- calculated only from cows that calved is always 100%.
-- ------------------------------------------------------------

create or replace view v_joining_result with (security_invoker = on) as
select
  j.id, j.dam_id, d.stock_code as dam_code, d.name as dam_name,
  j.sire_id, s.name as sire_name,
  j.season, j.cycle, j.attempt, j.joined_on, j.bull_out, j.tested_on,
  j.gestation_days, j.due_on, j.confidence, j.outcome, j.notes,
  c.calved_on, c.outcome as calving_outcome,
  calf.stock_code as calf_code
from joining j
join animal d on d.id = j.dam_id
left join animal s on s.id = j.sire_id
left join calving c on c.joining_id = j.id
left join animal calf on calf.id = c.calf_id;

create or replace view v_joining_performance with (security_invoker = on) as
select
  coalesce(s.name, 'Sire not recorded')          as sire,
  j.season,
  count(*)                                       as joinings,
  count(*) filter (where j.outcome in ('in_calf','calved'))  as held,
  count(*) filter (where j.outcome = 'empty')                as empty,
  count(*) filter (where j.outcome in ('aborted','lost'))    as lost,
  count(*) filter (where j.outcome = 'unknown')              as untested,
  case when count(*) filter (where j.outcome <> 'unknown') > 0
       then round(100.0 * count(*) filter (where j.outcome in ('in_calf','calved'))
                  / count(*) filter (where j.outcome <> 'unknown'))
  end as pct_held
from joining j
left join animal s on s.id = j.sire_id
group by coalesce(s.name, 'Sire not recorded'), j.season;

-- Per cow, so a repeat offender is visible.
create or replace view v_dam_fertility with (security_invoker = on) as
select
  d.id as dam_id, d.stock_code, d.name,
  count(j.id)                                                as joinings,
  count(*) filter (where j.outcome in ('in_calf','calved'))   as held,
  count(*) filter (where j.outcome = 'empty')                 as empty,
  max(j.season) filter (where j.outcome = 'empty')            as last_empty,
  case when count(*) filter (where j.outcome <> 'unknown') > 0
       then round(100.0 * count(*) filter (where j.outcome in ('in_calf','calved'))
                  / count(*) filter (where j.outcome <> 'unknown'))
  end as pct_held
from animal d
join joining j on j.dam_id = d.id
where d.origin <> 'reference'
group by d.id, d.stock_code, d.name;

drop trigger if exists joining_changed on joining;
create trigger joining_changed after update or delete on joining
  for each row execute function log_record_change();
