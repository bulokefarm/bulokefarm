-- ============================================================
-- 71. What the butcher sees.
--
-- The butcher's workbook had three parts: a summary of the harvest
-- with every box numbered, the list of customers the boxes are for,
-- and one cut sheet per box. All three are the same orders read
-- three ways, so they are one function returning one document, and
-- /butcher lays it out for printing.
--
-- A butcher cannot read a single table (69). These functions run as
-- owner and hand back only what goes on the paper: who the box is
-- for and a phone number, where it is going if it is being sent,
-- what to cut. No prices, no payments, no emails, nothing about the
-- herd. And only for a harvest that has been released to them —
-- harvest.butcher_released_at — so a half-entered order book is not
-- mistaken for the job.
--
-- Owners, managers and viewers get the same document for any
-- harvest: it is how the sheets are checked before they are released.
--
-- Boxes are numbered across the harvest in order of order number, and
-- "2 of 3" counts the packs on one order, as the workbook did.
--
-- Safe to run more than once.
-- ============================================================

create or replace function butcher_harvests() returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  fid  uuid := current_farm();
  role text := my_role()::text;
begin
  if fid is null or role is null then
    raise exception 'Sign in first';
  end if;
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.harvest_on desc)
      from (select h.id, h.code, h.kind, h.title, h.harvest_on, h.butcher_on, h.pickup_on,
                   h.butcher_released_at is not null as released,
                   (select coalesce(sum(l.qty), 0)
                      from order_line l
                      join customer_order o on o.id = l.order_id
                     where o.harvest_id = h.id and o.status <> 'cancelled' and l.for_butcher) as packs
              from harvest h
             where h.farm_id = fid
               and (role <> 'butcher' or h.butcher_released_at is not null)) x), '[]'::jsonb);
end $$;

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
          select row_number() over (order by o.order_no, l.sort, l.created_at, g.n) as box_no,
                 row_number() over (partition by o.id order by l.sort, l.created_at, g.n) as idx,
                 count(*)     over (partition by o.id)                              as of,
                 l.id                                    as line_id,
                 order_ref(fb.order_prefix, o.order_no)  as order_ref,
                 c.name                                  as customer,
                 o.fulfilment,
                 l.description                           as pack,
                 l.size_kg,
                 l.cartons,
                 l.qty                                   as line_qty,
                 l.packed,
                 l.actual_kg,
                 l.butcher_note,
                 coalesce(l.cut_sheet, po.cut_sheet, pr.cut_sheet) as cut_sheet,
                 case when l.cut_sheet is not null or po.cut_sheet is not null then 1
                      else coalesce(po.sheet_multiple, 1) end      as sheet_multiple,
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
            cross join lateral generate_series(1, l.qty) as g(n)
            left join product_option po on po.id = l.product_option_id
            left join product pr        on pr.id = po.product_id
            left join farm_business fb  on fb.farm_id = o.farm_id
           where o.harvest_id = h.id and o.status <> 'cancelled') b), '[]'::jsonb),
    'remaining_sheet', h.remaining_sheet);
end $$;

-- The butcher ticks a pack off and writes down what it weighed.
-- Weight is for the whole line: two 12 kg packs on one line are
-- weighed together. A weight of zero clears it.
create or replace function butcher_pack(p_line uuid, p_packed boolean, p_actual_kg numeric default null)
returns void
language plpgsql security definer set search_path = public as $$
declare
  fid  uuid := current_farm();
  role text := my_role()::text;
begin
  if fid is null or role is null or role not in ('butcher', 'owner', 'manager') then
    raise exception 'Not allowed';
  end if;
  update order_line l
     set packed    = p_packed,
         actual_kg = case when p_actual_kg is null then l.actual_kg
                          when p_actual_kg = 0     then null
                          else p_actual_kg end
   where l.id = p_line and l.farm_id = fid
     and exists (select 1 from customer_order o
                   join harvest h on h.id = o.harvest_id
                  where o.id = l.order_id
                    and (role <> 'butcher' or h.butcher_released_at is not null));
  if not found then
    raise exception 'No such pack';
  end if;
end $$;

revoke execute on function butcher_harvests()                    from public, anon;
revoke execute on function butcher_sheet(uuid)                   from public, anon;
revoke execute on function butcher_pack(uuid, boolean, numeric)  from public, anon;
grant  execute on function butcher_harvests()                    to authenticated;
grant  execute on function butcher_sheet(uuid)                   to authenticated;
grant  execute on function butcher_pack(uuid, boolean, numeric)  to authenticated;

notify pgrst, 'reload schema';
