-- ============================================================
-- 72. The shop front: what someone with no login may ask.
--
-- The public website is static pages. Three things on it are not
-- static: what is for sale and when the next harvest is, whether the
-- carrier goes to a postcode, and placing an order. Each is one
-- function, run as owner, callable by anon — and they are the only
-- way in. Anon can read no table and no view but v_farm_public.
--
--   shop_front('buloke')            products, sizes, the harvests coming up
--   delivery_lookup('buloke', pc)   the carrier's zone and days for a postcode
--   place_order('buloke', {...})    writes the order; returns its reference
--
-- An order placed here is a request, not a sale: status 'new', source
-- 'web', nothing paid. It is confirmed, priced and invoiced from
-- /sales by someone who is signed in.
--
-- What place_order will not do:
--
--   It never changes an existing customer. Anyone can type anyone's
--   email address into a form; if that rewrote the address on file,
--   the form would be a way to redirect someone else's meat. A known
--   email reuses the customer row untouched, and what was typed this
--   time is kept on the order (ship_*), where a person can compare.
--
--   It does not trust a price. The browser sends an option id and a
--   quantity; the price, the size and the GST come from the product.
--
--   It does not take unlimited orders. Five an hour from one email,
--   forty an hour in all, then it asks people to write instead. A
--   field no person can see (website) is a trap for scripts: fill it
--   in and the order is accepted and thrown away.
--
-- Safe to run more than once.
-- ============================================================

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
               'options', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'id', o.id, 'name', o.name, 'label', o.label,
                          'size_kg', o.size_kg, 'price_cents', o.price_cents)
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
               'left_kg', case when coalesce(h.capacity_kg, h.carcass_kg * h.retail_ratio) is null then null
                               else greatest(coalesce(h.capacity_kg, round(h.carcass_kg * h.retail_ratio))
                                 - coalesce((select sum(l.qty * l.size_kg)
                                               from order_line l
                                               join customer_order o on o.id = l.order_id
                                              where o.harvest_id = h.id and o.status <> 'cancelled'), 0), 0)
                          end)
             order by h.harvest_on)
        from harvest h
       where h.farm_id = f.id
         and h.status in ('planned', 'open', 'closed')
         and coalesce(h.pickup_on, h.harvest_on) >= farm_today() - 7), '[]'::jsonb))
    from farm f
    left join farm_business b on b.farm_id = f.id
   where f.slug = p_farm
$$;

create or replace function delivery_lookup(p_farm text, p_postcode text) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
           'postcode', z.postcode, 'zone', string_agg(distinct z.zone, ' / '),
           'region', min(z.region),
           'days', array_remove(array[
             case when bool_or(z.mon) then 'Mon' end, case when bool_or(z.tue) then 'Tue' end,
             case when bool_or(z.wed) then 'Wed' end, case when bool_or(z.thu) then 'Thu' end,
             case when bool_or(z.fri) then 'Fri' end, case when bool_or(z.sat) then 'Sat' end], null))
    from delivery_zone z
    join farm f on f.id = z.farm_id
   where f.slug = p_farm and z.postcode = btrim(p_postcode)
   group by z.postcode
$$;

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
         coalesce(sum(w.qty * pr.deposit_cents), 0)
    into n, n_ok, kinds, dep
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
  if array_length(kinds, 1) = 1 then
    select id into hid from harvest
     where farm_id = fid and kind = kinds[1] and status = 'open'
     order by harvest_on limit 1;
  end if;

  insert into customer_order (farm_id, customer_id, harvest_id, source, status, fulfilment,
                              ship_name, ship_phone, ship_street, ship_suburb, ship_state,
                              ship_postcode, ship_instructions, customer_note)
  values (fid, cid, hid, 'web', 'new', v_ful, v_name, v_phone, v_street, v_suburb, v_state, v_pc,
          nullif(btrim(coalesce(p ->> 'instructions', '')), ''),
          nullif(btrim(coalesce(p ->> 'note', '')), ''))
  returning id, order_no into oid, ono;

  insert into order_line (order_id, product_option_id, description, qty, size_kg, unit_cents,
                          gst_rate, cartons, for_butcher, sort)
  select oid, o.id, o.name, w.qty, o.size_kg, o.price_cents, pr.gst_rate, o.cartons,
         pr.from_harvest, w.ord
    from (select (x ->> 'option_id')::uuid as option_id,
                 least(greatest(coalesce((x ->> 'qty')::int, 1), 1), 20) as qty, ord
            from jsonb_array_elements(p -> 'items') with ordinality as t(x, ord)) w
    join product_option o on o.id = w.option_id
    join product pr       on pr.id = o.product_id;

  return jsonb_build_object(
    'ref', order_ref((select order_prefix from farm_business where farm_id = fid), ono),
    'deposit_cents', dep,
    'harvest', (select jsonb_build_object('pickup_on', h.pickup_on, 'delivery_on', h.delivery_on,
                                          'interstate_on', h.interstate_on, 'pickup_place', h.pickup_place)
                  from harvest h where h.id = hid));
end $$;

revoke execute on function shop_front(text)            from public;
revoke execute on function delivery_lookup(text, text) from public;
revoke execute on function place_order(text, jsonb)    from public;
grant  execute on function shop_front(text)            to anon, authenticated;
grant  execute on function delivery_lookup(text, text) to anon, authenticated;
grant  execute on function place_order(text, jsonb)    to anon, authenticated;

notify pgrst, 'reload schema';
