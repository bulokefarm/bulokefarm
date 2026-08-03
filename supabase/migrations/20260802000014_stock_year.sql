-- ============================================================
-- Buloke Farm — livestock trading account by financial year
-- Apply after 20260802000013_joining_method.sql.
--
-- Numbers only. No valuation: the basis is an election that belongs
-- to the accountant, and guessing it here would put a figure on a
-- tax return that nobody chose.
--
-- The shape is the one every livestock schedule uses:
--
--     Opening + Purchases + Natural increase
--       − Sales − Deaths − Rations  =  Closing
--
-- Because animal_status is a dated timeline rather than a current
-- state, "who was alive on 30 June 2025" is a real question and every
-- line below falls out of it. Nothing is stored; a correction to a
-- status date reshapes the year it belongs to.
--
-- The reconciliation is deliberately allowed to fail. If the two
-- sides disagree, an animal has a status history that doesn't make
-- sense — and the report saying so in June is worth considerably
-- more than a report that quietly balances.
-- ============================================================

-- ------------------------------------------------------------
-- Rations versus sales.
--
-- life_state has one 'slaughtered'. Killed for the house and sold to
-- the works are both slaughter, and tax treats them as separate
-- lines. Until that's recorded properly, it's inferred: an animal
-- that left on a movement went to someone else; one that didn't was
-- eaten here.
--
-- It's a guess, so the report names the animals on the rations line
-- rather than just counting them. Wrong ones are then obvious.
-- ------------------------------------------------------------

drop view if exists v_stock_year_class;
drop view if exists v_stock_year;
drop view if exists v_stock_entry;
drop view if exists v_stock_exit;

create view v_stock_exit with (security_invoker = on) as
with gone as (
  -- First time an animal stopped being alive. A later correction that
  -- puts it back is somebody fixing a mistake, not a second exit.
  select distinct on (s.animal_id) s.animal_id, s.effective_on, s.life_state
  from animal_status s
  where s.life_state <> 'alive'
  order by s.animal_id, s.effective_on
)
select
  g.animal_id,
  a.stock_code,
  g.effective_on,
  g.life_state,
  c.destination_kind,
  (c.id is not null) as consigned,
  case
    when g.life_state = 'sold' then 'sale'
    when g.life_state = 'died' then 'death'
    -- Slaughtered and consigned somewhere that buys it: a sale. Note
    -- 'property' is not in that list — stock sent to agistment and
    -- killed later was still eaten here.
    when c.destination_kind in ('abattoir','saleyard','agent','other') then 'sale'
    else 'ration'
  end as exit_kind
from gone g
join animal a on a.id = g.animal_id and a.origin <> 'reference'
left join lateral (
  select c.id, c.destination_kind
  from consignment_animal ca
  join consignment c on c.id = ca.consignment_id and c.direction = 'out'
  where ca.animal_id = g.animal_id
    and c.consigned_on between g.effective_on - 30 and g.effective_on + 30
  order by c.consigned_on limit 1
) c on true;

comment on view v_stock_exit is
  'One row per animal that left the herd, with sale/death/ration inferred. Rations are a guess until life_state can say so.';

-- ------------------------------------------------------------
-- When an animal first appeared on the books. For something bred
-- that's natural increase; for something bought it's a purchase.
-- ------------------------------------------------------------

create view v_stock_entry with (security_invoker = on) as
select
  a.id as animal_id,
  a.stock_code,
  a.origin,
  coalesce(
    (select min(s.effective_on) from animal_status s where s.animal_id = a.id),
    a.purchased_on, a.dob
  ) as entered_on
from animal a
where a.origin <> 'reference';

-- ------------------------------------------------------------
-- The trading account itself, one row per financial year the
-- records span. Australian year: 1 July to 30 June.
-- ------------------------------------------------------------

create view v_stock_year with (security_invoker = on) as
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
    make_date(fy - 1, 7, 1) as fy_start,
    make_date(fy,     6, 30) as fy_end
  from span,
  generate_series(
    extract(year from d0)::int + case when extract(month from d0) >= 7 then 1 else 0 end,
    extract(year from d1)::int + case when extract(month from d1) >= 7 then 1 else 0 end
  ) as fy
)
select
  y.fy,
  (y.fy - 1) || '-' || right(y.fy::text, 2) as fy_label,
  y.fy_start,
  y.fy_end,

  -- Alive the day before the year opened.
  (select count(*) from animal a
    where a.origin <> 'reference'
      and (select s.life_state from animal_status s
            where s.animal_id = a.id and s.effective_on < y.fy_start
            order by s.effective_on desc limit 1) = 'alive')::int as opening,

  (select count(*) from v_stock_entry e
    where e.origin = 'purchased'
      and e.entered_on between y.fy_start and y.fy_end)::int as purchases,

  (select count(*) from v_stock_entry e
    where e.origin = 'bred'
      and e.entered_on between y.fy_start and y.fy_end)::int as natural_increase,

  (select count(*) from v_stock_exit x
    where x.exit_kind = 'sale'
      and x.effective_on between y.fy_start and y.fy_end)::int as sales,

  (select count(*) from v_stock_exit x
    where x.exit_kind = 'death'
      and x.effective_on between y.fy_start and y.fy_end)::int as deaths,

  (select count(*) from v_stock_exit x
    where x.exit_kind = 'ration'
      and x.effective_on between y.fy_start and y.fy_end)::int as rations,

  -- Alive at balance date.
  (select count(*) from animal a
    where a.origin <> 'reference'
      and (select s.life_state from animal_status s
            where s.animal_id = a.id and s.effective_on <= y.fy_end
            order by s.effective_on desc limit 1) = 'alive')::int as closing

from years y
order by y.fy;

comment on view v_stock_year is
  'Livestock trading account by financial year, head only. Opening + in - out should equal closing; when it does not, the status history is wrong somewhere.';

-- ------------------------------------------------------------
-- What the closing number was made of. The middle block of the
-- spreadsheet, and the part an accountant asks for by class.
-- ------------------------------------------------------------

create view v_stock_year_class with (security_invoker = on) as
select
  y.fy,
  coalesce(st.class::text, 'unclassed') as class,
  count(*)::int as head
from (select distinct fy, fy_end from v_stock_year) y
join animal a on a.origin <> 'reference'
join lateral (
  select s.life_state, s.class from animal_status s
  where s.animal_id = a.id and s.effective_on <= y.fy_end
  order by s.effective_on desc limit 1
) st on true
where st.life_state = 'alive'
group by y.fy, coalesce(st.class::text, 'unclassed')
order by y.fy, class;

notify pgrst, 'reload schema';
