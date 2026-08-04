-- ============================================================
-- Buloke Farm — the trading account splits by species
-- Apply after 20260802000021_species_in_app_views.sql.
--
-- A ewe and a cow are not interchangeable head. Adding them together
-- produces a closing number that goes on no tax return and answers no
-- question anyone asks — the schedule is prepared per species, and so
-- is the natural increase, and so is the valuation.
--
-- Only the grouping changes. Both views already read from
-- v_stock_year_animal, which has carried species since 019, so the
-- figures themselves are unchanged — they are just no longer summed
-- across two mobs that have nothing to do with each other.
-- ============================================================

drop view if exists v_stock_year_class;
drop view if exists v_stock_year;

create view v_stock_year with (security_invoker = on) as
select
  fy, fy_label, fy_start, fy_end, species,
  count(*) filter (where bucket = 'opening')::int          as opening,
  count(*) filter (where bucket = 'purchases')::int        as purchases,
  count(*) filter (where bucket = 'natural_increase')::int as natural_increase,
  count(*) filter (where bucket = 'sales')::int            as sales,
  count(*) filter (where bucket = 'deaths')::int           as deaths,
  count(*) filter (where bucket = 'rations')::int          as rations,
  count(*) filter (where bucket = 'closing')::int          as closing
from v_stock_year_animal
group by fy, fy_label, fy_start, fy_end, species
order by species, fy;

comment on view v_stock_year is
  'Livestock trading account, head only, one row per species per financial year. Opening + in - out should equal closing.';

create view v_stock_year_class with (security_invoker = on) as
select fy, fy_label, species, class, count(*)::int as head
from v_stock_year_animal
where bucket = 'closing'
group by fy, fy_label, species, class
order by species, fy, class;

notify pgrst, 'reload schema';
