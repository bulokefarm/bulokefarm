-- ============================================================
-- 75. A box is a carton.
--
-- The butcher's sheets numbered one "box" per pack, and noted
-- "2 cartons" beside a pack that fills two. That is not how the
-- packing bench works, and not how the old workbook counted: a
-- 24 kg beef order was Box 1 of 2 and Box 2 of 2, each a 12 kg box
-- with its own sheet; and a whole lamb goes into two boxes, not one.
--
-- So the sheets now count cartons. A pack that fills two cartons is
-- two boxes — two lines in the summary, two in the customer list,
-- two sheets — and "2 of 3" counts the boxes on the order.
--
-- What is on each box's sheet depends on the pack:
--
--   A pack that is the standard sheet several times over (beef: a
--   24 kg pack is the 12 kg sheet twice, in two cartons) has that
--   split evenly: each box gets the sheet sheet_multiple / cartons
--   times — once, for every beef size, exactly as the workbook's
--   one-sheet-per-12-kg-box had it.
--
--   A pack with a sheet of its own (a whole lamb) is one list
--   divided between its boxes. Each of its boxes carries the whole
--   list and says "split between 2 boxes"; split_boxes tells the
--   page so.
--
-- Weighing and ticking are still per order line (71): the weight is
-- written against the line's first box.
--
-- Only butcher_sheet() changes, replaced whole (as 74, with this).
-- butcher_harvests() still counts packs, which is what was sold.
--
-- Safe to run more than once.
-- ============================================================

create or replace function butcher_sheet(p_harvest uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  fid  uuid := current_farm();
  role text := my_role()::text;
  h    harvest;
begin
  if fid is null or role is null then
    raise exception 'Sign in first';
  end if;
  select * into h from harvest where id = p_harvest and farm_id = fid;
  if not found or (role = 'butcher' and h.butcher_released_at is null) then
    raise exception 'That harvest is not available';
  end if;

  return jsonb_build_object(
    'role', role,
    'farm', (select jsonb_build_object('name', f.name, 'logo_url', f.logo_url,
                                       'phone', b.phone, 'email', b.email)
               from farm f left join farm_business b on b.farm_id = f.id
              where f.id = fid),
    'harvest', jsonb_build_object(
      'id', h.id, 'code', h.code, 'kind', h.kind, 'title', h.title,
      'harvest_on', h.harvest_on, 'butcher_on', h.butcher_on, 'pickup_on', h.pickup_on,
      'delivery_on', h.delivery_on, 'interstate_on', h.interstate_on,
      'interstate_note', h.interstate_note, 'butcher_name', h.butcher_name,
      'pickup_place', h.pickup_place, 'head', h.head, 'carcass_kg', h.carcass_kg,
      'butcher_note', h.butcher_note, 'released', h.butcher_released_at is not null),
    'boxes', coalesce((
      select jsonb_agg(to_jsonb(b) order by b.box_no)
        from (
          select row_number() over (order by o.order_no, l.sort, l.created_at, g.n, k.c) as box_no,
                 row_number() over (partition by o.id order by l.sort, l.created_at, g.n, k.c) as idx,
                 count(*)     over (partition by o.id)                              as of,
                 l.id                                    as line_id,
                 order_ref(fb.order_prefix, o.order_no)  as order_ref,
                 c.name                                  as customer,
                 o.fulfilment,
                 l.description                           as pack,
                 g.n                                     as pack_no,     -- which of the line's packs
                 k.c                                     as carton,      -- which of that pack's boxes
                 x.cartons,                                              -- how many boxes that pack fills
                 round(l.size_kg / x.cartons, 2)         as size_kg,     -- in this box
                 l.qty                                   as line_qty,
                 l.packed,
                 l.actual_kg,
                 l.butcher_note,
                 l.answers,
                 coalesce(l.cut_sheet, po.cut_sheet, pr.cut_sheet) as cut_sheet,
                 case when x.own_sheet then 1
                      else round(coalesce(po.sheet_multiple, 1) / x.cartons, 2) end as sheet_multiple,
                 (x.own_sheet and x.cartons > 1)         as split_boxes,
                 coalesce(nullif(o.ship_name, ''), c.name)         as to_name,
                 coalesce(nullif(o.ship_phone, ''), c.phone)       as to_phone,
                 case when o.fulfilment = 'delivery' then
                   jsonb_build_object(
                     'street',   case when coalesce(o.ship_street, '') <> '' then o.ship_street   else c.street   end,
                     'suburb',   case when coalesce(o.ship_street, '') <> '' then o.ship_suburb   else c.suburb   end,
                     'state',    case when coalesce(o.ship_street, '') <> '' then o.ship_state    else c.state    end,
                     'postcode', case when coalesce(o.ship_street, '') <> '' then o.ship_postcode else c.postcode end,
                     'instructions', o.ship_instructions,
                     'deliver_on', o.deliver_on,
                     'carrier_ref', o.carrier_ref)
                 end                                     as ship
            from customer_order o
            join customer c    on c.id = o.customer_id
            join order_line l  on l.order_id = o.id and l.for_butcher
            left join product_option po on po.id = l.product_option_id
            left join product pr        on pr.id = po.product_id
            left join farm_business fb  on fb.farm_id = o.farm_id
            cross join lateral (select greatest(l.cartons, 1) as cartons,
                                       (l.cut_sheet is not null or po.cut_sheet is not null) as own_sheet) x
            cross join lateral generate_series(1, l.qty)     as g(n)
            cross join lateral generate_series(1, x.cartons) as k(c)
           where o.harvest_id = h.id and o.status <> 'cancelled') b), '[]'::jsonb),
    'remaining_sheet', h.remaining_sheet);
end $$;

notify pgrst, 'reload schema';
