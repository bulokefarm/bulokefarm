-- ============================================================
-- 81. Orders from before: what the old shop recorded.
--
-- Five years of orders were taken through a Squarespace shop. They are
-- worth keeping to look back on — who has ordered before, what, how
-- often, delivered or picked up — but they are not orders in the sense
-- customer_order means. Squarespace took a deposit ($120 a pack, and
-- the freight); the pack was weighed and the balance invoiced
-- somewhere else. Its "total" is the deposit, not the sale.
--
-- Put into customer_order they would say a customer spent $120 on 24
-- kilos of beef, sit under "No harvest" by the dozen, and take order
-- numbers the new orders need. So they are kept as what they are: a
-- record of what another system wrote down, in a table of its own that
-- nothing is added up from.
--
--   past_order   one row an order: where it came from and its number
--                there, when, who (linked to the customer by email when
--                there is one), what the shop had as lines, what it
--                took and gave back, how it was to leave, the names and
--                addresses as typed that day, and any note.
--
--   import_past_orders()   loads them, and can be run again: an order
--                already here (same shop, same number) is brought up to
--                date rather than doubled.
--
-- The rows are people's names and addresses. They are loaded by a
-- converter that writes SQL to be run and deleted
-- (seed/tools/import_squarespace_orders.py); nothing of them is in
-- this repository.
--
-- Safe to run more than once.
-- ============================================================

create table if not exists past_order (
  id             uuid primary key default gen_random_uuid(),
  farm_id        uuid not null default current_farm() references farm(id),
  source         text not null default 'squarespace',   -- the shop it came from
  ref            text not null,                          -- its order number there
  customer_id    uuid references customer(id) on delete set null,
  email          text,
  placed_at      timestamptz not null,
  paid_status    text,                                   -- as the shop had it: paid, refunded
  fulfil_status  text,                                   -- fulfilled, pending, cancelled
  fulfilled_at   timestamptz,
  cancelled_at   timestamptz,
  subtotal_cents int not null default 0,
  shipping_cents int not null default 0,
  tax_cents      int not null default 0,
  refunded_cents int not null default 0,
  total_cents    int not null default 0,                 -- what the shop took: usually a deposit, not the sale
  ship_method    text,                                   -- "Delivery", "Farm Pick-up", a butcher's name
  lines          jsonb not null default '[]'::jsonb,     -- [{qty, name, variant, sku, price_cents}]
  bill_name text, bill_street text, bill_suburb text, bill_state text, bill_postcode text, bill_phone text,
  ship_name text, ship_street text, ship_suburb text, ship_state text, ship_postcode text, ship_phone text,
  note           text,
  payment_method text,
  payment_ref    text,
  imported_at    timestamptz not null default now(),
  constraint past_order_lines_ck check (jsonb_typeof(lines) = 'array')
);
create unique index if not exists past_order_ref_uq on past_order (farm_id, source, ref);
create index if not exists past_order_farm_idx     on past_order (farm_id);
create index if not exists past_order_customer_idx on past_order (customer_id);

comment on table past_order is
  'Orders taken by a shop that came before this one, kept to look back on. Not customer_order: the totals are what that shop took (a deposit), and nothing is added up from them.';

alter table past_order enable row level security;

drop policy if exists past_order_read   on past_order;
drop policy if exists past_order_insert on past_order;
drop policy if exists past_order_update on past_order;
drop policy if exists past_order_delete on past_order;
-- Written wrapped, so each is asked once a statement (see 80).
create policy past_order_read on past_order for select to authenticated
  using (farm_id = (select current_farm()) and (select can_read()));
create policy past_order_insert on past_order for insert to authenticated
  with check (farm_id = (select current_farm()) and (select can_write()));
create policy past_order_update on past_order for update to authenticated
  using      (farm_id = (select current_farm()) and (select can_write()))
  with check (farm_id = (select current_farm()) and (select can_write()));
create policy past_order_delete on past_order for delete to authenticated
  using (farm_id = (select current_farm()) and (select my_role()) = 'owner');

revoke all on past_order from anon, public;
grant select, insert, update, delete on past_order to authenticated;

-- ------------------------------------------------------------
-- Loading them
--
-- p_rows: [{ref, email, placed_at, paid_status, fulfil_status,
-- fulfilled_at, cancelled_at, subtotal_cents, shipping_cents,
-- tax_cents, refunded_cents, total_cents, ship_method, lines,
-- bill_name … bill_phone, ship_name … ship_phone, note,
-- payment_method, payment_ref}].
--
-- Runs as the caller, so the row rules decide who may. An order is
-- tied to the customer with the same email, if there is one; an order
-- already tied to someone is left tied to them.
-- ------------------------------------------------------------

create or replace function import_past_orders(p_source text, p_rows jsonb) returns jsonb
language plpgsql set search_path = public as $$
declare
  fid   uuid := current_farm();
  src   text := coalesce(nullif(trim(p_source), ''), 'squarespace');
  added int;
  again int;
begin
  if fid is null then
    raise exception 'No farm';
  end if;
  if auth.uid() is not null and not coalesce(can_write(), false) then
    raise exception 'Only an owner or a manager can load past orders';
  end if;
  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'The orders must be a list';
  end if;

  with s as (
    select r.*
      from jsonb_to_recordset(p_rows) as r(
        ref text, email text, placed_at timestamptz, paid_status text, fulfil_status text,
        fulfilled_at timestamptz, cancelled_at timestamptz,
        subtotal_cents int, shipping_cents int, tax_cents int, refunded_cents int, total_cents int,
        ship_method text, lines jsonb,
        bill_name text, bill_street text, bill_suburb text, bill_state text, bill_postcode text, bill_phone text,
        ship_name text, ship_street text, ship_suburb text, ship_state text, ship_postcode text, ship_phone text,
        note text, payment_method text, payment_ref text)
     where nullif(trim(r.ref), '') is not null and r.placed_at is not null),
  up as (
    insert into past_order (farm_id, source, ref, customer_id, email, placed_at, paid_status, fulfil_status,
        fulfilled_at, cancelled_at, subtotal_cents, shipping_cents, tax_cents, refunded_cents, total_cents,
        ship_method, lines, bill_name, bill_street, bill_suburb, bill_state, bill_postcode, bill_phone,
        ship_name, ship_street, ship_suburb, ship_state, ship_postcode, ship_phone, note, payment_method, payment_ref)
    select fid, src, trim(s.ref),
           (select c.id from customer c
             where c.farm_id = fid and nullif(trim(s.email), '') is not null and lower(c.email) = lower(trim(s.email))
             order by c.created_at limit 1),
           nullif(lower(trim(s.email)), ''), s.placed_at, nullif(lower(s.paid_status), ''), nullif(lower(s.fulfil_status), ''),
           s.fulfilled_at, s.cancelled_at,
           coalesce(s.subtotal_cents, 0), coalesce(s.shipping_cents, 0), coalesce(s.tax_cents, 0),
           coalesce(s.refunded_cents, 0), coalesce(s.total_cents, 0),
           nullif(trim(s.ship_method), ''), coalesce(s.lines, '[]'::jsonb),
           nullif(s.bill_name, ''), nullif(s.bill_street, ''), nullif(s.bill_suburb, ''), nullif(s.bill_state, ''), nullif(s.bill_postcode, ''), nullif(s.bill_phone, ''),
           nullif(s.ship_name, ''), nullif(s.ship_street, ''), nullif(s.ship_suburb, ''), nullif(s.ship_state, ''), nullif(s.ship_postcode, ''), nullif(s.ship_phone, ''),
           nullif(s.note, ''), nullif(s.payment_method, ''), nullif(s.payment_ref, '')
      from s
    on conflict (farm_id, source, ref) do update set
        customer_id = coalesce(past_order.customer_id, excluded.customer_id),
        email = excluded.email, placed_at = excluded.placed_at,
        paid_status = excluded.paid_status, fulfil_status = excluded.fulfil_status,
        fulfilled_at = excluded.fulfilled_at, cancelled_at = excluded.cancelled_at,
        subtotal_cents = excluded.subtotal_cents, shipping_cents = excluded.shipping_cents, tax_cents = excluded.tax_cents,
        refunded_cents = excluded.refunded_cents, total_cents = excluded.total_cents,
        ship_method = excluded.ship_method, lines = excluded.lines,
        bill_name = excluded.bill_name, bill_street = excluded.bill_street, bill_suburb = excluded.bill_suburb,
        bill_state = excluded.bill_state, bill_postcode = excluded.bill_postcode, bill_phone = excluded.bill_phone,
        ship_name = excluded.ship_name, ship_street = excluded.ship_street, ship_suburb = excluded.ship_suburb,
        ship_state = excluded.ship_state, ship_postcode = excluded.ship_postcode, ship_phone = excluded.ship_phone,
        note = excluded.note, payment_method = excluded.payment_method, payment_ref = excluded.payment_ref
    returning (xmax = 0) as is_new)
  select count(*) filter (where is_new), count(*) filter (where not is_new) into added, again from up;

  return jsonb_build_object(
    'added', added, 'updated', again,
    'on_file', (select count(*) from past_order where farm_id = fid and source = src),
    'with_customer', (select count(*) from past_order where farm_id = fid and source = src and customer_id is not null),
    'without_customer', (select count(*) from past_order where farm_id = fid and source = src and customer_id is null));
end $$;

comment on function import_past_orders(text, jsonb) is
  'Load orders recorded by an earlier shop into past_order. Safe to repeat: the same shop and order number is updated, not added twice. Each is tied to the customer with the same email, where there is one.';

revoke execute on function import_past_orders(text, jsonb) from public, anon;
grant  execute on function import_past_orders(text, jsonb) to authenticated;

notify pgrst, 'reload schema';
