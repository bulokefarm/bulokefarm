-- ============================================================
-- 77. What a harvest has to sell, and what is left of it.
--
-- A harvest knew what had been sold out of it and, for beef, how many
-- kilos there were to sell (carcass x retail ratio, once the carcass
-- had been weighed). It did not know the plain thing: six lambs are
-- twelve boxes, three are spoken for, nine are left. Nobody could see
-- that — not the butcher on the summary, not the person taking orders,
-- not a customer on the website wondering whether to hurry.
--
-- The balance is counted in boxes, because a box is what is sold and
-- what is packed (75: a box is a carton; a whole lamb is two, a half
-- is one, a 24 kg beef pack is two 12 kg boxes).
--
--   boxes for sale   harvest.boxes_for_sale if someone typed it. If
--                    not, it is worked out: a lamb is two boxes, so
--                    head x 2; beef is sold by weight, so the kilos for
--                    sale divided by the smallest box that kind is sold
--                    in (12 kg), once those kilos are known.
--   boxes sold       every box on the butcher's sheets: the packs on
--                    orders that are not cancelled, each counted as
--                    the cartons it fills.
--   boxes left       the difference. It can go below nought — sold
--                    more than there is — and says so rather than
--                    hiding it.
--
-- v_harvest_balance is that sum, once. Three things read it:
--
--   butcher_sheet()  hands it to the summary ("balance").
--   shop_front()     tells the website what is for sale and what is
--                    left on each harvest, and how many boxes each
--                    pack is, so it can say "4 1/2 of 6 lambs left".
--   place_order()    puts a website order on the first open harvest of
--                    its kind that has room for it. A harvest with
--                    nothing left behaves as a closed one always has:
--                    the order is still taken, and waits under "No
--                    harvest" for a person to place.
--
-- It is a view of its own, not three more columns on v_harvest:
-- v_harvest is built in 70 and a later migration cannot add to it
-- without 70 failing the next time it is run.
--
-- One correction rides along. A lamb harvest could end up carrying the
-- standard *beef* "Remaining" sheet — eye fillet, scotch fillet — when
-- a Sales page that had been open since before the sheet was cleared
-- saved the harvest and wrote its old copy back. Such a sheet is taken
-- off; the page no longer writes a sheet nobody opened.
--
-- Each of the three functions is replaced whole: butcher_sheet() as
-- 75, shop_front() as 74, place_order() as 76, each with this.
--
-- Safe to run more than once.
-- ============================================================

alter table harvest add column if not exists boxes_for_sale int;
alter table harvest drop constraint if exists harvest_boxes_for_sale_check;
alter table harvest add constraint harvest_boxes_for_sale_check check (boxes_for_sale >= 0);

comment on column harvest.boxes_for_sale is
  'How many boxes this harvest has to sell, if typed. Blank means worked out: head x 2 for lamb, for-sale kg / the smallest box for beef. See v_harvest_balance.';

create or replace view v_harvest_balance with (security_invoker = on) as
select h.id, h.farm_id, h.code, h.kind, h.status, h.head,
       case when h.kind = 'lamb' then 2 end              as per_head,    -- boxes to an animal, where that is a fixed thing
       bk.box_kg,                                                        -- the smallest box this kind is sold in
       x.boxes,                                                          -- for sale; null if not yet knowable
       coalesce(s.boxes, 0)::int                         as boxes_sold,
       (x.boxes - coalesce(s.boxes, 0))::int             as boxes_left,
       h.boxes_for_sale                                                  -- as typed; null if worked out
  from harvest h
  left join lateral (
    select min(o.size_kg / greatest(o.cartons, 1)) as box_kg
      from product_option o
      join product p on p.id = o.product_id
     where p.farm_id = h.farm_id and p.kind = h.kind and p.from_harvest
       and p.active and o.active and o.size_kg > 0) bk on true
  cross join lateral (
    select coalesce(h.boxes_for_sale,
                    case when h.kind = 'lamb' then h.head * 2 end,
                    floor(coalesce(h.capacity_kg, h.carcass_kg * h.retail_ratio) / bk.box_kg)::int) as boxes) x
  left join lateral (
    select sum(l.qty * greatest(l.cartons, 1)) as boxes
      from order_line l
      join customer_order o on o.id = l.order_id
     where o.harvest_id = h.id and o.status <> 'cancelled' and l.for_butcher) s on true;

revoke all on v_harvest_balance from anon, authenticated;
grant select on v_harvest_balance to authenticated;

-- Beef cuts on a lamb harvest's "Remaining" sheet got there by
-- accident (see above). A sheet someone wrote for lamb is left alone.
update harvest h
   set remaining_sheet = null
 where h.kind = 'lamb'
   and h.remaining_sheet is not null
   and exists (
     select 1
       from jsonb_array_elements(case when jsonb_typeof(h.remaining_sheet -> 'rows') = 'array'
                                      then h.remaining_sheet -> 'rows' else '[]'::jsonb end) r
      where r ->> 0 in ('Eye Fillet', 'Scotch Fillet', 'Porterhouse', 'T-Bone', 'Rump Steak'));

-- ------------------------------------------------------------
-- butcher_sheet(): as 75, with the harvest's balance
-- ------------------------------------------------------------

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
    -- What there is to sell, what is on these sheets, and the difference (77).
    'balance', (select jsonb_build_object('boxes', b.boxes, 'sold', b.boxes_sold, 'left', b.boxes_left,
                                          'head', b.head, 'per_head', b.per_head, 'box_kg', b.box_kg)
                  from v_harvest_balance b where b.id = h.id),
    'remaining_sheet', h.remaining_sheet);
end $$;

-- ------------------------------------------------------------
-- shop_front(): as 74; a pack says how many boxes it is, and a
-- harvest how many it has and how many are left
-- ------------------------------------------------------------

create or replace function shop_front(p_farm text) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'farm', jsonb_build_object('name', f.name, 'email', b.email, 'phone', b.phone),
    'products', coalesce((
      select jsonb_agg(jsonb_build_object(
               'slug', p.slug, 'name', p.name, 'kind', p.kind, 'summary', p.summary,
               'description', p.description, 'image_url', p.image_url,
               'deposit_cents', p.deposit_cents, 'local_only', p.local_only,
               'from_harvest', p.from_harvest,
               'questions', coalesce(p.questions, '[]'::jsonb),
               'options', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'id', o.id, 'name', o.name, 'label', o.label,
                          'size_kg', o.size_kg, 'price_cents', o.price_cents,
                          'cartons', greatest(o.cartons, 1))
                        order by o.sort, o.price_cents)
                   from product_option o
                  where o.product_id = p.id and o.active), '[]'::jsonb))
             order by p.sort, p.name)
        from product p
       where p.farm_id = f.id and p.active), '[]'::jsonb),
    'harvests', coalesce((
      select jsonb_agg(jsonb_build_object(
               'code', h.code, 'kind', h.kind, 'status', h.status,
               'harvest_on', h.harvest_on, 'pickup_on', h.pickup_on,
               'delivery_on', h.delivery_on, 'interstate_on', h.interstate_on,
               'interstate_note', h.interstate_note,
               'pickup_place', h.pickup_place, 'pickup_hours', h.pickup_hours,
               -- The balance (77), in boxes. Never below nought here: the
               -- public is told there is none left, not by how much we are over.
               'head', h.head, 'per_head', b.per_head, 'box_kg', b.box_kg,
               'boxes', b.boxes, 'left_boxes', greatest(b.boxes_left, 0),
               'left_kg', case when coalesce(h.capacity_kg, h.carcass_kg * h.retail_ratio) is null then null
                               else greatest(coalesce(h.capacity_kg, round(h.carcass_kg * h.retail_ratio))
                                 - coalesce((select sum(l.qty * l.size_kg)
                                               from order_line l
                                               join customer_order o on o.id = l.order_id
                                              where o.harvest_id = h.id and o.status <> 'cancelled'), 0), 0)
                          end)
             order by h.harvest_on)
        from harvest h
        join v_harvest_balance b on b.id = h.id
       where h.farm_id = f.id
         and h.status in ('planned', 'open', 'closed')
         and coalesce(h.pickup_on, h.harvest_on) >= farm_today() - 7), '[]'::jsonb))
    from farm f
    left join farm_business b on b.farm_id = f.id
   where f.slug = p_farm
$$;

-- ------------------------------------------------------------
-- place_order(): as 76; the order goes on the first open harvest
-- of its kind with room for it
-- ------------------------------------------------------------

create or replace function place_order(p_farm text, p jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  fid     uuid;
  cid     uuid;
  oid     uuid;
  hid     uuid;
  ono     int;
  n       int;
  n_ok    int;
  kinds   text[];
  dep     int;
  need    int;     -- boxes this order would take from a harvest
  mailed  boolean := false;
  v_name  text := btrim(coalesce(p ->> 'name', ''));
  v_email text := lower(btrim(coalesce(p ->> 'email', '')));
  v_phone text := btrim(coalesce(p ->> 'phone', ''));
  v_ful   text := coalesce(nullif(p ->> 'fulfilment', ''), 'pickup_butcher');
  v_street text := nullif(btrim(coalesce(p ->> 'street', '')), '');
  v_suburb text := nullif(btrim(coalesce(p ->> 'suburb', '')), '');
  v_state  text := nullif(upper(btrim(coalesce(p ->> 'state', ''))), '');
  v_pc     text := nullif(btrim(coalesce(p ->> 'postcode', '')), '');
begin
  select id into fid from farm where slug = p_farm;
  if fid is null then
    raise exception 'Unknown shop';
  end if;

  -- The trap. Looks like success; writes nothing.
  if coalesce(p ->> 'website', '') <> '' then
    return jsonb_build_object('ref', 'BF-0000', 'deposit_cents', 0);
  end if;

  if length(v_name) < 2 or length(v_name) > 120 then
    raise exception 'Please tell us your name';
  end if;
  if length(v_email) > 200 or v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'That email address does not look right';
  end if;
  if length(v_phone) < 6 or length(v_phone) > 40 then
    raise exception 'Please give us a phone number';
  end if;
  if v_ful not in ('pickup_farm', 'pickup_butcher', 'delivery') then
    raise exception 'Pick-up or delivery?';
  end if;
  if v_ful = 'delivery' and (v_street is null or v_suburb is null or v_state is null or v_pc is null) then
    raise exception 'For delivery we need the full address';
  end if;
  if length(coalesce(p ->> 'note', '')) > 2000 or length(coalesce(v_street, '')) > 200
     or length(coalesce(v_suburb, '')) > 100 or length(coalesce(v_pc, '')) > 10
     or length(coalesce(p ->> 'company', '')) > 120 or length(coalesce(p ->> 'instructions', '')) > 500 then
    raise exception 'One of those answers is too long';
  end if;
  if jsonb_typeof(p -> 'items') is distinct from 'array' then
    raise exception 'Nothing was ordered';
  end if;

  select count(*), count(pr.id),
         array_agg(distinct pr.kind) filter (where pr.from_harvest),
         coalesce(sum(w.qty * pr.deposit_cents), 0),
         coalesce(sum(w.qty * greatest(o.cartons, 1)) filter (where pr.from_harvest), 0)
    into n, n_ok, kinds, dep, need
    from (select (x ->> 'option_id')::uuid as option_id,
                 least(greatest(coalesce((x ->> 'qty')::int, 1), 1), 20) as qty
            from jsonb_array_elements(p -> 'items') as t(x)) w
    left join product_option o on o.id = w.option_id and o.farm_id = fid and o.active
    left join product pr       on pr.id = o.product_id and pr.active;
  if n = 0 or n > 20 then
    raise exception 'Nothing was ordered';
  end if;
  if n_ok <> n then
    raise exception 'Something in that order is no longer available. Please refresh the page and try again.';
  end if;

  if (select count(*) from customer_order o join customer c on c.id = o.customer_id
       where o.farm_id = fid and o.source = 'web' and lower(c.email) = v_email
         and o.created_at > now() - interval '1 hour') >= 5
     or (select count(*) from customer_order o
          where o.farm_id = fid and o.source = 'web'
            and o.created_at > now() - interval '1 hour') >= 40 then
    raise exception 'We could not take that order just now. Please email us instead.';
  end if;

  select id into cid from customer
   where farm_id = fid and lower(email) = v_email
   order by created_at limit 1;
  if cid is null then
    insert into customer (farm_id, name, company, email, phone, street, suburb, state, postcode, source)
    values (fid, v_name, nullif(btrim(coalesce(p ->> 'company', '')), ''), v_email, v_phone,
            v_street, v_suburb, v_state, v_pc, 'web')
    returning id into cid;
  end if;

  -- One kind of pack: it goes on that kind's open harvest. Beef and
  -- lamb together, or nothing open: left for a person to place.
  -- (77) ...with room for it. A harvest whose balance is not known
  -- yet has room; a full one is passed over, as a closed one is.
  if array_length(kinds, 1) = 1 then
    -- Two orders in the same instant must not both take the last box.
    perform pg_advisory_xact_lock(hashtext('harvest_room'), hashtext(fid::text));
    select h.id into hid
      from harvest h
      join v_harvest_balance b on b.id = h.id
     where h.farm_id = fid and h.kind = kinds[1] and h.status = 'open'
       and (b.boxes is null or b.boxes_left >= need)
     order by h.harvest_on limit 1;
  end if;

  insert into customer_order (farm_id, customer_id, harvest_id, source, status, fulfilment,
                              ship_name, ship_phone, ship_street, ship_suburb, ship_state,
                              ship_postcode, ship_instructions, customer_note)
  values (fid, cid, hid, 'web', 'new', v_ful, v_name, v_phone, v_street, v_suburb, v_state, v_pc,
          nullif(btrim(coalesce(p ->> 'instructions', '')), ''),
          nullif(btrim(coalesce(p ->> 'note', '')), ''))
  returning id, order_no into oid, ono;

  insert into order_line (order_id, product_option_id, description, qty, size_kg, unit_cents,
                          gst_rate, cartons, for_butcher, answers, sort)
  select oid, o.id, o.name, w.qty, o.size_kg, o.price_cents, pr.gst_rate, o.cartons,
         pr.from_harvest, answers_for(pr.questions, w.answers), w.ord
    from (select (x ->> 'option_id')::uuid as option_id,
                 least(greatest(coalesce((x ->> 'qty')::int, 1), 1), 20) as qty,
                 x -> 'answers' as answers, ord
            from jsonb_array_elements(p -> 'items') with ordinality as t(x, ord)) w
    join product_option o on o.id = w.option_id
    join product pr       on pr.id = o.product_id;

  -- The emails come last and in a block of their own: whatever goes
  -- wrong in writing them is undone alone, and the order stands.
  begin
    if (select b.email_web_orders and coalesce(b.email, '') <> ''
          from farm_business b where b.farm_id = fid) then
      perform queue_order_mail(oid, true, true);
      mailed := true;
    end if;
  exception when others then
    mailed := false;
  end;

  return jsonb_build_object(
    'ref', order_ref((select order_prefix from farm_business where farm_id = fid), ono),
    'deposit_cents', dep,
    'harvest', (select jsonb_build_object('pickup_on', h.pickup_on, 'delivery_on', h.delivery_on,
                                          'interstate_on', h.interstate_on, 'pickup_place', h.pickup_place)
                  from harvest h where h.id = hid),
    'emailed', mailed);
end $$;

notify pgrst, 'reload schema';
