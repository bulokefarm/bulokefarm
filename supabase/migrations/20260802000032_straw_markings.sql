-- ============================================================
-- Buloke Farm — how a straw is identified on the shelf
-- Apply after 20260802000031_cryo_store.sql.
--
-- Column B of the register runs down up to four rows per bull and is
-- not one label. Davelle Cool Beau N51 reads:
--
--     Yellow          the cane marker
--     white strws     the straw itself
--     mini's          the size
--     red goblett     the goblet it sits in
--
-- Four separate things, and together they are how you find the right
-- straw in a tank in the cold. Flattened into one string they are
-- unsearchable, and two lots of the same bull in the same location —
-- W Winds Atlas has exactly that — can only be told apart by them.
--
-- marking is kept as the verbatim column, because the parsing is a
-- reading of it and the original should survive being read wrong.
-- ============================================================

alter table ai_semen add column if not exists mark_colour text;
alter table ai_semen add column if not exists straw_desc  text;
alter table ai_semen add column if not exists straw_size  text
  check (straw_size in ('mini','maxi'));
alter table ai_semen add column if not exists goblet      text;

comment on column ai_semen.marking     is 'Column B verbatim. The source for the four fields below.';
comment on column ai_semen.mark_colour is 'Cane marker — Yellow, Green, No Mrk.';
comment on column ai_semen.straw_desc  is 'The straw as described — white strws, red straws, White strw-green crimp top.';
comment on column ai_semen.straw_size  is 'mini or maxi.';
comment on column ai_semen.goblet      is 'Goblet it sits in — red goblett, Orange Gob.';

create index if not exists ai_semen_mark_idx on ai_semen (tank, location, mark_colour);

-- Rebuilt so the shelf description comes through as one readable line
-- without losing the parts.
--
-- v_cryo_location reads v_ai_semen, so it comes off first and goes back
-- after. Postgres will not let a view be dropped from underneath one
-- that depends on it, and CASCADE would drop it silently.
drop view if exists v_cryo_location;
drop view if exists v_ai_semen;
create view v_ai_semen with (security_invoker = on) as
select
  s.*,
  nullif(concat_ws(' · ', s.mark_colour, s.straw_desc,
                   nullif(s.straw_size,'') , s.goblet), '') as shelf_label,
  coalesce(t.on_hand, 0)                       as straws_left,
  coalesce(t.used, 0)                          as straws_used,
  coalesce(a.stock_code, a.name, s.sire_name)  as sire_label,
  t.last_moved
from ai_semen s
left join animal a on a.id = s.sire_id
left join lateral (
  select sum(qty)                               as on_hand,
         -sum(qty) filter (where kind = 'used')  as used,
         max(on_date)                            as last_moved
    from cryo_txn where ai_semen_id = s.id
) t on true;

-- Back on, unchanged from 031.
create view v_cryo_location with (security_invoker = on) as
select tank, location, 'semen' as holds,
       count(*)::int as entries, sum(straws_left)::numeric as units
  from v_ai_semen where retired_on is null and tank is not null
 group by tank, location
union all
select tank, location, 'embryo',
       count(*)::int, sum(units_left)::numeric
  from v_embryo where retired_on is null and tank is not null
 group by tank, location
 order by tank, location, holds;

notify pgrst, 'reload schema';
