-- ============================================================
-- Buloke Farm — the animals behind each figure
-- Apply after 20260802000016_exit_leaves_paddock.sql.
--
-- v_stock_year counted. It couldn't say who. A trading account whose
-- purpose is finding discrepancies has to be able to show its working,
-- otherwise "closing is three out" is where the investigation stops
-- rather than where it starts.
--
-- So the list comes first and the counts are aggregated from it. They
-- cannot disagree: if the drill-down shows 38 animals, the headline
-- says 38, because it counted those same rows.
-- ============================================================

drop view if exists v_stock_year_class;
drop view if exists v_stock_year;
drop view if exists v_stock_year_animal;

create view v_stock_year_animal with (security_invoker = on) as
with span as (
  select
    least(
      coalesce((select min(effective_on) from animal_status), current_date),
      coalesce((select min(dob) from animal where origin <> 'reference'), current_date)
    ) as d0,
    greatest(
      coalesce((select max(effective_on) from animal_status), current_date),
      current_date
    ) as d1
  ),
years as (
  select
    fy,
    make_date(fy - 1, 7, 1)  as fy_start,
    make_date(fy,     6, 30) as fy_end
  from span,
  generate_series(
    extract(year from d0)::int + case when extract(month from d0) >= 7 then 1 else 0 end,
    extract(year from d1)::int + case when extract(month from d1) >= 7 then 1 else 0 end
  ) as fy
),

-- Alive the day before the year opened.
opening as (
  select y.fy, y.fy_start, y.fy_end, 'opening'::text as bucket,
         a.id as animal_id, s.effective_on as on_date, s.class, null::text as detail
  from years y
  cross join animal a
  join lateral (
    select effective_on, life_state, class from animal_status
     where animal_id = a.id and effective_on < y.fy_start
     order by effective_on desc limit 1) s on true
  where a.origin <> 'reference' and s.life_state = 'alive'
),

-- Alive at balance date.
closing as (
  select y.fy, y.fy_start, y.fy_end, 'closing'::text,
         a.id, s.effective_on, s.class, null::text
  from years y
  cross join animal a
  join lateral (
    select effective_on, life_state, class from animal_status
     where animal_id = a.id and effective_on <= y.fy_end
     order by effective_on desc limit 1) s on true
  where a.origin <> 'reference' and s.life_state = 'alive'
),

-- Came onto the books: bought, or born here.
entries as (
  select y.fy, y.fy_start, y.fy_end,
         case when e.origin = 'purchased' then 'purchases' else 'natural_increase' end,
         e.animal_id, e.entered_on, null::animal_class_t, e.origin::text
  from years y
  join v_stock_entry e on e.entered_on between y.fy_start and y.fy_end
),

-- Left: sold, died, or eaten here.
exits as (
  select y.fy, y.fy_start, y.fy_end,
         case x.exit_kind when 'sale'  then 'sales'
                          when 'death' then 'deaths'
                          else 'rations' end,
         x.animal_id, x.effective_on, null::animal_class_t,
         coalesce(x.destination_kind::text, x.life_state::text)
  from years y
  join v_stock_exit x on x.effective_on between y.fy_start and y.fy_end
)

select
  u.fy,
  (u.fy - 1) || '-' || right(u.fy::text, 2) as fy_label,
  u.fy_start, u.fy_end, u.bucket,
  u.animal_id, an.stock_code, an.name, an.sex, an.breed, an.dob,
  u.on_date,
  coalesce(u.class::text, 'unclassed') as class,
  u.detail
from (
  select * from opening
  union all select * from closing
  union all select * from entries
  union all select * from exits
) u
join animal an on an.id = u.animal_id;

comment on view v_stock_year_animal is
  'One row per animal per bucket per financial year. Every figure in the trading account is a count of these rows.';

-- ------------------------------------------------------------
-- The trading account, counted off the list above.
-- ------------------------------------------------------------

create view v_stock_year with (security_invoker = on) as
select
  fy, fy_label, fy_start, fy_end,
  count(*) filter (where bucket = 'opening')::int          as opening,
  count(*) filter (where bucket = 'purchases')::int        as purchases,
  count(*) filter (where bucket = 'natural_increase')::int as natural_increase,
  count(*) filter (where bucket = 'sales')::int            as sales,
  count(*) filter (where bucket = 'deaths')::int           as deaths,
  count(*) filter (where bucket = 'rations')::int          as rations,
  count(*) filter (where bucket = 'closing')::int          as closing
from v_stock_year_animal
group by fy, fy_label, fy_start, fy_end
order by fy;

comment on view v_stock_year is
  'Livestock trading account, head only. Opening + in - out should equal closing; where it does not, the status history is wrong somewhere.';

-- ------------------------------------------------------------
-- What the closing number was made of.
-- ------------------------------------------------------------

create view v_stock_year_class with (security_invoker = on) as
select fy, fy_label, class, count(*)::int as head
from v_stock_year_animal
where bucket = 'closing'
group by fy, fy_label, class
order by fy, class;

notify pgrst, 'reload schema';
