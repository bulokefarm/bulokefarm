#!/usr/bin/env python3
"""Mailchimp audience exports (csv) -> SQL that loads the mailing list.

    python import_mailchimp_audience.py subscribed_….csv unsubscribed_….csv cleaned_….csv buloke \
        > ../somewhere-outside-the-repo/mailing_list.sql

Mailchimp exports an audience as up to three files. Which one a file is
is read from its columns, not its name: UNSUB_TIME means unsubscribed,
CLEAN_TIME means cleaned (an address that bounced — "bounced" here),
neither means subscribed. Give it all three: the people who left are the
ones the list most needs to remember.

The SQL calls import_subscribers() (migration 73) once per file, so the
rules for someone already on the list are the database's, not this
script's: the later change wins, and an opt-out is never undone by an
older "subscribed".

THE OUTPUT IS PEOPLE'S EMAIL ADDRESSES. It is not a seed: do not write
it into supabase/seed/ and do not commit it. Run it and delete it.

Only what a person told us is taken: email, names, the State they
typed. Mailchimp's guesses from an IP address (REGION, TIMEZONE, CC)
are left behind.
"""
import csv
import datetime
import json
import sys

REASONS = {"NORMAL": "", "NOSIGNUP": "said they never signed up", "SPAM": "marked it as spam",
           "INAPPROPRIATE": "said it was inappropriate", "OTHER": ""}


def when(s):
    s = (s or "").strip()
    for fmt in ("%Y-%m-%d %H:%M:%S", "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M", "%Y-%m-%d %H:%M", "%Y-%m-%d"):
        try:
            return datetime.datetime.strptime(s, fmt).strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            pass
    return None


def read(path):
    with open(path, newline="", encoding="utf-8-sig") as fh:
        rows = list(csv.DictReader(fh))
    if not rows:
        return None, []
    cols = rows[0].keys()
    status = "unsubscribed" if "UNSUB_TIME" in cols else "bounced" if "CLEAN_TIME" in cols else "subscribed"
    out = []
    for r in rows:
        g = lambda k: (r.get(k) or "").strip()
        if status == "unsubscribed":
            why = REASONS.get(g("UNSUB_REASON"), g("UNSUB_REASON").lower()) or g("UNSUB_REASON_OTHER")
            note = "; ".join(x for x in ("Unsubscribed from “%s”" % g("UNSUB_CAMPAIGN_TITLE") if g("UNSUB_CAMPAIGN_TITLE") else "",
                                         why) if x)
            changed = when(g("UNSUB_TIME"))
        elif status == "bounced":
            note = "Bounced on “%s”" % g("CLEAN_CAMPAIGN_TITLE") if g("CLEAN_CAMPAIGN_TITLE") else ""
            changed = when(g("CLEAN_TIME"))
        else:
            note = ""
            changed = when(g("LAST_CHANGED")) or when(g("CONFIRM_TIME"))
        out.append({"email": g("Email Address"), "first_name": g("First Name"), "last_name": g("Last Name"),
                    "state": g("State"), "opted_in_on": when(g("CONFIRM_TIME")) or when(g("OPTIN_TIME")) or "",
                    "changed_on": changed or "", "note": note,
                    "source": "Mailchimp: " + g("SOURCE") if g("SOURCE") else "Mailchimp"})
    return status, out


def main():
    *paths, farm = sys.argv[1:]
    out = sys.stdout
    out.reconfigure(encoding="utf-8", newline="\n")
    out.write("-- Mailing list from Mailchimp. Personal data: run it, then delete it. Never commit.\n\n")
    out.write("select set_config('app.farm', (select id::text from farm where slug = '%s'), false);\n\n"
              % farm.replace("'", "''"))
    # Opt-outs last, so that within one run they are what is left standing.
    loaded = sorted((read(p) for p in paths), key=lambda x: x[0] == "subscribed", reverse=True)
    for status, rows in loaded:
        if not rows:
            continue
        body = json.dumps(rows, ensure_ascii=False).replace("$ml$", "")
        out.write("select import_subscribers('%s', $ml$%s$ml$::jsonb) as %s;\n\n" % (status, body, status))
        sys.stderr.write("%s: %d\n" % (status, len(rows)))


if __name__ == "__main__":
    main()
