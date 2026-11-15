-- ============================================================
-- 76. What is emailed, and what became of it.
--
-- Until now the system sent nothing. A website order showed a
-- thank-you page and that was all the customer had; an invoice was
-- printed to a PDF and attached to an email by hand.
--
-- Three emails, all from the farm's own mailbox — the address on the
-- letterhead (farm_business.email):
--
--   order         to the customer: we have your order, here is what
--                 happens next. Says what the website's thank-you
--                 page says, and nothing about money but the deposit.
--   order_notice  to the farm: a website order has come in. Replying
--                 to it writes to the customer.
--   invoice       to the customer: a message, then the invoice itself
--                 in the body of the email. No attachment.
--
-- (and "test", to the farm, to prove the mailbox works.)
--
-- The database writes the email; it does not send it. Every email is
-- a row in `mail` — who to, the subject, the words — written by a
-- function here from the order or the invoice as it stands. That row
-- is the record of what was said. A small function outside the
-- database (supabase/functions/send-mail) does only transport: it
-- claims what is queued, hands each to the mailbox, and reports back
-- sent or failed. So:
--
--   An order never depends on email. place_order() queues its two
--   emails after the order is written, and if writing them fails the
--   order stands and nothing is queued.
--
--   Nothing is sent twice. mail_claim() takes a row from queued to
--   sending under a lock; a second sender sees nothing to take.
--
--   Nothing old is sent by surprise. A row not sent within a day of
--   being asked for is marked failed, not sent late: a confirmation
--   that arrives three days after the order is worse than none. A
--   person can still send it, with mail_retry().
--
--   A row left "sending" for ten minutes is marked failed with a
--   warning that it may have gone — the sender died before saying.
--
-- Website confirmations are off until the owner turns them on
-- (farm_business.email_web_orders), which is after the test email has
-- arrived. Emails from Sales are asked for one at a time by a person.
--
-- Nobody writes to `mail` directly: there is no insert, update or
-- delete policy. Staff read it; the functions here write it; only the
-- sender (service_role) may claim and report.
--
-- place_order() is replaced whole (as 74, with the queueing).
--
-- Safe to run more than once.
-- ============================================================

alter table farm_business
  add column if not exists email_web_orders boolean not null default false;

comment on column farm_business.email_web_orders is
  'Email the customer a confirmation, and the farm a notice, when an order arrives from the website. Off until the mailbox is proven.';

create table if not exists mail (
  id          uuid primary key default gen_random_uuid(),
  farm_id     uuid not null references farm(id),
  kind        text not null check (kind in ('order', 'order_notice', 'invoice', 'test')),
  order_id    uuid references customer_order(id) on delete set null,
  invoice_id  uuid references invoice(id) on delete set null,
  from_email  text not null,                   -- the farm's mailbox, as it was when asked
  from_name   text not null,
  to_email    text not null,
  to_name     text,
  reply_to    text,
  subject     text not null,
  body_text   text not null,
  body_html   text not null,
  status      text not null default 'queued'
                check (status in ('queued', 'sending', 'sent', 'failed')),
  attempts    int  not null default 0,
  error       text,                            -- why not, in words a person can act on
  asked_by    uuid references farm_user(id) default auth.uid(),   -- null: the website
  created_at  timestamptz not null default now(),
  queued_at   timestamptz not null default now(),                 -- moves on a retry
  claimed_at  timestamptz,
  sent_at     timestamptz
);
create index if not exists mail_farm_idx    on mail (farm_id, created_at desc);
create index if not exists mail_queue_idx   on mail (queued_at) where status in ('queued', 'sending');
create index if not exists mail_order_idx   on mail (order_id);
create index if not exists mail_invoice_idx on mail (invoice_id);

comment on table mail is
  'Every email the system was asked to send, the words it used, and whether it went. Written by functions, sent by supabase/functions/send-mail.';

alter table mail enable row level security;

drop policy if exists mail_read on mail;
create policy mail_read on mail
  for select to authenticated using (farm_id = (select current_farm()) and can_read());

-- Read only. RLS decides which rows; there is no policy to write by.
revoke all on mail from anon, authenticated;
grant select on mail to authenticated;
grant select, insert, update, delete on mail to service_role;

-- ------------------------------------------------------------
-- How things are written out
-- ------------------------------------------------------------

-- Null in, null out — so `'<p>' || html_esc(x) || '</p>'` is null when
-- x is, and a coalesce around it drops the paragraph.
create or replace function html_esc(p text) returns text
language sql immutable strict set search_path = public as $$
  select replace(replace(replace(replace(p, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;')
$$;

-- 1,234.50
create or replace function amount_text(p_cents numeric) returns text
language sql stable strict set search_path = public as $$
  select case when p_cents < 0 then '-' else '' end || btrim(to_char(abs(p_cents) / 100.0, '999,999,990.00'))
$$;

-- $1,234.50
create or replace function money_text(p_cents numeric) returns text
language sql stable strict set search_path = public as $$
  select case when p_cents < 0 then '-' else '' end || '$' || btrim(to_char(abs(p_cents) / 100.0, '999,999,990.00'))
$$;

-- 2, 0.5 — a quantity without the zeros nobody typed
create or replace function qty_text(p numeric) returns text
language sql stable strict set search_path = public as $$
  select rtrim(rtrim(to_char(p, 'FM999990.00'), '0'), '.')
$$;

-- Monday 7 December 2026, as the website writes a date
create or replace function day_text(p date) returns text
language sql stable strict set search_path = public as $$
  select to_char(p, 'FMDay FMDD FMMonth YYYY')
$$;

-- Typed text as paragraphs: a blank line starts one, a line break stays.
create or replace function para_html(p text) returns text
language sql immutable set search_path = public as $$
  select coalesce(string_agg('<p style="margin:0 0 14px">'
                    || replace(html_esc(btrim(x, E' \n\t')), E'\n', '<br>') || '</p>', '' order by n), '')
    from regexp_split_to_table(replace(coalesce(p, ''), E'\r', ''), E'\n[ \t]*\n+') with ordinality as t(x, n)
   where btrim(x, E' \n\t') <> ''
$$;

-- Who it is from, under the words. The street address goes on an
-- invoice (p_full), as it does on paper, and not on anything else.
create or replace function mail_sign(p_farm uuid, p_full boolean) returns text
language sql stable security definer set search_path = public as $$
  select concat_ws(E'\n', f.name,
           case when p_full then nullif(f.address, '') end,
           nullif(concat_ws(' · ', nullif(b.phone, ''), nullif(b.email, ''), nullif(b.website, '')), ''),
           case when p_full then 'ABN ' || nullif(b.abn, '') end)
    from farm f left join farm_business b on b.farm_id = f.id
   where f.id = p_farm
$$;

create or replace function mail_frame(p_farm uuid, p_inner text, p_full boolean) returns text
language sql stable security definer set search_path = public as $$
  select '<div style="font-family:-apple-system,''Segoe UI'',Helvetica,Arial,sans-serif;font-size:15px;line-height:1.5;color:#222222;max-width:640px">'
      || p_inner
      || '<p style="margin:28px 0 0;padding-top:12px;border-top:1px solid #dddddd;font-size:13px;color:#666666">'
      || replace(html_esc(mail_sign(p_farm, p_full)), E'\n', '<br>')
      || '</p></div>'
$$;

-- ------------------------------------------------------------
-- Putting one in the queue
--
-- The address is checked here, harder than the order form checks it:
-- this is the last place before it becomes a line in a conversation
-- with a mail server. Names and subjects lose their line breaks for
-- the same reason.
-- ------------------------------------------------------------

create or replace function mail_put(p_farm uuid, p_kind text, p_order uuid, p_invoice uuid,
                                    p_to text, p_to_name text, p_reply_to text,
                                    p_subject text, p_text text, p_html text) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  ok     constant text := '^[^@\s<>,;:"()\[\]\\]+@[a-z0-9.-]+\.[a-z]{2,}$';
  v_from text;
  v_name text;
  v_to   text := lower(btrim(coalesce(p_to, '')));
  v_rep  text := nullif(lower(btrim(coalesce(p_reply_to, ''))), '');
  mid    uuid;
begin
  select nullif(lower(btrim(b.email)), ''), f.name into v_from, v_name
    from farm f left join farm_business b on b.farm_id = f.id
   where f.id = p_farm;
  if v_from is null then
    raise exception 'Add the farm''s email address in Sales → Settings first';
  end if;
  if length(v_to) > 200 or v_to !~ ok then
    raise exception '“%” does not look like an email address', coalesce(p_to, '');
  end if;
  if v_rep is not null and (length(v_rep) > 200 or v_rep !~ ok) then
    v_rep := null;
  end if;

  insert into mail (farm_id, kind, order_id, invoice_id, from_email, from_name,
                    to_email, to_name, reply_to, subject, body_text, body_html)
  values (p_farm, p_kind, p_order, p_invoice, v_from, v_name, v_to,
          nullif(btrim(regexp_replace(coalesce(p_to_name, ''), '[\r\n\t]+', ' ', 'g')), ''),
          v_rep,
          left(btrim(regexp_replace(p_subject, '[\r\n\t]+', ' ', 'g')), 200),
          p_text, p_html)
  returning id into mid;
  return mid;
end $$;

-- ------------------------------------------------------------
-- An order: the confirmation, and the farm's notice
--
-- The confirmation says what the website's thank-you page says
-- (site/site.js, showConfirmation and whenLine) — change one, change
-- the other. A website order is greeted by the name that was typed;
-- an order written up in Sales, by the customer's.
-- ------------------------------------------------------------

create or replace function queue_order_mail(p_order uuid, p_customer boolean, p_notice boolean,
                                            p_to text default null) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  o       v_order%rowtype;
  f       farm%rowtype;
  h       harvest%rowtype;
  v_first text;
  v_who   text;
  it_t    text;      -- the lines, as text
  it_h    text;      -- and as a list
  v_cut   boolean;
  steps   text[];
  v_when  text;
  v_place text;
  addr    text;
  v_ful   text;
  t       text;
  hh      text;
  mid     uuid;
  nid     uuid;
  p0      constant text := '<p style="margin:0 0 14px">';
  li      constant text := '<li style="margin:0 0 4px">';
begin
  select * into o from v_order where id = p_order;
  if not found then
    raise exception 'No such order';
  end if;
  select * into f from farm where id = o.farm_id;
  if o.harvest_id is not null then
    select * into h from harvest where id = o.harvest_id;
  end if;

  v_who   := case when o.source = 'web' then o.to_name else o.customer_name end;
  v_first := split_part(btrim(v_who), ' ', 1);

  select string_agg(l.qty || ' × ' || l.description || coalesce(' — ' || a.txt, ''),
                    E'\n' order by l.sort, l.created_at),
         string_agg(li || l.qty || ' &times; ' || html_esc(l.description)
                       || coalesce(' &mdash; ' || html_esc(a.txt), '') || '</li>',
                    '' order by l.sort, l.created_at),
         coalesce(bool_or(l.for_butcher), false)
    into it_t, it_h, v_cut
    from order_line l
    left join lateral (
      select string_agg(e.k || ': ' || e.v, ', ') as txt
        from jsonb_each_text(case when jsonb_typeof(l.answers) = 'object' then l.answers
                                  else '{}'::jsonb end) as e(k, v)) a on true
   where l.order_id = o.id;

  steps := array[
    case when o.deposit_cents > 0 and o.paid_cents < o.deposit_cents
         then 'We’ll email an invoice for the deposit (' || money_text(o.deposit_cents)
              || ') with payment details. There is nothing to pay online.'
         else 'We’ll email an invoice with payment details. There is nothing to pay online.' end];
  if v_cut then
    steps := steps || 'Once your order is butchered and packed we confirm the weights and invoice the balance.'::text;
  end if;

  if o.fulfilment = 'delivery' then
    v_when := case
        when o.deliver_on is not null then 'Delivery: ' || day_text(o.deliver_on) || '.'
        when h.delivery_on is not null or h.interstate_on is not null then
          btrim(coalesce('Delivery: ' || day_text(h.delivery_on) || '.', '')
             || coalesce(' Interstate deliveries: ' || day_text(h.interstate_on) || '.', ''))
        else 'We’ll be in touch to confirm your delivery date.' end
      || case when o.delivery_fee_cents = 0
              then ' The delivery fee depends on where you are and is confirmed on your invoice.'
              else '' end;
    addr := concat_ws(E'\n', o.to_name, nullif(o.to_street, ''),
              nullif(concat_ws(' ', nullif(o.to_suburb, ''), nullif(o.to_state, ''), nullif(o.to_postcode, '')), ''),
              'Instructions: ' || nullif(o.ship_instructions, ''));
  elsif o.fulfilment = 'pickup_farm' then
    v_when := coalesce('Local pick-up: ' || day_text(h.pickup_on) || '. ', '')
           || 'We’ll be in touch to arrange where and when to pick up from us.';
  else
    v_place := coalesce(nullif(h.pickup_place, ''), nullif(h.butcher_name, ''), 'the butcher');
    v_when := case when h.pickup_on is not null
                   then 'Pick-up: ' || day_text(h.pickup_on) || ', from ' || v_place || '.'
                   else 'We’ll be in touch to confirm when your order is ready to pick up from ' || v_place || '.' end;
  end if;
  steps := steps || v_when;

  if p_customer then
    if coalesce(nullif(btrim(p_to), ''), nullif(o.customer_email, '')) is null then
      raise exception '% has no email address', o.customer_name;
    end if;
    t := 'Hi ' || v_first || ',' || E'\n\n'
      || 'Thank you — we’ve got your order. Your reference is ' || o.ref || '.' || E'\n\n'
      || coalesce(it_t || E'\n\n', '')
      || 'What happens next' || E'\n'
      || (select string_agg(x.n || '. ' || x.s, E'\n' order by x.n)
            from unnest(steps) with ordinality as x(s, n)) || E'\n\n'
      || coalesce('Delivering to:' || E'\n' || addr || E'\n\n', '')
      || coalesce('Your note: ' || nullif(o.customer_note, '') || E'\n\n', '')
      || 'Questions? Reply to this email and mention ' || o.ref || '.' || E'\n\n'
      || mail_sign(o.farm_id, false);
    hh := mail_frame(o.farm_id,
         p0 || 'Hi ' || html_esc(v_first) || ',</p>'
      || p0 || 'Thank you &mdash; we&rsquo;ve got your order. Your reference is <b>' || html_esc(o.ref) || '</b>.</p>'
      || coalesce('<ul style="margin:0 0 18px;padding-left:20px">' || it_h || '</ul>', '')
      || '<p style="margin:0 0 6px"><b>What happens next</b></p>'
      || '<ol style="margin:0 0 18px;padding-left:20px">'
      || (select string_agg(li || html_esc(x.s) || '</li>', '' order by x.n)
            from unnest(steps) with ordinality as x(s, n)) || '</ol>'
      || coalesce(p0 || '<b>Delivering to</b><br>' || replace(html_esc(addr), E'\n', '<br>') || '</p>', '')
      || coalesce(p0 || '<b>Your note</b><br>'
                     || replace(html_esc(nullif(o.customer_note, '')), E'\n', '<br>') || '</p>', '')
      || p0 || 'Questions? Reply to this email and mention ' || html_esc(o.ref) || '.</p>',
      false);
    mid := mail_put(o.farm_id, 'order', o.id, null,
                    coalesce(nullif(btrim(p_to), ''), o.customer_email), v_who, null,
                    'Your ' || f.name || ' order ' || o.ref, t, hh);
  end if;

  if p_notice then
    v_ful := case o.fulfilment when 'delivery' then 'Delivery'
                               when 'pickup_farm' then 'Pick-up — from us'
                               else 'Pick-up — butcher' end;
    t := 'A new order came in from the website.' || E'\n\n'
      || o.ref || ' · ' || v_who || E'\n'
      || concat_ws(' · ', nullif(o.customer_email, ''), nullif(o.to_phone, '')) || E'\n\n'
      || coalesce(it_t || E'\n\n', '')
      || v_ful || ' · ' || coalesce('harvest ' || h.code, 'not on a harvest yet') || E'\n'
      || coalesce(addr || E'\n', '')
      || coalesce(E'\n' || 'Their note: ' || nullif(o.customer_note, '') || E'\n', '')
      || coalesce(E'\n' || 'Open it: https://' || nullif(f.hostname, '') || '/sales#order/' || o.id || E'\n', '')
      || E'\n' || 'Replying to this email writes to ' || v_first || '.';
    hh := mail_frame(o.farm_id,
         p0 || 'A new order came in from the website.</p>'
      || p0 || '<b>' || html_esc(o.ref) || ' · ' || html_esc(v_who) || '</b><br>'
            || html_esc(concat_ws(' · ', nullif(o.customer_email, ''), nullif(o.to_phone, ''))) || '</p>'
      || coalesce('<ul style="margin:0 0 18px;padding-left:20px">' || it_h || '</ul>', '')
      || p0 || '<b>' || html_esc(v_ful) || '</b> · '
            || html_esc(coalesce('harvest ' || h.code, 'not on a harvest yet'))
            || coalesce('<br>' || replace(html_esc(addr), E'\n', '<br>'), '') || '</p>'
      || coalesce(p0 || '<b>Their note</b><br>'
                     || replace(html_esc(nullif(o.customer_note, '')), E'\n', '<br>') || '</p>', '')
      || coalesce(p0 || '<a href="https://' || html_esc(nullif(f.hostname, '')) || '/sales#order/' || o.id
                     || '">Open the order</a></p>', '')
      || p0 || 'Replying to this email writes to ' || html_esc(v_first) || '.</p>',
      false);
    nid := mail_put(o.farm_id, 'order_notice', o.id, null,
                    (select b.email from farm_business b where b.farm_id = o.farm_id), f.name,
                    o.customer_email,
                    'New website order ' || o.ref || ' — ' || v_who, t, hh);
  end if;
  return coalesce(mid, nid);     -- the customer's, if both
end $$;

-- From Sales: send the confirmation for an order, to its customer or
-- to an address typed in.
create or replace function mail_order(p_order uuid, p_to text default null) returns uuid
language plpgsql security definer set search_path = public as $$
begin
  if current_farm() is null or not can_write() then
    raise exception 'Only someone who records for this farm can send its email';
  end if;
  if not exists (select 1 from customer_order where id = p_order and farm_id = current_farm()) then
    raise exception 'No such order on this farm';
  end if;
  return queue_order_mail(p_order, true, false, p_to);
end $$;

-- ------------------------------------------------------------
-- An invoice
--
-- A message, then the invoice as it stands: the same figures, in the
-- same order, as the page that prints it. p_message null means the
-- standard two lines.
-- ------------------------------------------------------------

create or replace function mail_invoice(p_invoice uuid, p_to text default null,
                                        p_subject text default null, p_message text default null)
returns uuid
language plpgsql security definer set search_path = public as $$
declare
  i      v_invoice%rowtype;
  f      farm%rowtype;
  b      farm_business%rowtype;
  v_msg  text;
  rows_t text;
  rows_h text;
  sums_t text;
  sums_h text;
  t      text;
  hh     text;
  td     constant text := 'padding:6px 5px;border-bottom:1px solid #eeeeee;vertical-align:top';
  th     constant text := 'padding:6px 5px;border-bottom:2px solid #222222;font-size:11px;text-transform:uppercase;letter-spacing:.04em';
  lab    constant text := 'font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:#666666';
begin
  if current_farm() is null or not can_write() then
    raise exception 'Only someone who records for this farm can send its email';
  end if;
  select * into i from v_invoice where id = p_invoice and farm_id = current_farm();
  if not found then
    raise exception 'No such invoice on this farm';
  end if;
  if i.void then
    raise exception 'Invoice % is void', i.invoice_no;
  end if;
  if coalesce(nullif(btrim(p_to), ''), nullif(i.customer_email, '')) is null then
    raise exception '% has no email address', i.customer_name;
  end if;
  select * into f from farm where id = i.farm_id;
  select * into b from farm_business where farm_id = i.farm_id;

  v_msg := coalesce(nullif(btrim(p_message), ''),
    'Hi ' || split_part(btrim(i.customer_name), ' ', 1) || ',' || E'\n\n'
    || 'Thank you for your order. Your invoice is below'
    || case when i.due_cents > 0
            then ' — ' || money_text(i.due_cents) || ' is due'
                 || coalesce(' by ' || to_char(i.due_on, 'DD/MM/YYYY'), '') || '.'
            else '.' end);

  select string_agg(l.description || E'\n    ' || qty_text(l.qty) || ' × ' || amount_text(l.rate_cents)
                      || ' = ' || amount_text(round(l.qty * l.rate_cents))
                      || case when l.gst_rate > 0 then '  (plus 10% GST)' else '  (GST free)' end,
                    E'\n' order by l.sort),
         -- Four columns, not the printed five: GST sits under the
         -- description, so the amounts still fit on a phone.
         string_agg('<tr><td style="' || td || '"><b>' || html_esc(l.description) || '</b>'
                      || '<br><span style="font-size:12px;color:#666666">'
                      || case when l.gst_rate > 0 then 'plus 10% GST' else 'GST free' end || '</span></td>'
                      || '<td align="right" style="' || td || '">' || qty_text(l.qty) || '</td>'
                      || '<td align="right" style="' || td || '">' || amount_text(l.rate_cents) || '</td>'
                      || '<td align="right" style="' || td || '">' || amount_text(round(l.qty * l.rate_cents)) || '</td></tr>',
                    '' order by l.sort)
    into rows_t, rows_h
    from invoice_line l
   where l.invoice_id = i.id and not l.shipping;

  select string_agg(rpad(s.label, 14) || s.val, E'\n' order by s.n),
         string_agg('<tr><td align="right" style="padding:3px 8px;' || case when s.strong then 'font-weight:bold;border-top:2px solid #222222;padding-top:8px' else 'color:#444444' end || '">' || s.label || '</td>'
                      || '<td align="right" style="padding:3px 8px;white-space:nowrap;' || case when s.strong then 'font-weight:bold;border-top:2px solid #222222;padding-top:8px' else '' end || '">' || s.val || '</td></tr>',
                    '' order by s.n)
    into sums_t, sums_h
    from (values (1, 'Subtotal',  amount_text(i.subtotal_cents), false, true),
                 (2, 'GST total', amount_text(i.gst_cents),      false, true),
                 (3, 'Shipping',  amount_text(i.shipping_cents), false, i.shipping_cents <> 0),
                 (4, 'Total',     amount_text(i.total_cents),    false, true),
                 (5, 'Paid',      '-' || amount_text(least(i.paid_cents, i.total_cents)), false, i.paid_cents > 0),
                 (6, 'Total due', 'A' || money_text(i.due_cents), true, true)
         ) as s(n, label, val, strong, shown)
   where s.shown;

  t := v_msg || E'\n\n'
    || '----------------------------------------' || E'\n'
    || 'TAX INVOICE ' || i.invoice_no || E'\n'
    || 'Date: ' || to_char(i.issued_on, 'DD/MM/YYYY') || E'\n'
    || coalesce('Due: ' || to_char(i.due_on, 'DD/MM/YYYY') || E'\n', '')
    || 'Order: ' || i.order_ref || E'\n\n'
    || 'Invoice to:' || E'\n' || i.bill_to || E'\n\n'
    || coalesce('Ship to:' || E'\n' || nullif(i.ship_to, '') || E'\n\n', '')
    || coalesce(nullif(concat_ws(E'\n', 'Ship date: ' || to_char(i.ship_on, 'DD/MM/YYYY'),
                                        'Ship via: ' || nullif(i.ship_via, ''),
                                        'Tracking no.: ' || nullif(i.tracking, '')), '') || E'\n\n', '')
    || coalesce(rows_t || E'\n\n', '')
    || sums_t || E'\n\n'
    || coalesce('Payment details' || E'\n' || nullif(b.payment_details, '') || E'\n\n', '')
    || coalesce(nullif(i.note, '') || E'\n\n', '')
    || '----------------------------------------' || E'\n'
    || mail_sign(i.farm_id, true);

  hh := mail_frame(i.farm_id,
       para_html(v_msg)
    || '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:24px 0 0;border-top:1px solid #dddddd">'
    || '<tr><td style="padding:16px 0 10px;font-size:20px;font-weight:bold">Tax Invoice ' || i.invoice_no || '</td>'
    || '<td align="right" style="padding:16px 0 10px;font-size:13px;color:#444444">Date ' || to_char(i.issued_on, 'DD/MM/YYYY')
    || coalesce('<br>Due ' || to_char(i.due_on, 'DD/MM/YYYY'), '')
    || '<br>Order ' || html_esc(i.order_ref) || '</td></tr></table>'
    || '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0 0 14px"><tr>'
    || '<td width="50%" style="vertical-align:top;padding:0 8px 0 0"><span style="' || lab || '">Invoice to</span><br>'
    || replace(html_esc(i.bill_to), E'\n', '<br>') || '</td>'
    || '<td width="50%" style="vertical-align:top">'
    || coalesce('<span style="' || lab || '">Ship to</span><br>' || replace(html_esc(nullif(i.ship_to, '')), E'\n', '<br>'), '')
    || '</td></tr></table>'
    || coalesce('<p style="margin:0 0 14px;font-size:13px;color:#444444">'
                || html_esc(nullif(concat_ws(' · ', 'Ship date ' || to_char(i.ship_on, 'DD/MM/YYYY'),
                                                     'Ship via ' || nullif(i.ship_via, ''),
                                                     'Tracking no. ' || nullif(i.tracking, '')), ''))
                || '</p>', '')
    || '<table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0 0 10px">'
    || '<tr><th align="left" style="' || th || '">Description</th><th align="right" style="' || th || '">Qty</th>'
    || '<th align="right" style="' || th || '">Rate</th>'
    || '<th align="right" style="' || th || '">Amount</th></tr>'
    || coalesce(rows_h, '') || '</table>'
    || '<table role="presentation" align="right" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0 0 18px">'
    || sums_h || '</table>'
    || '<div style="clear:both;height:1px;line-height:1px">&nbsp;</div>'
    || coalesce('<p style="margin:14px 0 14px"><b>Payment details</b><br>'
                || replace(html_esc(nullif(b.payment_details, '')), E'\n', '<br>') || '</p>', '')
    || coalesce(para_html(nullif(i.note, '')), ''),
    true);

  return mail_put(i.farm_id, 'invoice', i.order_id, i.id,
                  coalesce(nullif(btrim(p_to), ''), i.customer_email), i.customer_name, null,
                  coalesce(nullif(btrim(p_subject), ''), 'Invoice ' || i.invoice_no || ' from ' || f.name),
                  t, hh);
end $$;

-- To the farm's own address: is the mailbox working?
create or replace function mail_test() returns uuid
language plpgsql security definer set search_path = public as $$
declare
  fid uuid := current_farm();
  v_email text;
  v_name  text;
  t text;
begin
  if fid is null or my_role()::text is distinct from 'owner' then
    raise exception 'Only an owner can test the farm''s email';
  end if;
  select nullif(btrim(b.email), ''), f.name into v_email, v_name
    from farm f left join farm_business b on b.farm_id = f.id
   where f.id = fid;
  if v_email is null then
    raise exception 'Add the farm''s email address in Sales → Settings first';
  end if;
  t := 'If you are reading this in the ' || v_email || ' inbox, email from the sales system is working.'
    || E'\n\n' || 'Order confirmations and invoices will come from this address, and copies will be in its Sent folder.';
  return mail_put(fid, 'test', null, null, v_email, v_name, null,
                  'Test email from ' || v_name || ' sales', t || E'\n\n' || mail_sign(fid, false),
                  mail_frame(fid, para_html(t), false));
end $$;

-- Try a failed one again, as it was written.
create or replace function mail_retry(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if current_farm() is null or not can_write() then
    raise exception 'Only someone who records for this farm can send its email';
  end if;
  update mail set status = 'queued', queued_at = now(), error = null
   where id = p_id and farm_id = current_farm() and status = 'failed';
  if not found then
    raise exception 'That email is not waiting to be tried again';
  end if;
end $$;

-- ------------------------------------------------------------
-- The sender's two questions: what is there to send, and here is
-- what happened. service_role only.
-- ------------------------------------------------------------

create or replace function mail_claim(p_limit int default 10) returns setof mail
language plpgsql security definer set search_path = public as $$
begin
  update mail set status = 'failed',
                  error  = 'Not sent within a day of being asked for, so not sent at all'
   where status = 'queued' and queued_at < now() - interval '1 day';
  update mail set status = 'failed',
                  error  = 'The sender stopped part-way. This may or may not have gone: look in the Sent folder before sending it again.'
   where status = 'sending' and claimed_at < now() - interval '10 minutes';

  return query
    update mail m
       set status = 'sending', attempts = m.attempts + 1, claimed_at = now(), error = null
     where m.id in (select q.id from mail q
                     where q.status = 'queued'
                     order by q.queued_at
                     limit greatest(least(coalesce(p_limit, 10), 50), 1)
                       for update skip locked)
    returning m.*;
end $$;

create or replace function mail_done(p_id uuid, p_ok boolean, p_error text default null) returns void
language plpgsql security definer set search_path = public as $$
declare
  m mail;
begin
  update mail
     set status  = case when p_ok then 'sent' else 'failed' end,
         sent_at = case when p_ok then now() end,
         error   = case when p_ok then null else left(coalesce(nullif(btrim(p_error), ''), 'Not sent'), 500) end
   where id = p_id and status = 'sending'
  returning * into m;
  if found and p_ok and m.kind = 'invoice' and m.invoice_id is not null then
    update invoice set sent_on = farm_today() where id = m.invoice_id and sent_on is null;
  end if;
end $$;

-- ------------------------------------------------------------
-- Who may ask
-- ------------------------------------------------------------

revoke execute on function html_esc(text), amount_text(numeric), money_text(numeric), qty_text(numeric),
                           day_text(date), para_html(text), mail_sign(uuid, boolean),
                           mail_frame(uuid, text, boolean),
                           mail_put(uuid, text, uuid, uuid, text, text, text, text, text, text),
                           queue_order_mail(uuid, boolean, boolean, text),
                           mail_claim(int), mail_done(uuid, boolean, text)
  from public, anon, authenticated;

revoke execute on function mail_order(uuid, text), mail_invoice(uuid, text, text, text),
                           mail_test(), mail_retry(uuid)
  from public, anon;
grant execute on function mail_order(uuid, text), mail_invoice(uuid, text, text, text),
                          mail_test(), mail_retry(uuid)
  to authenticated;

grant execute on function mail_claim(int), mail_done(uuid, boolean, text) to service_role;

-- ------------------------------------------------------------
-- What the pages read: the log, with what each one was about
-- ------------------------------------------------------------

create or replace view v_mail with (security_invoker = on) as
select m.id, m.farm_id, m.kind, m.order_id, m.invoice_id, m.to_email, m.to_name, m.subject,
       m.status, m.error, m.attempts, m.created_at, m.sent_at, m.body_text,
       order_ref(fb.order_prefix, o.order_no) as order_ref,
       i.invoice_no
  from mail m
  left join customer_order o on o.id = m.order_id
  left join invoice i        on i.id = m.invoice_id
  left join farm_business fb on fb.farm_id = m.farm_id;

revoke all on v_mail from anon, authenticated;
grant select on v_mail to authenticated;

-- ------------------------------------------------------------
-- place_order(): as 74; when the farm has turned confirmations on,
-- the order's two emails are queued behind it. The reply says so
-- ("emailed"), which is the website's cue to wake the sender.
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
