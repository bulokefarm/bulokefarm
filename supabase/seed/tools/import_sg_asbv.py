#!/usr/bin/env python3
"""
Turn a Sheep Genetics ASBV export (CSV) into one call of import_asbv (65).

    python import_sg_asbv.py export.csv 2026-09-15 toland > asbv_2026-09-15.sql

Run the SQL in the editor or with psql. It names the farm the way the
seeds do, so nobody needs to be signed in. Load the same run twice and
you get two runs; delete one from asbv_run and its values go with it.

The export's exact columns are not known until Toland sends one, so
this reads the header rather than trusting fixed names:
  - the ID column is the one whose values are sixteen characters: ten
    digits (flock, drop year) and a tag that may have letters in it,
  - the EID column is the one whose values are fifteen digits once the
    space is gone (940 110012345678),
  - a trait is any other column of small numbers (not a sire, dam,
    tag or year); a column called
    "<trait> Acc", "<trait>_ACC" or "Acc" straight after it is its
    accuracy.
It prints what it found to stderr. Check that before loading.
Only the standard library is needed.
"""
import csv, json, re, sys

SRC, RUN_ON = sys.argv[1], sys.argv[2]
FARM = sys.argv[3] if len(sys.argv) > 3 else "toland"
if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", RUN_ON):
    sys.exit("analysis date as YYYY-MM-DD")

with open(SRC, newline="", encoding="utf-8-sig") as f:
    rows = list(csv.reader(f))
head, body = [h.strip() for h in rows[0]], [r for r in rows[1:] if any(c.strip() for c in r)]
digits = lambda s: re.sub(r"\D", "", s or "")
alnum = lambda s: re.sub(r"[^0-9A-Za-z]", "", s or "").upper()
is_sg_id = lambda v: re.fullmatch(r"\d{10}[0-9A-Z]{6}", alnum(v)) is not None
col = lambda i: [r[i].strip() if i < len(r) else "" for r in body]

def share(i, test):
    vals = [v for v in col(i) if v]
    return len(vals) and sum(map(test, vals)) / len(vals) >= 0.9

def num(v):
    try:
        return float(v.replace(",", ""))
    except ValueError:
        return None

id_col  = next((i for i in range(len(head)) if share(i, is_sg_id)), None)
eid_col = next((i for i in range(len(head)) if i != id_col and share(i, lambda v: len(digits(v)) == 15)), None)
if id_col is None and eid_col is None:
    sys.exit("no sixteen-character ID or fifteen-digit EID column found")

# Columns of numbers that are not breeding values: who the parents are,
# tags, years. A value never has five digits before the point.
NOT_A_TRAIT = re.compile(r"sire|dam|tag|\bid\b|ident|year|drop|birth|dob|sex|flock|born|rear|group|no\.?$", re.I)
looks_like_id = lambda v: re.fullmatch(r"\d{5,}", v.replace(",", "")) is not None

ACC = re.compile(r"^(.*?)[\s_.-]*(acc|accuracy|%)$", re.I)
traits = {}                    # column -> (trait, accuracy column or None)
for i, h in enumerate(head):
    if (i in (id_col, eid_col) or ACC.match(h) or NOT_A_TRAIT.search(h)
            or not share(i, lambda v: num(v) is not None) or share(i, looks_like_id)):
        continue
    trait = re.sub(r"[^A-Za-z0-9+_-]", "", h).upper()[:16]
    if not trait:
        continue
    acc = None
    for j, g in enumerate(head):
        m = ACC.match(g)
        if m and (re.sub(r"[^A-Za-z0-9+]", "", m.group(1)).upper() == trait.replace("_", "")
                  or (j == i + 1 and not m.group(1).strip())):
            acc = j
            break
    traits[i] = (trait, acc)

print(f"ID: {head[id_col] if id_col is not None else '-'}  EID: {head[eid_col] if eid_col is not None else '-'}", file=sys.stderr)
for i, (t, a) in traits.items():
    print(f"  {t:<8} from {head[i]!r}" + (f", accuracy {head[a]!r}" if a is not None else ", no accuracy"), file=sys.stderr)

out = []
for r in body:
    cell = lambda i: r[i].strip() if i is not None and i < len(r) else ""
    vals = {}
    for i, (t, a) in traits.items():
        v = num(cell(i))
        if v is not None:
            acc = num(cell(a)) if a is not None else None
            vals[t] = [v, round(acc) if acc is not None else None]
    out.append({"sg_id": alnum(cell(id_col)) or None, "eid": digits(cell(eid_col)) or None, "values": vals})

print(f"{len(out)} animals, {len(traits)} traits", file=sys.stderr)
print(f"select set_config('app.farm', (select id::text from farm where slug = '{FARM}'), false);")
print(f"select import_asbv('{RUN_ON}', $json${json.dumps(out, separators=(',', ':'))}$json$::jsonb, "
      f"'{SRC.replace(chr(39), '')}');")
