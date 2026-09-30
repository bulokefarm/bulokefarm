#!/usr/bin/env python3
"""
Convert Toland Merino's ewe export (studs.csv) into seed SQL.

    python migrate_toland_csv.py studs.csv ../toland/10_ewes.sql toland

Columns as exported: Color, Visual Id, Sire, Dam, No.Born, Horn, EID,
GRADE, Note, Sex. No date of birth: by Richard's rule a ewe is born on
1 June of the year in the first two digits of her Visual Id, 230040
being a 2023 drop. That is a stated convention, not a measurement, and
the notes file says so.

Same shape as migrate_cattle_xlsx.py: no UUIDs made here, natural keys
and subqueries, every statement guarded so the file can be run again.
Only the standard library is needed.
"""
import csv, re, sys
from collections import Counter

SRC  = sys.argv[1] if len(sys.argv) > 1 else "studs.csv"
OUT  = sys.argv[2] if len(sys.argv) > 2 else "10_ewes.sql"
FARM = sys.argv[3] if len(sys.argv) > 3 else "toland"
PIC  = "3SBES046"          # Toland's own, primary
BREED = "Merino"           # a Merino stud; flagged in the notes all the same

# The NLIS colour cycle, as year_letter() has it since migration 46.
COLOUR = {2024: 'BK', 2025: 'W', 2026: 'O', 2027: 'G', 2028: 'P', 2029: 'Y', 2030: 'R', 2031: 'BU'}
COLOUR_OF_YEAR = lambda y: COLOUR[2024 + ((y - 2024) % 8)]

FARM_LINE = (
    "-- The seeds run as postgres, where current_farm() has no membership to consult,\n"
    "-- so the farm is named here and every insert takes it by default.\n"
    f"select set_config('app.farm', (select id::text from farm where slug = '{FARM}'), false);\n")


def q(v):
    if v is None or v == '':
        return 'null'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(v)
    return "'" + str(v).strip().replace("'", "''") + "'"


def main():
    with open(SRC, newline='', encoding='utf-8-sig') as f:
        rows = [{k.strip(): (v or '').strip() for k, v in r.items()} for r in csv.DictReader(f)]

    warn, out = [], [FARM_LINE]
    out.append(f"-- Generated from {SRC.split('/')[-1].split(chr(92))[-1]} by migrate_toland_csv.py — do not hand-edit.\n"
               "-- Needs the farm row to exist already (farm_scope_plan.md §9).\n"
               "begin;\n")

    # --- the ewes, checked ------------------------------------------
    ewes = {}
    for i, r in enumerate(rows, start=2):        # line numbers as in the file
        vid = r['Visual Id']
        if not re.fullmatch(r'\d{6}', vid):
            warn.append(f"line {i}: Visual Id '{vid}' is not six digits — skipped")
            continue
        if vid in ewes:
            warn.append(f"line {i}: Visual Id {vid} appears twice — second skipped")
            continue
        year = 2000 + int(vid[:2])
        colour = COLOUR_OF_YEAR(year)
        if r['Color'] != colour:
            warn.append(f"line {i} ({vid}): colour '{r['Color']}' in the file, "
                        f"{colour} is the NLIS colour for {year} — file's colour kept as the tag")
            colour = r['Color'] or colour
        sex = {'F': 'female', 'M': 'male', 'W': 'wether'}.get(r['Sex'].upper())
        if sex is None:
            warn.append(f"line {i} ({vid}): Sex '{r['Sex']}' not F, M or W — recorded unknown")
            sex = 'unknown'
        horn = r['Horn'].upper() or None
        if horn and horn not in ('P', 'H', 'PP', 'PH', 'HH'):
            warn.append(f"line {i} ({vid}): Horn '{r['Horn']}' not PP, PH or HH — left blank")
            horn = None
        born = int(r['No.Born']) if r['No.Born'].isdigit() and 1 <= int(r['No.Born']) <= 5 else None
        if r['No.Born'] and born is None:
            warn.append(f"line {i} ({vid}): No.Born '{r['No.Born']}' — left blank")
        eid = re.sub(r'\s+', ' ', r['EID']) or None
        if eid and not re.fullmatch(r'940 \d{12}', eid):
            warn.append(f"line {i} ({vid}): EID '{eid}' is not 940 and twelve digits — kept as written")
        ewes[vid] = dict(line=i, code=f"{colour} {vid}", letter=colour, num=int(vid),
                         dob=f"{year}-06-01", sex=sex, horn=horn, born=born, eid=eid,
                         grade=r['GRADE'] or None, note=r['Note'] or None,
                         sire=r['Sire'] or None, dam=r['Dam'] or None)

    # --- who is on file and who is not ------------------------------
    ext_sires = sorted({e['sire'] for e in ewes.values() if e['sire'] and e['sire'] not in ewes})
    ext_dams  = sorted({e['dam']  for e in ewes.values() if e['dam']  and e['dam']  not in ewes})
    both = set(ext_sires) & set(ext_dams)
    for b in sorted(both):
        warn.append(f"'{b}' is written as a sire on one line and a dam on another — recorded once, sex unknown")

    # --- property ---------------------------------------------------
    out.append("-- Toland's own PIC. Already there on production; here for a rebuild.")
    out.append(f"insert into property (pic, is_own, is_primary, name) values ({q(PIC)}, true, true, 'Toland Merino') "
               "on conflict (farm_id, pic) do nothing;")

    # --- reference animals ------------------------------------------
    out.append("\n-- Reference animals: sires and dams not in this file. Toland's own rams and\n"
               "-- older ewes by their number, outside rams as written (KIA210266 and so on).\n"
               "-- Promote to a resident animal when their own file arrives.")
    ref = lambda name: (f"(select id from animal where farm_id = current_farm() and origin = 'reference' "
                        f"and name = {q(name)} limit 1)")
    for name in sorted(set(ext_sires) | set(ext_dams)):
        sex = 'unknown' if name in both else ('male' if name in ext_sires else 'female')
        out.append(f"insert into animal (species, name, origin, sex) select 'sheep', {q(name)}, 'reference', {q(sex)} "
                   f"where not exists (select 1 from animal where farm_id = current_farm() "
                   f"and origin = 'reference' and name = {q(name)});")

    # --- the ewes ---------------------------------------------------
    res = lambda code: (f"(select id from animal where farm_id = current_farm() and species = 'sheep' "
                        f"and origin <> 'reference' and stock_code = {q(code)} limit 1)")
    out.append("\n-- The ewes. Born 1 June of the year in the tag, by Richard's rule.")
    for vid, e in ewes.items():
        out.append(f"""insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', {q(e['code'])}, {q(e['letter'])}, {e['num']}, {q(e['eid'])}, 'bred', {q(e['sex'])}, {q(e['dob'])},
  {q(BREED)}, {q(e['grade'])}, {q(e['horn'])}, {q(e['born'])},
  (select id from property where farm_id = current_farm() and pic = {q(PIC)}), {q(e['note'])}
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = {q(e['code'])});""")

    # --- pedigree, once every animal exists -------------------------
    out.append("\n-- Pedigree")
    for vid, e in ewes.items():
        for col, field in (('sire', 'sire_id'), ('dam', 'dam_id')):
            v = e[col]
            if not v:
                continue
            target = res(ewes[v]['code']) if v in ewes else ref(v)
            out.append(f"update animal set {field} = {target} where id = {res(e['code'])} and {field} is null;")

    # --- status -----------------------------------------------------
    out.append("\n-- Status: alive and a breeder from the day she was born, there being no other date.")
    for vid, e in ewes.items():
        out.append(f"insert into animal_status (animal_id, effective_on, life_state, class, reason) "
                   f"select {res(e['code'])}, {q(e['dob'])}, 'alive', 'breeder', 'Imported from the stud file' "
                   f"where not exists (select 1 from animal_status where animal_id = {res(e['code'])});")

    out.append("\ncommit;")

    with open(OUT, 'w', newline='\n', encoding='utf-8') as f:
        f.write("\n".join(out) + "\n")

    # --- notes ------------------------------------------------------
    n = len(ewes)
    no_dam = sum(1 for e in ewes.values() if not e['dam'])
    no_horn = sum(1 for e in ewes.values() if not e['horn'])
    retag = [(e['code'], e['note']) for e in ewes.values() if e['note'] and re.match(r'(?i)was\s+\d', e['note'])]
    notes = Counter(e['note'].upper() for e in ewes.values() if e['note'])
    by_year = Counter(e['dob'][:4] for e in ewes.values())
    lines = [
        "# Toland ewe import — things to check", "",
        f"{n} ewes, all alive, all breeders, from {SRC.split(chr(92))[-1].split('/')[-1]}.", "",
        "- **Date of birth is a convention, not a record.** The file has none. Every ewe is "
        "entered as born on 1 June of the year in the first two digits of her tag (Richard, "
        "30 Sep 2026). Ages, the drop a ewe belongs to and the year her natural increase "
        "counts in all follow from it. Replace with real lambing dates if the stud program can export them.",
        f"- Drops: " + ", ".join(f"{y} × {c}" for y, c in sorted(by_year.items())) + ".",
        f"- Tags are the colour then the six-digit Visual Id, `BU 230040`, so the colour pill "
        "works as it does for Buloke's sheep. Migration 62 lets the parser read six digits.",
        f"- Breed set to {BREED} for all {n}; the file does not say. Confirm with Anna.",
        f"- {len(ext_sires)} sires, none in this file (it is the ewes only): reference animals. "
        f"{len([s for s in ext_sires if not s.isdigit()])} carry a stud prefix and are outside rams: "
        + ", ".join(s for s in ext_sires if not s.isdigit()) + ".",
        f"- {len(ext_dams)} dams not in this file: reference animals by number. "
        f"{sum(1 for e in ewes.values() if e['dam'] in ewes)} ewes have a dam in the file and link to her directly. "
        f"{no_dam} ewe(s) have no dam written.",
        "- Sires and dams not on file are named exactly as written. When Toland's rams and older ewes "
        "are imported, those references should become the real animals.",
        f"- Horn is PP, PH or HH as tested; {no_horn} blank.",
        "- EID is the RFID form, 940 and twelve digits, kept with its space as written. Buloke's "
        "sheep carry the PIC form instead; NLIS accepts either.",
        f"- {len(retag)} retag notes kept as notes, the current tag being the one in Visual Id: "
        + ", ".join(f"{c} ({t})" for c, t in retag) + ".",
        "- Notes kept verbatim. Most common: "
        + ", ".join(f"'{t}' × {c}" for t, c in notes.most_common(5))
        + ". 'LL 2026' is read as lost lamb 2026 and 'A PLUS' as a classing mark; neither is parsed into a field.",
        "- No paddocks: nothing in the file says where a ewe is. Move mobs on the phone once the map is traced.",
        "- No joinings, weights, treatments or shearing in this file.",
    ]
    if warn:
        lines += ["", "## Rows flagged by the converter", ""] + [f"- {w}" for w in dict.fromkeys(warn)]
    notes_path = OUT.replace('10_ewes.sql', 'notes/01_ewe_import.md')
    with open(notes_path, 'w', newline='\n', encoding='utf-8') as f:
        f.write("\n".join(lines) + "\n")

    print(f"Wrote {OUT} and {notes_path}")
    print(f"  {n} ewes, {len(set(ext_sires) | set(ext_dams))} reference animals, {len(warn)} flagged")


if __name__ == '__main__':
    main()
