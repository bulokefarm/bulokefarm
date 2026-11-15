#!/usr/bin/env python3
"""Squarespace orders export (orders.csv) -> SQL that loads past_order.

    python import_squarespace_orders.py orders.csv buloke \
        > ../somewhere-outside-the-repo/past_orders.sql

Squarespace > Commerce > Orders > Export gives one row a line item: an
order with two things in it is two rows, the second carrying only the
order number and the item. They are put back together here.

The SQL calls import_past_orders() (migration 81), so the rules are the
database's, not this script's: an order already loaded is brought up to
date rather than added twice, and each is tied to the customer with the
same email where there is one. Run it again after a later export and
only the new orders are new.

THE OUTPUT IS PEOPLE'S NAMES, ADDRESSES AND PHONE NUMBERS. It is not a
seed: do not write it into supabase/seed/ and do not commit it. Run it
and delete it.

What is kept is what the shop wrote down, as it wrote it — a suburb in
capitals stays in capitals — because this is a record of that, not a
tidied copy. Two things are mended, both the export's doing and not the
customer's: the apostrophe a spreadsheet puts before "+61…", and the
leading 0 a spreadsheet takes off a mobile number.
"""
import csv
import datetime
import decimal
import json
import re
import sys


def cents(s):
    s = (s or "").strip().replace(",", "")
    if not s:
        return 0
    return int((decimal.Decimal(s) * 100).quantize(decimal.Decimal("1")))


def when(s):
    """'2026-09-07 16:49:52 +1000' -> '2026-09-07T16:49:52+10:00', or None."""
    s = (s or "").strip()
    if not s:
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S %z", "%Y-%m-%d %H:%M %z", "%Y-%m-%dT%H:%M:%S%z"):
        try:
            return datetime.datetime.strptime(s, fmt).isoformat()
        except ValueError:
            pass
    raise SystemExit("A date this script does not know how to read: %r" % s)


def phone(s):
    s = (s or "").strip().lstrip("'").strip()
    digits = re.sub(r"\D", "", s)
    if re.fullmatch(r"[2-478]\d{8}", digits) and not s.startswith("+"):
        return "0" + digits          # 427314474 was 0427 314 474 before a spreadsheet had it
    return re.sub(r"\s+", " ", s)


def text(s):
    return re.sub(r"[ \t]+", " ", (s or "").strip())


def street(a1, a2):
    return ", ".join(x for x in (text(a1), text(a2)) if x)


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    path, farm = sys.argv[1], sys.argv[2]
    if not re.fullmatch(r"[a-z0-9-]+", farm):
        raise SystemExit("The farm is its slug: buloke, toland.")

    orders, order = [], None
    with open(path, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            ref = text(r.get("Order ID"))
            if not ref:
                continue
            line = {"qty": int(float(r.get("Lineitem quantity") or 1)), "name": text(r.get("Lineitem name")),
                    "variant": text(r.get("Lineitem variant")), "sku": text(r.get("Lineitem sku")),
                    "price_cents": cents(r.get("Lineitem price"))}
            if order is not None and order["ref"] == ref and not text(r.get("Created at")):
                order["lines"].append(line)        # a second item on the order above
                continue
            order = {
                "ref": ref, "email": text(r.get("Email")).lower(), "placed_at": when(r.get("Created at")),
                "paid_status": text(r.get("Financial Status")).lower(), "fulfil_status": text(r.get("Fulfillment Status")).lower(),
                "fulfilled_at": when(r.get("Fulfilled at")), "cancelled_at": when(r.get("Cancelled at")),
                "subtotal_cents": cents(r.get("Subtotal")), "shipping_cents": cents(r.get("Shipping")), "tax_cents": cents(r.get("Taxes")),
                "refunded_cents": cents(r.get("Amount Refunded")), "total_cents": cents(r.get("Total")),
                "ship_method": text(r.get("Shipping Method")), "lines": [line],
                "bill_name": text(r.get("Billing Name")), "bill_street": street(r.get("Billing Address1"), r.get("Billing Address2")),
                "bill_suburb": text(r.get("Billing City")), "bill_state": text(r.get("Billing Province")),
                "bill_postcode": text(r.get("Billing Zip")), "bill_phone": phone(r.get("Billing Phone")),
                "ship_name": text(r.get("Shipping Name")), "ship_street": street(r.get("Shipping Address1"), r.get("Shipping Address2")),
                "ship_suburb": text(r.get("Shipping City")), "ship_state": text(r.get("Shipping Province")),
                "ship_postcode": text(r.get("Shipping Zip")), "ship_phone": phone(r.get("Shipping Phone")),
                "note": (r.get("Private Notes") or "").strip(), "payment_method": text(r.get("Payment Method")),
                "payment_ref": text(r.get("Payment Reference")),
            }
            if not order["placed_at"]:
                raise SystemExit("Order %s has no date" % ref)
            orders.append(order)

    refs = [o["ref"] for o in orders]
    if len(set(refs)) != len(refs):
        raise SystemExit("The same order number appears twice as a whole order: %s" % sorted({r for r in refs if refs.count(r) > 1}))

    out = sys.stdout
    out.reconfigure(encoding="utf-8", newline="\n")
    out.write("-- %d orders, %d lines, from a Squarespace export. People's details: run it, then delete it.\n" %
              (len(orders), sum(len(o["lines"]) for o in orders)))
    out.write("select set_config('app.farm', (select id::text from farm where slug = '%s'), false);\n" % farm)
    tag = "$sq$"
    payload = json.dumps(orders, ensure_ascii=False)
    while tag in payload:
        tag = tag[:-1] + "q$"
    out.write("select import_past_orders('squarespace', %s%s%s::jsonb) as loaded;\n" % (tag, payload, tag))
    sys.stderr.write("%d orders (%s to %s), %d lines\n" % (
        len(orders), min(o["placed_at"] for o in orders)[:10], max(o["placed_at"] for o in orders)[:10],
        sum(len(o["lines"]) for o in orders)))


if __name__ == "__main__":
    main()
