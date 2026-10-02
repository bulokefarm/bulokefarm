#!/usr/bin/env python3
"""
Convert Dad's cattle sheet (the Rupari herd, PIC 3BWTW595) into seed SQL.

    python migrate_rupari_csv.py "Cattle Data per Buloke App V1 260800.csv" ../buloke/40_rupari.sql

The sheet is the Buloke layout with Dad's columns: Purpose, Heritage,
Status, Name, Stock ... first and second joinings, and the planned
joins. Only the Rupari rows are read. The Buloke rows at the foot are
already on file from 10_herd.sql and the phone.

Dad's PIC goes on Buloke's farm as a second own PIC (README: two
own-PICs under the one farm). Three stock codes collide with Buloke's
or with each other and take an R: S 16R, U 20R, V 08R (Richard,
2 Oct 2026).

Names are matched by hand below, not by heuristic: the file is 42 rows
and every sire and dam spelling has been read. Same shape as
migrate_toland_csv.py: no UUIDs, natural keys, every statement guarded
so the file can be run again. Standard library only.
"""
import csv, re, sys
from datetime import date

SRC  = sys.argv[1] if len(sys.argv) > 1 else "Cattle Data per Buloke App V1 260800.csv"
OUT  = sys.argv[2] if len(sys.argv) > 2 else "40_rupari.sql"
FARM = sys.argv[3] if len(sys.argv) > 3 else "buloke"
PIC  = "3BWTW595"                 # Dad's; blank PIC cells default to it
AS_AT = date(2026, 10, 2)         # the day the sheet came in; classes calf/yearling by age on it
GESTATION = 285

# Columns, 0-indexed, as the sheet has them.
C = dict(purpose=0, heritage=1, life=2, name=3, stock=4, colour=7, grade=8, horn=9, sex=10,
         dob=11, sire=12, dam=13, nlis=14, breed=15, pic=16, orig_pic=17, purch=18,
         comment=19, calv_comment=20, calv_cycle=22, birth_wt=26, gest=27, wean_wt=28,
         wean_on=29, j1=31, j1_conf=32, j1_to=33, j1_due=34, j1_act=35,
         j2=36, j2_conf=37, j2_to=38, j2_due=39, j2_act=40,
         plan_on=41, plan1=42, plan2=43)
LAST_READ = 43                    # columns after this (carcase, sale, GST) are checked empty

# Stock codes that collide: (code as written, name) -> code on file.
RECODE = {('S 16', 'Sasher Lee'): 'S 16R',            # Buloke's Bre. Sandy S16
          ('U 20', 'Bre. Ultima (ex U2)'): 'U 20R',   # Buloke's U 20, XBL0080
          ('V 08', 'Verity Lee'): 'V 08R'}            # Bre. Valda V08 keeps V 08

# Parents written by name who are resident: in this file, or Buloke's own.
RESIDENT = {'D. Cool Lucia': 'P 14', 'D. Lucia': 'P 22', 'D. Black Rose': 'Q 39',
            'Raina BUPR0044': 'R 44', 'Raina R44': 'R 44',
            'Stella Noir': 'S 06', 'Stella Noir S6': 'S 06',
            'Sasher Lee': 'S 16R', 'Sarong': 'S 18', 'Sally Lee': 'S 20',
            'Unita U02': 'U 02', 'Ulainee Lee U04': 'U 04',
            'B. Underdone U8': 'U 08',
            'Bre. Ultima U22': 'U 20R',      # Ultima is U 20 here; U 22 is a Buloke heifer
            'Bre. Valda V08': 'V 08', 'Bre. Vova-done V18': 'V 18',
            'Veteran': 'V 07',
            'Gerbera': 'G 02'}               # Buloke's, Rupari heritage

# Spellings of one outside animal, to the name on file. Names already on
# Buloke's file (Atlas, Russel, MJB United 333U?PP ...) are reused as they are.
ALIAS = {'Kasper': "Kasper d'Poll", 'Henri': "Henri d'Poll",
         'Sitz STELLAR ssf': 'Sitz STELLAR',
         'Bre M 29 (P)': 'Bre. M 29 (P)', 'Bre? M 29 (P)': 'Bre. M 29 (P)',
         'Russell': 'Russel', 'WW Atlas': 'Atlas',
         'MJB United': 'MJB United 333U?PP'}

# Bulls with straws in the tank, by the tank's spelling. A joining or plan
# to one of these is AI; the straw is linked where the tank has one batch.
TANK = {'Sitz STELLAR': 'Sitz STELLAR ssf', 'Chiltn Pk MOE M6': 'Chiltern Pk Moe  M6',
        'Hammer': "R. Hammer d'Poll  H29", 'Norrie': "R. Norrie d'Poll    N23",
        'James J1': 'Rupari James   J01', 'Kotsukari': 'TWA Kotsukari',
        'P STATESMAN S115': 'Paringa Statesman S115', 'MJB United 333U?PP': 'MJB United 333U ?PP?',
        "Kasper d'Poll": "R. Kasper d'Poll", 'Atlas': 'W.W. Atlas',
        "Henri d'Poll": "R. Henri d'Poll   H15"}
NATURAL = {'Veteran'}               # Dad's own bull, V 07

FARM_LINE = (
    "-- The seeds run as postgres, where current_farm() has no membership to consult,\n"
    "-- so the farm is named here and every insert takes it by default.\n"
    f"select set_config('app.farm', (select id::text from farm where slug = '{FARM}'), false);\n")


def clean(v):
    return re.sub(r'\s+', ' ', (v or '').strip())


def name_of(v):
    v = clean(v)
    return ALIAS.get(v, v) if v else None


def parse_date(v):
    v = clean(v)
    if not v:
        return None
    d, m, y = (int(x) for x in v.split('/'))
    return date(y + 2000 if y < 100 else y, m, d)


def pct(v):
    v = clean(v).rstrip('%')
    return int(v) if v else None


def q(v):
    if v is None or v == '':
        return 'null'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, date):
        return f"'{v.isoformat()}'"
    return "'" + str(v).strip().replace("'", "''") + "'"


def norm_stock(v):
    m = re.match(r'^([A-Z])\s*0*(\d+)$', clean(v).upper())
    return f"{m.group(1)} {int(m.group(2)):02d}" if m else clean(v)


def season_of(d):
    return f"{d.year}-{d.year + 1}" if d.month >= 7 else f"{d.year - 1}-{d.year}"


def months(dob):
    return (AS_AT.year - dob.year) * 12 + AS_AT.month - dob.month - (AS_AT.day < dob.day)


def main():
    with open(SRC, newline='', encoding='utf-8-sig') as f:
        rows = list(csv.reader(f))

    warn, out = [], [FARM_LINE]
    out.append(f"-- Generated from {SRC.replace(chr(92), '/').split('/')[-1]} by migrate_rupari_csv.py — do not hand-edit.\n"
               "-- Dad's herd, Rupari heritage, PIC 3BWTW595. Runs after 10_herd.sql: it links to\n"
               "-- Buloke's Gerbera (G 02) and reuses Buloke's reference bulls by name.\n"
               "begin;\n")

    # --- the animals, checked ---------------------------------------
    cows = {}
    for i, r in enumerate(rows, start=1):
        r = r + [''] * (60 - len(r))
        if clean(r[C['heritage']]) != 'Rupari' or not clean(r[C['stock']]):
            continue
        name = clean(r[C['name']])
        code = norm_stock(r[C['stock']])
        code = RECODE.get((code, name), code)
        if code in cows:
            warn.append(f"row {i}: {code} already used by {cows[code]['name']} — {name} skipped")
            continue
        if any(clean(x).strip(',') for x in r[LAST_READ + 1:]):
            warn.append(f"row {i} ({code}): something in the sale/carcase columns, not imported")
        sex = {'female': 'female', 'male': 'male', 'steer': 'steer'}.get(clean(r[C['sex']]).lower(), 'unknown')
        dob = parse_date(r[C['dob']])
        nlis = clean(r[C['nlis']])
        if nlis in ('?', 'Nil.', 'Nil'):
            nlis = None
        pic = clean(r[C['pic']]) or None
        if not pic:
            warn.append(f"{code} {name}: no PIC in the sheet — put on Dad's, {PIC}")
            pic = PIC
        comment = clean(r[C['comment']])
        born_as = 2 if comment.lower() == 'twin' else None
        if born_as:
            comment = ''
        gest = clean(r[C['gest']])
        note = '. '.join(x for x in (comment, f"Carried {gest} days" if gest else '') if x) or None
        purpose = clean(r[C['purpose']])
        age = months(dob)
        cls = ('bull' if 'Bull' in purpose else 'breeder' if purpose == 'Breeder'
               else 'calf' if age < 9 else 'yearling' if purpose == 'Heifer' else 'harvest')
        joins = []
        for n, k in ((1, 'j1'), (2, 'j2')):
            jd = parse_date(r[C[k]])
            if not jd:
                continue
            sire = name_of(r[C[k + '_to']])
            due, act = parse_date(r[C[k + '_due']]), parse_date(r[C[k + '_act']])
            joins.append(dict(attempt=n, on=jd, sire=sire, conf=pct(r[C[k + '_conf']]), due=due, act=act,
                              method='natural' if sire in NATURAL else 'ai'))
            if sire not in NATURAL and sire not in TANK:
                warn.append(f"{code} {name}: join {n} to '{sire}' — no straws of that name in the tank; "
                            "recorded as AI with no straw linked")
            if not due:
                warn.append(f"{code} {name}: join {n} on {jd:%d/%m/%y} has no due date — kept, off Due, "
                            f"season {season_of(jd.fromordinal(jd.toordinal() + GESTATION))} by 285 days")
        plans = []
        pon = parse_date(r[C['plan_on']])
        for n, k in ((1, 'plan1'), (2, 'plan2')):
            b = name_of(r[C[k]])
            if b:
                plans.append(dict(attempt=n, sire=b, on=pon if n == 1 else None))
        cows[code] = dict(row=i, code=code, name=name, purpose=purpose, cls=cls,
                          letter=code[0], num=int(re.search(r'\d+', code).group()),
                          nlis=nlis, sex=sex, dob=dob, breed=clean(r[C['breed']]) or None,
                          grade=clean(r[C['grade']]) or None, colour=clean(r[C['colour']]) or None,
                          horn=clean(r[C['horn']]).upper() or None, born_as=born_as,
                          pic=pic, orig_pic=clean(r[C['orig_pic']]) or None,
                          purch=parse_date(r[C['purch']]), note=note,
                          birth_wt=clean(r[C['birth_wt']]) or None,
                          wean_wt=clean(r[C['wean_wt']]) or None, wean_on=parse_date(r[C['wean_on']]),
                          sire=name_of(r[C['sire']]), dam=name_of(r[C['dam']]),
                          joins=joins, plans=plans)

    def resident(v):
        return RESIDENT.get(v) if v else None

    # --- properties and heritage ------------------------------------
    out.append("-- Dad's PIC becomes one of Buloke's own. It was on file as an outside PIC,\n"
               "-- the one Buloke's Rupari-bred stock came from.")
    out.append(f"insert into property (pic, is_own) values ({q(PIC)}, true) on conflict (farm_id, pic) do nothing;")
    out.append(f"update property set is_own = true where farm_id = current_farm() and pic = {q(PIC)} and not is_own;")
    for p in sorted({c['orig_pic'] for c in cows.values() if c['orig_pic']} | {c['pic'] for c in cows.values()}):
        if p != PIC:
            out.append(f"insert into property (pic, is_own) values ({q(p)}, false) on conflict (farm_id, pic) do nothing;")
    out.append("insert into heritage (name) values ('Rupari') on conflict (farm_id, name) do nothing;")

    # --- reference animals ------------------------------------------
    refs = {}
    for c in cows.values():
        for v, sex in ((c['sire'], 'male'), (c['dam'], 'female')):
            if v and not resident(v):
                refs.setdefault(v, sex)
        for j in c['joins'] + c['plans']:
            if j['sire'] and not resident(j['sire']):
                refs.setdefault(j['sire'], 'male')
    out.append("\n-- Reference animals: outside sires and dams. Names already on Buloke's file\n"
               "-- (Atlas, Russel, M. Umberto U3 ...) are found, not made again.")
    for name, sex in sorted(refs.items()):
        out.append(f"insert into animal (species, name, origin, sex) select 'cattle', {q(name)}, 'reference', {q(sex)} "
                   f"where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' "
                   f"and origin = 'reference' and name = {q(name)});")

    ref = lambda n: (f"(select id from animal where farm_id = current_farm() and species = 'cattle' "
                     f"and origin = 'reference' and name = {q(n)} order by created_at limit 1)")
    res = lambda code: (f"(select id from animal where farm_id = current_farm() and species = 'cattle' "
                        f"and origin <> 'reference' and stock_code = {q(code)})")
    who = lambda n: res(resident(n)) if resident(n) else ref(n)
    straw = lambda n: (f"(select min(id::text)::uuid from ai_semen where farm_id = current_farm() "
                       f"and sire_name = {q(TANK[n])} having count(*) = 1)" if n in TANK else 'null')

    # --- the animals ------------------------------------------------
    out.append("\n-- Dad's cattle")
    for c in cows.values():
        out.append(f"""insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', {q(c['code'])}, {q(c['letter'])}, {c['num']}, {q(c['name'])}, {q(c['nlis'])},
  {q('purchased' if c['purch'] else 'bred')}, {q(c['sex'])}, {q(c['dob'])},
  {q(c['breed'])}, {q(c['grade'])}, {q(c['colour'])}, {q(c['horn'])}, {q(c['born_as'])},
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = {q(c['pic'])}),
  (select id from property where farm_id = current_farm() and pic = {q(c['orig_pic'])}),
  {q(c['purch'])}, {c['birth_wt'] or 'null'}, {q(c['wean_on'])}, {q(c['note'])}
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = {q(c['code'])});""")

    out.append("\n-- Pedigree")
    for c in cows.values():
        for v, field in ((c['sire'], 'sire_id'), (c['dam'], 'dam_id')):
            if v:
                out.append(f"update animal set {field} = {who(v)} where id = {res(c['code'])} and {field} is null;")

    out.append("\n-- Status as at birth, the class being what the sheet's Purpose says today")
    for c in cows.values():
        out.append(f"insert into animal_status (animal_id, effective_on, life_state, class, reason) "
                   f"select {res(c['code'])}, {q(c['dob'])}, 'alive', {q(c['cls'])}, 'Imported from Dad''s sheet' "
                   f"where not exists (select 1 from animal_status where animal_id = {res(c['code'])});")

    out.append("\n-- Weaning weights")
    for c in cows.values():
        if c['wean_wt'] and c['wean_on']:
            out.append(f"insert into weight_event (animal_id, weighed_on, weight_kg, notes) "
                       f"values ({res(c['code'])}, {q(c['wean_on'])}, {c['wean_wt']}, 'Weaning, from Dad''s sheet') "
                       f"on conflict (animal_id, weighed_on) do nothing;")

    # --- joinings ---------------------------------------------------
    out.append("\n-- Joinings. AI where the bull is in the tank, natural to Veteran. Confidence is\n"
               "-- confidence_pct on an AI joining and the 0-1 figure on a natural one.")
    n_join = 0
    for c in cows.values():
        for j in c['joins']:
            n_join += 1
            gd = (j['due'] - j['on']).days if j['due'] else GESTATION
            season = season_of(j['due'] or j['on'].fromordinal(j['on'].toordinal() + GESTATION))
            conf, conf_pct = ((j['conf'] / 100 if j['conf'] is not None else None), None) \
                if j['method'] == 'natural' else (None, j['conf'])
            out.append(f"insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, "
                       f"gestation_days, due_on, confidence, confidence_pct, outcome, notes) "
                       f"select {res(c['code'])}, {who(j['sire'])}, {q(j['method'])}, "
                       f"{straw(j['sire']) if j['method'] == 'ai' else 'null'}, "
                       f"{q('spring' if (j['due'] or j['on']).month in range(7, 12) else 'autumn') if j['due'] else 'null'}, "
                       f"{q(season)}, {j['attempt']}, {q(j['on'])}, {gd}, {q(j['due'])}, {q(conf)}, {q(conf_pct)}, "
                       f"{q('calved' if j['act'] else 'unknown')}, 'From Dad''s sheet' "
                       f"where not exists (select 1 from joining where dam_id = {res(c['code'])} "
                       f"and season = {q(season)} and attempt = {j['attempt']});")

    # --- calvings ---------------------------------------------------
    out.append("\n-- Calvings: every calf here whose dam is resident, and a dam's actual calving date.")
    calves = {}
    for c in cows.values():
        if resident(c['dam']):
            calves.setdefault((resident(c['dam']), c['dob']), []).append(c['code'])
    n_calv = 0
    joined = lambda dam, on: (f"(select id from joining where dam_id = {res(dam)} and joined_on = {q(on)} "
                              f"order by attempt desc limit 1)")
    for c in cows.values():
        for j in c['joins']:
            if j['act'] and (c['code'], j['act']) not in calves:
                n_calv += 1
                warn.append(f"{c['code']} {c['name']}: calved {j['act']:%d/%m/%y} by the sheet; the calf is "
                            "not in it yet — calving recorded with no calf and no outcome")
                out.append(f"insert into calving (dam_id, joining_id, calved_on, notes) "
                           f"select {res(c['code'])}, {joined(c['code'], j['on'])}, {q(j['act'])}, "
                           f"'Calved by Dad''s sheet; calf not yet recorded' "
                           f"where not exists (select 1 from calving where dam_id = {res(c['code'])} "
                           f"and calved_on = {q(j['act'])});")
    for (dam, dob), kids in calves.items():
        j = next((j for j in cows[dam]['joins'] if j['act'] == dob), None) if dam in cows else None
        for kid in kids:
            n_calv += 1
            out.append(f"insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) "
                       f"select {res(dam)}, {joined(dam, j['on']) if j else 'null'}, {q(dob)}, {res(kid)}, "
                       f"'live', {q('Twin' if len(kids) > 1 else None)} "
                       f"where not exists (select 1 from calving where calf_id = {res(kid)});")

    # --- plans ------------------------------------------------------
    out.append("\n-- Planned joins: the first bull on the planned date, the second as the back-up.")
    n_plan = 0
    for c in cows.values():
        pon = next((p['on'] for p in c['plans'] if p['on']), None)
        if c['plans'] and not pon:
            warn.append(f"{c['code']} {c['name']}: planned bull with no planned date — not imported")
            continue
        for p in c['plans']:
            n_plan += 1
            season = season_of(pon.fromordinal(pon.toordinal() + GESTATION))
            out.append(f"insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) "
                       f"select {res(c['code'])}, 'ai', {who(p['sire'])}, {straw(p['sire'])}, {q(season)}, "
                       f"{p['attempt']}, {q(p['on'])}, 'From Dad''s sheet' "
                       f"where not exists (select 1 from planned_joining where dam_id = {res(c['code'])} "
                       f"and season = {q(season)} and attempt = {p['attempt']} and joining_id is null "
                       f"and cancelled_on is null);")

    out.append("\ncommit;")
    with open(OUT, 'w', newline='\n', encoding='utf-8') as f:
        f.write("\n".join(out) + "\n")

    # --- notes ------------------------------------------------------
    by_cls = {}
    for c in cows.values():
        by_cls[c['cls']] = by_cls.get(c['cls'], 0) + 1
    lines = [
        "# Dad's cattle (Rupari, PIC 3BWTW595) — things to check", "",
        f"{len(cows)} head, all alive, from {SRC.replace(chr(92), '/').split('/')[-1]}: "
        + ", ".join(f"{n} {k}" for k, n in sorted(by_cls.items())) + ". "
        f"{n_join} joinings, {n_calv} calvings, {n_plan} planned joins. "
        "The Buloke rows at the foot of the sheet were left alone.", "",
        "- **PIC 3BWTW595 is now one of Buloke's own**, beside 3BWWY089. It was on file as an "
        "outside PIC. Filter by PIC wherever the two need telling apart.",
        "- **Three stock codes carry an R** because the code was taken: S 16R Sasher Lee "
        "(Buloke's Bre. Sandy is S 16), U 20R Bre. Ultima (Buloke's U 20), V 08R Verity Lee "
        "(Bre. Valda keeps V 08; both were V 08 in the sheet). Rename on the card once the tags are settled.",
        "- Xpatriot X 01's dam is written *Bre. Ultima U22*. Ultima is U 20 in this sheet (ex U2), and "
        "Buloke's U 22 is another heifer, so he is linked to Ultima, U 20R. Check.",
        "- Xalla X 08's dam *B. Underdone U8* is linked to U 08, *Bre Underdone U05*, on Buloke's PIC "
        "(transferred 13/4/24).",
        "- Raina R 44's dam Gerbera is Buloke's G 02 and is linked to her.",
        "- Outside bulls reuse Buloke's names where they are surely the same: Atlas (and *WW Atlas*), "
        "Russel (written *Russell* here), MJB United 333U?PP, M. Umberto U3, G/bat K456 Wgyu, "
        "Kildare Pharoh P99, Bre. Quicksilver (P), Bre. Poppy. *Kasper* is merged with *Kasper d'Poll*, "
        "*Henri* with *Henri d'Poll*, *Sitz STELLAR ssf* with *Sitz STELLAR*, and both *Bre M 29* "
        "spellings into Bre. M 29 (P).",
        "- Every joining and plan is AI except R 44 to Veteran (V 07, natural, 5%). A straw is linked "
        "where the tank holds one batch of that bull; W.W. Atlas has three, so none is linked. Linking "
        "a straw does not take it off the tank count; that comes from the tank store's own movements.",
        "- A cow joined twice with no due date on the first (P 22, S 16R, U 14) has both joinings, the "
        "first left unknown and off Due. P 22's two joinings carry the same date, 25/12/25.",
        "- *As Calf Gestation* has no field of its own (the animal's gestation field is her own as a "
        "dam), so it is in the notes: 'Carried 288 days'.",
        "- 'Twin' in Comments became born as 2. The planned second bull is a back-up plan with no date.",
        "- Purpose became the class: Breeder → breeder, Breeder, Bull → bull, Heifer → yearling, "
        "Sales → harvest; any under nine months at 2 Oct 2026 is a calf.",
        "- No paddocks, weights after birth, treatments or sales in the sheet.",
    ]
    if warn:
        lines += ["", "## Rows flagged by the converter", ""] + [f"- {w}" for w in dict.fromkeys(warn)]
    notes_path = OUT.replace('40_rupari.sql', 'notes/03_rupari_import.md')
    with open(notes_path, 'w', newline='\n', encoding='utf-8') as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {OUT} and {notes_path}")
    print(f"  {len(cows)} head, {len(refs)} reference names, {n_join} joinings, {n_calv} calvings, "
          f"{n_plan} plans, {len(warn)} flagged")


if __name__ == '__main__':
    main()
