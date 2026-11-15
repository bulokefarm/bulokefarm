-- ============================================================
-- 74. The one thing a customer chooses: soup bones, or not.
--
-- The old shop's beef form had twelve fields: a free-text box for
-- every cut — blade, chuck, brisket, how would you like it — and one
-- real choice, soup bones yes or none. In five years the boxes were
-- filled in a handful of times, each a small promise the butcher
-- then had to keep for one pack among a dozen. They are not coming
-- across. A pack is what the cut sheet says it is.
--
-- The choice is. So a product may ask questions, and a question is a
-- label and a short list of answers to pick from — never a box to
-- type in:
--
--   product.questions   [{"label": "Soup bones", "choices": ["Yes please", "None"]}]
--   order_line.answers  {"Soup bones": "None"}
--
-- The first choice is the standard one: it is what an order gets if
-- nothing is said, and what the form shows already picked. The
-- website sends what was picked; place_order() keeps only answers to
-- questions the product really asks, from the choices it really
-- offers, so nothing typed into a request can reach the butcher's
-- sheet. The answer prints on the box's cut sheet and against the
-- box in the customer list.
--
-- Four functions learn the two columns, each replaced whole:
-- shop_front() hands the questions out, place_order() and
-- save_order() write the answers, butcher_sheet() prints them.
--
-- Safe to run more than once.
-- ============================================================

alter table product    add column if not exists questions jsonb;
alter table order_line add column if not exists answers   jsonb;

comment on column product.questions is
  '[{"label", "choices": [...]}] — asked once per pack on the order form. Choices only; the first is the default. [] means none, on purpose.';
comment on column order_line.answers is
  '{"label": "choice"} for the questions the product asked when this was ordered.';

-- What an order's answers are, given what the product asks and what
-- was sent: every question answered, with a choice it offers, the
-- first if nothing valid was said. No questions, no answers (null).
create or replace function answers_for(p_questions jsonb, p_given jsonb) returns jsonb
language sql immutable set search_path = public as $$
  select jsonb_object_agg(
           q ->> 'label',
           coalesce((select g.value
                       from jsonb_each_text(case when jsonb_typeof(p_given) = 'object' then p_given else '{}'::jsonb end) g
                      where g.key = q ->> 'label' and (q -> 'choices') ? g.value),
                    q -> 'choices' ->> 0))
    from jsonb_array_elements(case when jsonb_typeof(p_questions) = 'array' then p_questions else '[]'::jsonb end) q
   where coalesce(q ->> 'label', '') <> ''
     and jsonb_typeof(q -> 'choices') = 'array' and jsonb_array_length(q -> 'choices') > 0
$$;

-- Buloke's beef asks about soup bones. Set once: a product whose
-- questions are null has never been asked about; one that was
-- cleared on purpose holds [] and is left alone. (On a rebuild the
-- product does not exist yet when this runs; seed 60 carries it.)
update product
   set questions = '[{"label": "Soup bones", "choices": ["Yes please", "None"]}]'::jsonb
 where farm_id = (select id from farm where slug = 'buloke')
   and slug = 'beef' and questions is null;

-- ------------------------------------------------------------
-- shop_front(): as 72, with each product's questions
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

-- ------------------------------------------------------------
-- place_order(): as 72; each item may carry "answers"
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
                          gst_rate, cartons, for_butcher, answers, sort)
  select oid, o.id, o.name, w.qty, o.size_kg, o.price_cents, pr.gst_rate, o.cartons,
         pr.from_harvest, answers_for(pr.questions, w.answers), w.ord
    from (select (x ->> 'option_id')::uuid as option_id,
                 least(greatest(coalesce((x ->> 'qty')::int, 1), 1), 20) as qty,
                 x -> 'answers' as answers, ord
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

-- ------------------------------------------------------------
-- save_order(): as 70; a line's answers are saved with it
-- ------------------------------------------------------------

create or replace function save_order(p jsonb) returns uuid
language plpgsql set search_path = public as $$
declare
  r    customer_order;
  l    order_line;
  ln   jsonb;
  keep uuid[] := '{}';
  n    int := 0;
begin
  if jsonb_typeof(p -> 'lines') is distinct from 'array' or jsonb_array_length(p -> 'lines') = 0 then
    raise exception 'An order needs at least one line';
  end if;
  r := jsonb_populate_record(null::customer_order, blank_to_null(p - 'lines'));
  if r.customer_id is null then
    raise exception 'An order needs a customer';
  end if;

  if r.id is null then
    insert into customer_order (
      customer_id, harvest_id, placed_on, source, status, fulfilment,
      ship_name, ship_phone, ship_alt_phone, ship_street, ship_suburb, ship_state, ship_postcode,
      ship_type, ship_instructions, deliver_on, delivery_fee_cents,
      carrier, carrier_ref, carrier_no, tracking_url, customer_note, note)
    values (
      r.customer_id, r.harvest_id, coalesce(r.placed_on, farm_today()), coalesce(r.source, 'manual'),
      coalesce(r.status, 'new'), coalesce(r.fulfilment, 'pickup_butcher'),
      r.ship_name, r.ship_phone, r.ship_alt_phone, r.ship_street, r.ship_suburb, r.ship_state, r.ship_postcode,
      coalesce(r.ship_type, 'Residential'), r.ship_instructions, r.deliver_on, coalesce(r.delivery_fee_cents, 0),
      r.carrier, r.carrier_ref, r.carrier_no, r.tracking_url, r.customer_note, r.note)
    returning id into r.id;
  else
    update customer_order set
      customer_id = r.customer_id, harvest_id = r.harvest_id,
      placed_on = coalesce(r.placed_on, placed_on), source = coalesce(r.source, source),
      status = coalesce(r.status, status), fulfilment = coalesce(r.fulfilment, fulfilment),
      ship_name = r.ship_name, ship_phone = r.ship_phone, ship_alt_phone = r.ship_alt_phone,
      ship_street = r.ship_street, ship_suburb = r.ship_suburb, ship_state = r.ship_state,
      ship_postcode = r.ship_postcode, ship_type = coalesce(r.ship_type, ship_type),
      ship_instructions = r.ship_instructions, deliver_on = r.deliver_on,
      delivery_fee_cents = coalesce(r.delivery_fee_cents, 0),
      carrier = r.carrier, carrier_ref = r.carrier_ref, carrier_no = r.carrier_no,
      tracking_url = r.tracking_url, customer_note = r.customer_note, note = r.note
    where id = r.id;
    if not found then
      raise exception 'No such order on this farm';
    end if;
  end if;

  for ln in select * from jsonb_array_elements(p -> 'lines') loop
    n := n + 1;
    l := jsonb_populate_record(null::order_line, blank_to_null(ln));
    if coalesce(l.description, '') = '' then
      raise exception 'Line % has no description', n;
    end if;
    if l.id is null then
      insert into order_line (
        order_id, product_option_id, description, qty, size_kg, actual_kg, unit_cents,
        discount_cents, gst_rate, cartons, for_butcher, cut_sheet, answers, butcher_note, packed, sort)
      values (
        r.id, l.product_option_id, l.description, coalesce(l.qty, 1), l.size_kg, l.actual_kg,
        coalesce(l.unit_cents, 0), coalesce(l.discount_cents, 0), coalesce(l.gst_rate, 0),
        coalesce(l.cartons, 1), coalesce(l.for_butcher, true),
        case when jsonb_typeof(l.cut_sheet) = 'object' then l.cut_sheet end,
        case when jsonb_typeof(l.answers) = 'object' then l.answers end,
        l.butcher_note, coalesce(l.packed, false), n)
      returning id into l.id;
    else
      update order_line set
        product_option_id = l.product_option_id, description = l.description,
        qty = coalesce(l.qty, 1), size_kg = l.size_kg, actual_kg = l.actual_kg,
        unit_cents = coalesce(l.unit_cents, 0), discount_cents = coalesce(l.discount_cents, 0),
        gst_rate = coalesce(l.gst_rate, 0), cartons = coalesce(l.cartons, 1),
        for_butcher = coalesce(l.for_butcher, true),
        cut_sheet = case when jsonb_typeof(l.cut_sheet) = 'object' then l.cut_sheet end,
        answers = case when jsonb_typeof(l.answers) = 'object' then l.answers end,
        butcher_note = l.butcher_note, packed = coalesce(l.packed, false), sort = n
      where id = l.id and order_id = r.id;
      if not found then
        raise exception 'Line % is not on this order', n;
      end if;
    end if;
    keep := keep || l.id;
  end loop;

  delete from order_line where order_id = r.id and id <> all (keep);
  return r.id;
end $$;

-- ------------------------------------------------------------
-- butcher_sheet(): as 71; each box carries its line's answers
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
                 l.answers,
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

notify pgrst, 'reload schema';
