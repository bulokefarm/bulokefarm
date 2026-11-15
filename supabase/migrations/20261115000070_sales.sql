-- ============================================================
-- 70. Selling the meat: products, harvests, customers, orders,
--     payments, invoices and where the carrier delivers.
--
-- Until now an order was a row in "Buloke Sales Orders.xlsx", a
-- butcher's order was a second workbook retyped from the first, the
-- delivery manifest a third retyped from the second, and the invoice
-- a fourth. One order, typed four times. This is the one place it is
-- written down; the butcher's sheets (71), the carrier's manifest and
-- the invoice are all read off it.
--
--   product ─── product_option          what is sold, and in what sizes
--   harvest                             one kill: its dates, what it yields
--   customer ── customer_order ─┬─ order_line      what they ordered
--                               ├─ order_payment   what they have paid
--                               └─ invoice ── invoice_line
--   delivery_zone                       postcode -> carrier zone and days
--   farm_business                       ABN, bank details: the invoice letterhead
--
-- The same rules as the rest of the schema:
--
--   Derived values are not stored. An order's total, what is still
--   owing, how many kilos of a harvest are sold — all computed on
--   read (v_order, v_harvest, v_invoice).
--
--   A balance is the sum of its movements. A deposit, the rest, a
--   refund are each a row in order_payment; "paid" is their total.
--
--   Nothing is silently rewritten. Orders, lines, payments, invoices,
--   customers and harvests all log every change.
--
--   An invoice keeps what it said. bill_to and ship_to are text
--   copied at the time, and its lines are its own rows: a customer
--   who moves house, or a price that changes, must not rewrite an
--   invoice already sent.
--
-- Money is integer cents, ex GST. Meat is GST-free; freight is not.
--
-- Safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The letterhead
-- ------------------------------------------------------------

create table if not exists farm_business (
  farm_id            uuid primary key default current_farm() references farm(id) on delete cascade,
  abn                text,
  phone              text,
  email              text,
  website            text,
  payment_details    text,                       -- printed under "Payment details", as typed
  invoice_terms_days int  not null default 14,
  order_prefix       text not null default 'BF', -- BF-0001; also the carrier's Order Identifier
  first_invoice_no   int  not null default 1     -- where numbering starts if another system came before
);

comment on table farm_business is
  'What the farm trades as on paper: ABN, contact, bank details. Entered in Sales -> Settings, never in the repo.';

-- ------------------------------------------------------------
-- 2. What is sold
-- ------------------------------------------------------------

create table if not exists product (
  id            uuid primary key default gen_random_uuid(),
  farm_id       uuid not null default current_farm() references farm(id),
  slug          text not null,
  name          text not null,
  kind          text not null default 'other' check (kind in ('beef', 'lamb', 'other')),
  summary       text,                 -- one line, on the shop tile
  description   text,                 -- the product page; a blank line starts a paragraph
  image_url     text,
  deposit_cents int  not null default 0 check (deposit_cents >= 0),
  gst_rate      numeric(4,2) not null default 0 check (gst_rate in (0, 10)),
  from_harvest  boolean not null default true,   -- cut to order from a kill; a pie is not
  local_only    boolean not null default false,  -- not sent by carrier
  cut_sheet     jsonb,                -- the standard butchering sheet for the smallest pack
  active        boolean not null default true,
  sort          int not null default 0,
  created_at    timestamptz not null default now(),
  constraint product_slug_ck check (slug ~ '^[a-z0-9-]{2,60}$')
);
create unique index if not exists product_farm_slug_uq on product (farm_id, slug);

comment on column product.cut_sheet is
  '{"columns": [...], "rows": [[...], ...], "notes": [[label, text], ...]} — what the butcher is asked to do for one pack.';
comment on column product.deposit_cents is
  'Asked for per pack when the order is placed. The balance is invoiced once it is packed.';

create table if not exists product_option (
  id            uuid primary key default gen_random_uuid(),
  farm_id       uuid not null references farm(id),
  product_id    uuid not null references product(id) on delete cascade,
  sku           text,
  name          text not null,        -- '12kg Beef Pack': how it reads on an invoice and a cut sheet
  label         text,                 -- 'Small': the short word for it in the shop
  size_kg       numeric(7,2),
  price_cents   int not null check (price_cents >= 0),   -- the estimate: size x rate
  cartons       int not null default 1 check (cartons >= 0),
  sheet_multiple numeric(5,2) not null default 1,  -- a 24 kg pack is the 12 kg sheet twice
  cut_sheet     jsonb,                -- only where this size has a sheet of its own
  active        boolean not null default true,
  sort          int not null default 0
);
create index if not exists product_option_product_idx on product_option (product_id);

-- ------------------------------------------------------------
-- 3. The harvest
-- ------------------------------------------------------------

create table if not exists harvest (
  id              uuid primary key default gen_random_uuid(),
  farm_id         uuid not null default current_farm() references farm(id),
  code            text not null,               -- H20260629
  kind            text not null check (kind in ('beef', 'lamb')),
  title           text,                        -- 'Cherry Tree · Blonde · Wagyu'
  harvest_on      date not null,
  butcher_on      date,
  pickup_on       date,
  delivery_on     date,                        -- local run
  interstate_on   date,
  interstate_note text,                        -- 'Sydney, Central Coast'
  butcher_name    text,
  pickup_place    text,
  pickup_hours    text,
  status          text not null default 'planned'
                    check (status in ('planned', 'open', 'closed', 'done')),
  butcher_released_at timestamptz,             -- when the butcher may see the sheets
  head            int check (head > 0),
  live_kg         numeric(8,1),
  carcass_kg      numeric(8,1),
  retail_ratio    numeric(4,3) not null default 0.66 check (retail_ratio > 0 and retail_ratio <= 1),
  capacity_kg     numeric(8,1),                -- offered for sale, if not carcass x ratio
  kill_fee_cents      int,
  butcher_rate_cents  int,                     -- per kg of cold carcass
  carton_fee_cents    int,                     -- per carton
  other_cost_cents    int,
  remaining_sheet jsonb,                       -- what happens to what is left over
  butcher_note    text,
  note            text,
  recorded_by     uuid references farm_user(id) default auth.uid(),
  created_at      timestamptz not null default now()
);
create unique index if not exists harvest_farm_code_uq on harvest (farm_id, code);

comment on column harvest.status is
  'planned: dates pencilled, shown on the site as "tbc". open: taking orders. closed: full. done: delivered and paid.';

-- ------------------------------------------------------------
-- 4. Customers
-- ------------------------------------------------------------

create table if not exists customer (
  id          uuid primary key default gen_random_uuid(),
  farm_id     uuid not null default current_farm() references farm(id),
  name        text not null,
  company     text,
  email       text,
  phone       text,
  alt_phone   text,
  street      text,
  suburb      text,
  state       text,
  postcode    text,
  country     text not null default 'Australia',
  abn         text,
  note        text,
  source      text not null default 'manual' check (source in ('manual', 'web', 'import')),
  recorded_by uuid references farm_user(id) default auth.uid(),
  created_at  timestamptz not null default now()
);
create index if not exists customer_farm_email_idx on customer (farm_id, lower(email));

-- ------------------------------------------------------------
-- 5. Orders
-- ------------------------------------------------------------

create table if not exists customer_order (
  id            uuid primary key default gen_random_uuid(),
  farm_id       uuid not null default current_farm() references farm(id),
  order_no      int  not null,                 -- per farm, handed out on insert
  customer_id   uuid not null references customer(id),
  harvest_id    uuid references harvest(id),
  placed_on     date not null default farm_today(),
  source        text not null default 'manual' check (source in ('manual', 'web', 'import')),
  status        text not null default 'new'
                  check (status in ('new', 'confirmed', 'packed', 'complete', 'cancelled')),
  fulfilment    text not null default 'pickup_butcher'
                  check (fulfilment in ('pickup_farm', 'pickup_butcher', 'delivery')),
  -- Who the box goes to. Blank means the customer, at their own address.
  ship_name     text,
  ship_phone    text,
  ship_alt_phone text,
  ship_street   text,
  ship_suburb   text,
  ship_state    text,
  ship_postcode text,
  ship_type     text not null default 'Residential' check (ship_type in ('Residential', 'Business')),
  ship_instructions text,
  deliver_on    date,
  delivery_fee_cents int not null default 0 check (delivery_fee_cents >= 0),
  carrier       text,
  carrier_ref   text,                          -- our Delivery Identifier on the manifest
  carrier_no    text,                          -- theirs, once booked (DET…)
  tracking_url  text,
  customer_note text,                          -- what they wrote
  note          text,                          -- what we wrote
  recorded_by   uuid references farm_user(id) default auth.uid(),
  created_at    timestamptz not null default now()
);
create unique index if not exists customer_order_no_uq on customer_order (farm_id, order_no);
create index if not exists customer_order_harvest_idx  on customer_order (harvest_id);
create index if not exists customer_order_customer_idx on customer_order (customer_id);

comment on column customer_order.status is
  'new: arrived, not yet looked at. confirmed: accepted. packed: weighed and boxed. complete: collected or delivered. Whether it is paid is not a status — see v_order.due_cents.';
comment on column customer_order.fulfilment is
  'pickup_farm: collected from us. pickup_butcher: collected from the butcher''s shop. delivery: sent by carrier.';

create table if not exists order_line (
  id            uuid primary key default gen_random_uuid(),
  farm_id       uuid not null references farm(id),
  order_id      uuid not null references customer_order(id) on delete cascade,
  product_option_id uuid references product_option(id),
  description   text not null,                 -- as it reads on the invoice
  qty           int  not null default 1 check (qty > 0),
  size_kg       numeric(7,2),                  -- each, as ordered
  actual_kg     numeric(7,2),                  -- all of them, as packed
  unit_cents    int  not null default 0,       -- each, ex GST, before discount
  discount_cents int not null default 0 check (discount_cents >= 0),  -- off the line
  gst_rate      numeric(4,2) not null default 0 check (gst_rate in (0, 10)),
  cartons       int  not null default 1 check (cartons >= 0),         -- each
  for_butcher   boolean not null default true, -- goes on a cut sheet
  cut_sheet     jsonb,                         -- only if it differs from the pack's own
  butcher_note  text,
  packed        boolean not null default false,
  sort          int not null default 0,
  created_at    timestamptz not null default now()
);
create index if not exists order_line_order_idx on order_line (order_id);

create table if not exists order_payment (
  id           uuid primary key default gen_random_uuid(),
  farm_id      uuid not null references farm(id),
  order_id     uuid not null references customer_order(id),
  paid_on      date not null default farm_today(),
  amount_cents int  not null check (amount_cents <> 0),   -- negative is a refund
  method       text not null default 'bank' check (method in ('bank', 'card', 'cash', 'other')),
  reference    text,
  note         text,
  recorded_by  uuid references farm_user(id) default auth.uid(),
  created_at   timestamptz not null default now()
);
create index if not exists order_payment_order_idx on order_payment (order_id);

-- ------------------------------------------------------------
-- 6. Invoices
-- ------------------------------------------------------------

create table if not exists invoice (
  id          uuid primary key default gen_random_uuid(),
  farm_id     uuid not null default current_farm() references farm(id),
  invoice_no  int  not null,                   -- per farm, handed out on insert
  order_id    uuid not null references customer_order(id),
  customer_id uuid not null references customer(id),
  issued_on   date not null default farm_today(),
  due_on      date,
  bill_to     text not null,
  ship_to     text,
  ship_on     date,
  ship_via    text,
  tracking    text,
  note        text,
  sent_on     date,
  void        boolean not null default false,  -- a number once given is never reused
  recorded_by uuid references farm_user(id) default auth.uid(),
  created_at  timestamptz not null default now()
);
create unique index if not exists invoice_no_uq on invoice (farm_id, invoice_no);
create index if not exists invoice_order_idx on invoice (order_id);

create table if not exists invoice_line (
  id          uuid primary key default gen_random_uuid(),
  farm_id     uuid not null references farm(id),
  invoice_id  uuid not null references invoice(id) on delete cascade,
  description text not null,
  qty         numeric(9,2) not null default 1,
  rate_cents  int not null default 0,          -- ex GST; negative for a discount line
  gst_rate    numeric(4,2) not null default 0 check (gst_rate in (0, 10)),
  shipping    boolean not null default false,  -- shown under SHIPPING, not in the lines
  sort        int not null default 0
);
create index if not exists invoice_line_invoice_idx on invoice_line (invoice_id);

-- ------------------------------------------------------------
-- 7. Where the carrier goes, and on which days
-- ------------------------------------------------------------

create table if not exists delivery_zone (
  id        uuid primary key default gen_random_uuid(),
  farm_id   uuid not null default current_farm() references farm(id),
  carrier   text not null default 'Blackbird Logistics',
  region    text not null,                     -- which schedule: 'VIC', 'National'
  postcode  text not null,
  suburb    text not null,
  zone      text not null,                     -- the carrier's Delivery Zone ID
  mon boolean not null default false, tue boolean not null default false,
  wed boolean not null default false, thu boolean not null default false,
  fri boolean not null default false, sat boolean not null default false
);
create unique index if not exists delivery_zone_uq
  on delivery_zone (farm_id, carrier, postcode, lower(suburb));
create index if not exists delivery_zone_postcode_idx on delivery_zone (farm_id, postcode);

-- ------------------------------------------------------------
-- 8. Every row is on a farm (as 54)
-- ------------------------------------------------------------

do $$
declare
  kids jsonb := '{
    "product_option": ["product", "product_id"],
    "customer_order": ["customer", "customer_id", "harvest", "harvest_id"],
    "order_line":     ["customer_order", "order_id", "product_option", "product_option_id"],
    "order_payment":  ["customer_order", "order_id"],
    "invoice":        ["customer_order", "order_id", "customer", "customer_id"],
    "invoice_line":   ["invoice", "invoice_id"]
  }'::jsonb;
  t    text;
  args text;
begin
  for t in select jsonb_object_keys(kids) loop
    select string_agg(quote_literal(x), ', ') into args
      from jsonb_array_elements_text(kids -> t) x;
    execute format('drop trigger if exists %I on %I', t || '_farm', t);
    execute format(
      'create trigger %I before insert or update on %I for each row execute function farm_id_from_parent(%s)',
      t || '_farm', t, args);
  end loop;

  foreach t in array array['product', 'product_option', 'harvest', 'customer', 'customer_order',
                           'order_line', 'order_payment', 'invoice', 'invoice_line', 'delivery_zone'] loop
    execute format('create index if not exists %I on %I (farm_id)', t || '_farm_idx', t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 9. Numbers handed out per farm
--
-- Not a sequence: a sequence is one per database, and two farms each
-- want to start at 1 — or at 1350, where the last system stopped.
-- The advisory lock makes two orders saved in the same instant queue
-- rather than collide on the unique index. Definer, because the
-- highest number so far must be found whoever is asking — a website
-- order arrives with no login at all.
--
-- The trigger names sort after *_farm, so farm_id is already set.
-- ------------------------------------------------------------

create or replace function next_order_no() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.order_no is null then
    perform pg_advisory_xact_lock(hashtext('customer_order_no'), hashtext(new.farm_id::text));
    select coalesce(max(order_no), 0) + 1 into new.order_no
      from customer_order where farm_id = new.farm_id;
  end if;
  return new;
end $$;

create or replace function next_invoice_no() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.invoice_no is null then
    perform pg_advisory_xact_lock(hashtext('invoice_no'), hashtext(new.farm_id::text));
    select greatest(coalesce(max(i.invoice_no), 0) + 1,
                    coalesce((select b.first_invoice_no from farm_business b
                               where b.farm_id = new.farm_id), 1))
      into new.invoice_no
      from invoice i where i.farm_id = new.farm_id;
  end if;
  return new;
end $$;

revoke execute on function next_order_no()   from public, anon, authenticated;
revoke execute on function next_invoice_no() from public, anon, authenticated;

drop trigger if exists customer_order_no on customer_order;
create trigger customer_order_no before insert on customer_order
  for each row execute function next_order_no();

drop trigger if exists invoice_no on invoice;
create trigger invoice_no before insert on invoice
  for each row execute function next_invoice_no();

-- BF-0042. Not lpad alone: lpad truncates, and order 12345 is not 1234.
create or replace function order_ref(p_prefix text, p_no int) returns text
language sql immutable set search_path = public as $$
  select coalesce(nullif(p_prefix, ''), 'BF') || '-' ||
         case when p_no < 10000 then lpad(p_no::text, 4, '0') else p_no::text end
$$;

-- ------------------------------------------------------------
-- 10. Change log
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['customer', 'harvest', 'customer_order', 'order_line',
                           'order_payment', 'invoice', 'invoice_line'] loop
    execute format('drop trigger if exists %I on %I', t || '_changed', t);
    execute format('create trigger %I after update or delete on %I
                    for each row execute function log_record_change()', t || '_changed', t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 11. Who may do what
--
-- The standard four (55): read if you read the farm, write if you
-- record, delete if you own it. Two exceptions. Taking a line off an
-- order, or off an invoice, is an edit — a manager may. And the
-- letterhead, with the bank details on it, is the owner's to change.
-- ------------------------------------------------------------

alter table farm_business  enable row level security;
alter table product        enable row level security;
alter table product_option enable row level security;
alter table harvest        enable row level security;
alter table customer       enable row level security;
alter table customer_order enable row level security;
alter table order_line     enable row level security;
alter table order_payment  enable row level security;
alter table invoice        enable row level security;
alter table invoice_line   enable row level security;
alter table delivery_zone  enable row level security;

do $$
declare
  t text;
  line_like text[] := array['order_line', 'invoice_line', 'product_option'];
begin
  foreach t in array array['product', 'product_option', 'harvest', 'customer', 'customer_order',
                           'order_line', 'order_payment', 'invoice', 'invoice_line', 'delivery_zone'] loop
    execute format('drop policy if exists %I on %I', t || '_read',   t);
    execute format('drop policy if exists %I on %I', t || '_insert', t);
    execute format('drop policy if exists %I on %I', t || '_update', t);
    execute format('drop policy if exists %I on %I', t || '_delete', t);

    execute format($p$create policy %I on %I for select to authenticated
      using (farm_id = (select current_farm()) and can_read())$p$, t || '_read', t);
    execute format($p$create policy %I on %I for insert to authenticated
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_insert', t);
    execute format($p$create policy %I on %I for update to authenticated
      using      (farm_id = (select current_farm()) and can_write())
      with check (farm_id = (select current_farm()) and can_write())$p$, t || '_update', t);
    if t = any (line_like) then
      execute format($p$create policy %I on %I for delete to authenticated
        using (farm_id = (select current_farm()) and can_write())$p$, t || '_delete', t);
    else
      execute format($p$create policy %I on %I for delete to authenticated
        using (farm_id = (select current_farm()) and my_role() = 'owner')$p$, t || '_delete', t);
    end if;
  end loop;
end $$;

drop policy if exists farm_business_read  on farm_business;
drop policy if exists farm_business_write on farm_business;
create policy farm_business_read on farm_business
  for select to authenticated using (farm_id = (select current_farm()) and can_read());
create policy farm_business_write on farm_business
  for all to authenticated
  using      (farm_id = (select current_farm()) and my_role() = 'owner')
  with check (farm_id = (select current_farm()) and my_role() = 'owner');

-- Said out loud (see 53): the cloud grants these by default, a local
-- stack does not. RLS decides; the grant only lets the API ask.
grant select, insert, update, delete on
  farm_business, product, product_option, harvest, customer, customer_order,
  order_line, order_payment, invoice, invoice_line, delivery_zone
  to authenticated;

-- ------------------------------------------------------------
-- 12. What the pages read
-- ------------------------------------------------------------

-- An order with its sums. GST on a line is the line's rate; freight
-- always carries 10%.
drop view if exists v_harvest;
drop view if exists v_customer;
drop view if exists v_order;
create view v_order with (security_invoker = on) as
select o.id, o.farm_id, o.order_no,
       order_ref(fb.order_prefix, o.order_no)                    as ref,
       o.customer_id, c.name as customer_name, c.company as customer_company,
       c.email as customer_email, c.phone as customer_phone,
       o.harvest_id, h.code as harvest_code, h.kind as harvest_kind,
       o.placed_on, o.source, o.status, o.fulfilment,
       coalesce(nullif(o.ship_name, ''), c.name)                 as to_name,
       coalesce(nullif(o.ship_phone, ''), c.phone)               as to_phone,
       coalesce(nullif(o.ship_alt_phone, ''), c.alt_phone)       as to_alt_phone,
       case when coalesce(o.ship_street, '') <> '' then o.ship_street   else c.street   end as to_street,
       case when coalesce(o.ship_street, '') <> '' then o.ship_suburb   else c.suburb   end as to_suburb,
       case when coalesce(o.ship_street, '') <> '' then o.ship_state    else c.state    end as to_state,
       case when coalesce(o.ship_street, '') <> '' then o.ship_postcode else c.postcode end as to_postcode,
       o.ship_name, o.ship_phone, o.ship_alt_phone, o.ship_street, o.ship_suburb,
       o.ship_state, o.ship_postcode, o.ship_type, o.ship_instructions,
       o.deliver_on, o.delivery_fee_cents, o.carrier, o.carrier_ref, o.carrier_no, o.tracking_url,
       o.customer_note, o.note, o.created_at,
       coalesce(t.items, '')                                     as items,
       coalesce(t.packs, 0)::int                                 as packs,
       coalesce(t.kg, 0)                                         as kg,
       t.actual_kg,
       coalesce(t.cartons, 0)::int                               as cartons,
       coalesce(t.goods_cents, 0)::int                           as goods_cents,
       (coalesce(t.gst_cents, 0) + round(o.delivery_fee_cents * 0.10))::int as gst_cents,
       (coalesce(t.goods_cents, 0) + o.delivery_fee_cents
          + coalesce(t.gst_cents, 0) + round(o.delivery_fee_cents * 0.10))::int as total_cents,
       coalesce(p.paid_cents, 0)::int                            as paid_cents,
       (coalesce(t.goods_cents, 0) + o.delivery_fee_cents
          + coalesce(t.gst_cents, 0) + round(o.delivery_fee_cents * 0.10)
          - coalesce(p.paid_cents, 0))::int                      as due_cents,
       least(coalesce(t.deposit_cents, 0), coalesce(t.goods_cents, 0))::int as deposit_cents,
       coalesce(t.unpacked, 0)::int                              as unpacked,
       i.invoices
  from customer_order o
  join customer c            on c.id = o.customer_id
  left join harvest h        on h.id = o.harvest_id
  left join farm_business fb on fb.farm_id = o.farm_id
  left join lateral (
    select string_agg(l.qty || ' × ' || l.description, ', ' order by l.sort, l.created_at) as items,
           sum(l.qty) filter (where l.for_butcher)                as packs,
           sum(l.qty * l.size_kg)                                 as kg,
           sum(l.actual_kg)                                       as actual_kg,
           sum(l.qty * l.cartons)                                 as cartons,
           sum(l.qty * l.unit_cents - l.discount_cents)           as goods_cents,
           sum(round((l.qty * l.unit_cents - l.discount_cents) * l.gst_rate / 100.0)) as gst_cents,
           sum(l.qty * coalesce(pr.deposit_cents, 0))             as deposit_cents,
           count(*) filter (where l.for_butcher and not l.packed) as unpacked
      from order_line l
      left join product_option po on po.id = l.product_option_id
      left join product pr        on pr.id = po.product_id
     where l.order_id = o.id) t on true
  left join lateral (
    select sum(amount_cents) as paid_cents from order_payment p where p.order_id = o.id) p on true
  left join lateral (
    select string_agg(i.invoice_no::text, ', ' order by i.invoice_no) as invoices
      from invoice i where i.order_id = o.id and not i.void) i on true;

-- A harvest with what has been sold out of it. Cancelled orders are
-- not sold.
create view v_harvest with (security_invoker = on) as
select h.id, h.farm_id, h.code, h.kind, h.title, h.harvest_on, h.butcher_on, h.pickup_on,
       h.delivery_on, h.interstate_on, h.interstate_note, h.butcher_name, h.pickup_place,
       h.pickup_hours, h.status, h.butcher_released_at, h.head, h.live_kg, h.carcass_kg,
       h.retail_ratio, h.capacity_kg, h.kill_fee_cents, h.butcher_rate_cents,
       h.carton_fee_cents, h.other_cost_cents, h.remaining_sheet, h.butcher_note, h.note,
       h.created_at,
       coalesce(h.capacity_kg, round(h.carcass_kg * h.retail_ratio))  as for_sale_kg,
       coalesce(s.orders, 0)::int      as orders,
       coalesce(s.packs, 0)::int       as packs,
       coalesce(s.kg, 0)               as sold_kg,
       coalesce(s.cartons, 0)::int     as cartons,
       coalesce(s.deliveries, 0)::int  as deliveries,
       coalesce(s.total_cents, 0)::int as total_cents,
       coalesce(s.paid_cents, 0)::int  as paid_cents,
       coalesce(s.delivery_fee_cents, 0)::int as delivery_fee_cents,
       (coalesce(h.kill_fee_cents, 0)
          + round(coalesce(h.butcher_rate_cents, 0) * coalesce(h.carcass_kg, 0))
          + coalesce(h.carton_fee_cents, 0) * coalesce(s.cartons, 0)
          + coalesce(h.other_cost_cents, 0))::int as cost_cents
  from harvest h
  left join lateral (
    select count(*)                                    as orders,
           sum(o.packs)                                as packs,
           sum(o.kg)                                   as kg,
           sum(o.cartons)                              as cartons,
           count(*) filter (where o.fulfilment = 'delivery') as deliveries,
           sum(o.total_cents)                          as total_cents,
           sum(o.paid_cents)                           as paid_cents,
           sum(o.delivery_fee_cents)                   as delivery_fee_cents
      from v_order o
     where o.harvest_id = h.id and o.status <> 'cancelled') s on true;

create view v_customer with (security_invoker = on) as
select c.id, c.farm_id, c.name, c.company, c.email, c.phone, c.alt_phone, c.street, c.suburb,
       c.state, c.postcode, c.country, c.abn, c.note, c.source, c.created_at,
       coalesce(s.orders, 0)::int      as orders,
       s.last_order_on,
       coalesce(s.total_cents, 0)::int as total_cents,
       coalesce(s.due_cents, 0)::int   as due_cents
  from customer c
  left join lateral (
    select count(*) as orders, max(o.placed_on) as last_order_on,
           sum(o.total_cents) as total_cents, sum(o.due_cents) as due_cents
      from v_order o
     where o.customer_id = c.id and o.status <> 'cancelled') s on true;

-- An invoice with its sums, and the two lines of a BAS summary.
-- What has been paid is what has been paid on the order.
drop view if exists v_invoice;
create view v_invoice with (security_invoker = on) as
select i.id, i.farm_id, i.invoice_no, i.order_id, i.customer_id, i.issued_on, i.due_on,
       i.bill_to, i.ship_to, i.ship_on, i.ship_via, i.tracking, i.note, i.sent_on, i.void,
       i.created_at,
       c.name as customer_name, c.email as customer_email,
       order_ref(fb.order_prefix, o.order_no)                     as order_ref,
       coalesce(t.subtotal_cents, 0)::int                         as subtotal_cents,
       coalesce(t.shipping_cents, 0)::int                         as shipping_cents,
       coalesce(t.gst_cents, 0)::int                              as gst_cents,
       (coalesce(t.subtotal_cents, 0) + coalesce(t.shipping_cents, 0)
          + coalesce(t.gst_cents, 0))::int                        as total_cents,
       coalesce(t.net_free_cents, 0)::int                         as net_free_cents,
       coalesce(t.net_taxed_cents, 0)::int                        as net_taxed_cents,
       coalesce(p.paid_cents, 0)::int                             as paid_cents,
       greatest(coalesce(t.subtotal_cents, 0) + coalesce(t.shipping_cents, 0)
          + coalesce(t.gst_cents, 0) - coalesce(p.paid_cents, 0), 0)::int as due_cents
  from invoice i
  join customer c            on c.id = i.customer_id
  join customer_order o      on o.id = i.order_id
  left join farm_business fb on fb.farm_id = i.farm_id
  left join lateral (
    select sum(round(l.qty * l.rate_cents)) filter (where not l.shipping) as subtotal_cents,
           sum(round(l.qty * l.rate_cents)) filter (where l.shipping)     as shipping_cents,
           sum(round(round(l.qty * l.rate_cents) * l.gst_rate / 100.0))   as gst_cents,
           sum(round(l.qty * l.rate_cents)) filter (where l.gst_rate = 0) as net_free_cents,
           sum(round(l.qty * l.rate_cents)) filter (where l.gst_rate > 0) as net_taxed_cents
      from invoice_line l where l.invoice_id = i.id) t on true
  left join lateral (
    select sum(amount_cents) as paid_cents from order_payment p where p.order_id = i.order_id) p on true;

-- One row per postcode: the zone and the days the carrier is there.
drop view if exists v_delivery_postcode;
create view v_delivery_postcode with (security_invoker = on) as
select farm_id, carrier, postcode,
       min(region)                               as region,
       string_agg(distinct zone, ' / ')          as zone,
       string_agg(distinct suburb, ', ')         as suburbs,
       bool_or(mon) as mon, bool_or(tue) as tue, bool_or(wed) as wed,
       bool_or(thu) as thu, bool_or(fri) as fri, bool_or(sat) as sat
  from delivery_zone
 group by farm_id, carrier, postcode;

grant select on v_order, v_harvest, v_customer, v_invoice, v_delivery_postcode to authenticated;

-- ------------------------------------------------------------
-- 13. Saving an order in one piece
--
-- The browser sends one statement at a time (see record_spray, 40):
-- an order and its lines saved as separate requests can half-save,
-- and an order with no lines is a box of nothing. One call, one
-- transaction. Runs as the caller, so RLS decides who may.
--
-- p: the order's columns, plus "lines": [{id?, product_option_id,
-- description, qty, size_kg, actual_kg, unit_cents, discount_cents,
-- gst_rate, cartons, for_butcher, cut_sheet, butcher_note, packed}].
-- A line with an id is updated; one without is added; one that is on
-- the order but not in the list is removed.
-- ------------------------------------------------------------

-- '' from a form field means "nothing"; jsonb_populate_record would
-- try to read it as a date or a uuid and refuse the whole order.
create or replace function blank_to_null(p jsonb) returns jsonb
language sql immutable set search_path = public as $$
  select coalesce(jsonb_object_agg(k, case when v = '""'::jsonb then 'null'::jsonb else v end), '{}'::jsonb)
    from jsonb_each(p) as e(k, v)
$$;

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
        discount_cents, gst_rate, cartons, for_butcher, cut_sheet, butcher_note, packed, sort)
      values (
        r.id, l.product_option_id, l.description, coalesce(l.qty, 1), l.size_kg, l.actual_kg,
        coalesce(l.unit_cents, 0), coalesce(l.discount_cents, 0), coalesce(l.gst_rate, 0),
        coalesce(l.cartons, 1), coalesce(l.for_butcher, true),
        case when jsonb_typeof(l.cut_sheet) = 'object' then l.cut_sheet end,
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

revoke execute on function save_order(jsonb) from public, anon;
grant  execute on function save_order(jsonb) to authenticated;

-- ------------------------------------------------------------
-- 14. Raising the invoice for an order
--
-- Copies the order as it stands: who, where, each line, the freight.
-- From then on the invoice is its own record and is edited as one.
-- A discount is shown as a line of its own, the way it would be
-- written by hand, rather than folded into a rate nobody recognises.
-- ------------------------------------------------------------

create or replace function issue_invoice(p_order uuid) returns uuid
language plpgsql set search_path = public as $$
declare
  o    v_order%rowtype;
  c    customer%rowtype;
  days int;
  iid  uuid;
  addr text;
  ship text;
begin
  select * into o from v_order where id = p_order;
  if not found then
    raise exception 'No such order on this farm';
  end if;
  select * into c from customer where id = o.customer_id;
  select coalesce((select invoice_terms_days from farm_business where farm_id = o.farm_id), 14) into days;

  addr := concat_ws(E'\n', c.name, nullif(c.company, ''), nullif(c.street, ''),
            nullif(concat_ws('  ', concat_ws(' ', nullif(c.suburb, ''), nullif(c.state, '')), nullif(c.postcode, '')), ''));
  ship := case when o.fulfilment = 'delivery' then
            concat_ws(E'\n', o.to_name, nullif(o.to_street, ''),
              nullif(concat_ws('  ', concat_ws(' ', nullif(o.to_suburb, ''), nullif(o.to_state, '')), nullif(o.to_postcode, '')), ''))
          end;

  insert into invoice (order_id, customer_id, due_on, bill_to, ship_to, ship_on, ship_via, tracking)
  values (o.id, o.customer_id, farm_today() + days, addr, ship,
          case when o.fulfilment = 'delivery' then o.deliver_on end,
          case when o.fulfilment = 'delivery' then coalesce(nullif(o.carrier, ''), 'Blackbird') end,
          o.tracking_url)
  returning id into iid;

  insert into invoice_line (invoice_id, description, qty, rate_cents, gst_rate, sort)
  select iid, l.description, l.qty, l.unit_cents, l.gst_rate, l.sort * 10
    from order_line l where l.order_id = o.id;

  insert into invoice_line (invoice_id, description, qty, rate_cents, gst_rate, sort)
  select iid, 'Discount — ' || l.description, 1, -l.discount_cents, l.gst_rate, l.sort * 10 + 1
    from order_line l where l.order_id = o.id and l.discount_cents > 0;

  if o.delivery_fee_cents > 0 then
    insert into invoice_line (invoice_id, description, qty, rate_cents, gst_rate, shipping, sort)
    values (iid, 'Shipping', 1, o.delivery_fee_cents, 10, true, 10000);
  end if;
  return iid;
end $$;

revoke execute on function issue_invoice(uuid) from public, anon;
grant  execute on function issue_invoice(uuid) to authenticated;

notify pgrst, 'reload schema';
