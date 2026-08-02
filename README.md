# Buloke Farm

Cattle records for 267 North Canal Rd, Trafalgar, Victoria. PIC 3BWWY089.

Replaces a 55-column spreadsheet. Three static HTML pages talking to a
Supabase Postgres database. No build step, no server, no framework —
the phone app is about 26 KB over the wire.

Live at **https://admin.bulokefarm.com.au**

---

## 1. The pages

| File | Path | Where it's used |
|---|---|---|
| `public/index.html` | `/` | Phone. Herd, paddock map, family tree, all recording. |
| `public/reports.html` | `/reports` | Laptop. LPA records, printable, with editing and change history. |
| `public/map.html` | `/map` | Laptop. Tracing paddock boundaries on satellite imagery. |

The phone app links to the other two under **Record → Manage → On a laptop**.

### What the app does

**Herd** — three views behind one toggle. *List* filtered by class,
*Paddocks* grouped by where stock are, *Family tree* showing descent.

**Map** — paddock boundaries as flat SVG. No tiles, no map library: the
expensive work happens once in the boundary editor, and the phone just
draws stored coordinates. Two panes on a wide screen, stacked on a
phone. Selecting a paddock gives head count, area, stocking rate, and
buttons to move stock in or feed out.

**Due** — expected calvings by season.

**Record** — feed out, move mob, weights, treatments, joinings,
calvings, sale/consignment. Plus Manage: feed store, bulk update, field
visibility.

---

## 2. Design decisions

These are the things to re-read before changing anything.

**Nothing is silently rewritten.** Treatments, feeding, consignments,
weights, calvings, joinings and animal records all have change-log
triggers capturing before, after, who and when. Corrections are normal;
invisible corrections turn a compliance record into an assertion.

**Derived values are never stored.** Age, growth rate, head counts,
stocking rate, slaughter-clear dates, feed remaining — all computed on
read. Roughly a third of the spreadsheet's columns were stored
calculations, and they had gone stale.

**Feeding targets a paddock, not animals.** You record that the back
gully got two rolls; who ate it comes from `paddock_stay`. One entry
instead of fourteen.

**Feed stock uses adjustments.** A recount or spoilage is its own row,
never an edit to the original quantity, so the balance stays
explainable: 40 in, 24 fed out, 4 written off.

**Paddocks are retired, not deleted.** Their boundary at the time is
kept, and lineage records what split into what. Grazing history from
five years ago still resolves.

**Descent runs through the dam.** Sires are mostly external AI bulls
that change each season; the cow family is what persists.

**An animal is on hand if its life state is `alive` or absent.** Sold
and died animals stay in the pedigree and the family tree but count
towards nothing.

**LPA drives the schema.** Treatments carry batch, expiry, dose,
withholding, ESI and operator because that's what Section 2 wants. The
operator fills itself from the login, which is the whole reason for
separate accounts. Consigning checks withholding periods and refuses if
anything is still inside one.

---

## 3. Data model

```
animal ──┬─ animal_status       dated life state + class transitions
         ├─ weight_event
         ├─ treatment_animal ── treatment      LPA section 2
         ├─ paddock_stay ────── paddock        where, and where it's been
         ├─ consignment_animal─ consignment    NVD, waybill, LPA 5A/5B
         ├─ joining ─────────── calving        outcomes incl. empty
         └─ expected_calving                   projected, not yet animals

feed_source ─┬─ feed_event ──── paddock        LPA 3C / 3D
             └─ feed_adjustment                recounts, spoilage

farm_user           roles: viewer / manager / owner
user_pref           per-user field visibility
record_change_log   append-only audit trail
```

`animal` also holds **reference** animals (`origin = 'reference'`) —
sires and dams that were never on the property. That keeps pedigree a
single self-join instead of nullable text columns.

### Key views

| View | For |
|---|---|
| `v_animal_current` | The herd, every column, with age, status, paddock, clearance |
| `v_paddock_current` | Paddocks with live head count and stocking rate |
| `v_treatment_report` | LPA section 2 shape |
| `v_feed_event` / `v_feed_store` | LPA 3C / 3D, with what's left in the shed |
| `v_consignment` | LPA 5A / 5B |
| `v_animal_clearance` | Withholding and export interval per animal |
| `v_joining_performance` | Conception rate by bull and season |
| `v_record_history` | Change log in plain language |

### Deliberately not used

**PostGIS.** Boundaries are GeoJSON in `jsonb`; the only geometry maths
needed is polygon area, which is a dozen lines. Adding the extension
would eat a chunk of a 500 MB free-tier database for nothing.

**A frontend framework.** Three files, no build, no `node_modules`.

---

## 4. Repository

```
public/                 served as-is by Cloudflare Pages
supabase/
  migrations/           schema, applied in filename order
  seed/                 data loads, run once, in numeric order
    notes/              flagged rows from each import
    tools/              the xlsx -> SQL converters
.github/workflows/      keepalive and backup
```

**Migrations define shape; seeds carry data.** Migrations run first on a
rebuild, so anything depending on imported records has to be a seed.
That's why the joining-outcome backfill is `seed/90_joining_backfill.sql`
and not part of the migration that adds the column.

### Migrations

| # | What |
|---|---|
| 01 | Core: animal, status, weights, treatments, joining, calving |
| 02 | Users, roles, attribution, real RLS policies |
| 03 | Paddocks, grazing stays |
| 04 | Paddock retirement, lineage, geometry history |
| 05 | Feed sources and feeding events |
| 06 | Change log and audit triggers |
| 07 | Feed store quantities |
| 08 | Feed stock adjustments |
| 09 | Consignments, NVD, withholding checks |
| 10 | Full animal view, preferences, bulk status |
| 11 | Joining outcomes and fertility views |
| 12 | Heartbeat table for the keepalive job |

### Seeds

| # | What |
|---|---|
| 10 | The 31 head from `Cattle Data.xlsx` |
| 20 | Autumn/winter 2026 drenches and grain |
| 30 | 50 historical animals, 29 consignments, back to 2011 |
| 90 | Joining outcome backfill — must run last |

---

## 5. Making changes

1. Write the SQL into a **new numbered file** in `supabase/migrations/`
2. Commit and push
3. Paste the same SQL into the Supabase **SQL Editor** and run it

The file is the record; running it is execution. If you paste SQL that
isn't in a file, the repo quietly stops being true and a rebuild won't
reproduce the database.

Every migration is written to be **safely re-runnable** — `if not
exists`, `or replace`, `drop policy if exists`. Keep it that way.

### Two rules learned the hard way

- **`create or replace view` can only append columns.** Adding one at
  the front, renaming, or reordering needs `drop view if exists` first.
  This cost two failed migrations.
- **Drop dependent views before touching a column they read.**

### Deploying

`git push` to `main`. Cloudflare Pages rebuilds in under a minute. There
is no build step — it serves `public/` as-is.

Pages settings: framework preset **None**, build command **empty**,
output directory **public**.

**Don't add a `_redirects` file mapping `/foo` to `/foo.html`.** Pages
already serves clean URLs and redirects the `.html` form, so the two
fight and you get a redirect loop. Name the file after the path you want.

---

## 6. Operations

### Infrastructure

| Thing | Where |
|---|---|
| Domain | VentraIP (`ns1-3.nameserver.net.au`), one CNAME: `admin` → `bulokefarm.pages.dev` |
| Main website | Squarespace, untouched — shares only the registrar |
| Hosting | Cloudflare Pages, project `bulokefarm` |
| Database | Supabase project `production`, region **Oceania (Sydney)** |
| Repo | `github.com/bulokefarm/bulokefarm` |

Sydney, not Singapore: the Vocus path from Trafalgar to `ap-southeast-1`
was dropping packets past Perth.

### Keys

The anon key is in the HTML and that is correct — it is designed to be
public, and row level security protects the data. Every table denies by
default, then grants read to active farm users, write to managers and
owners, delete to owners.

The **service_role** key bypasses RLS entirely. Never in this repo,
never in the HTML.

### GitHub secrets

| Secret | Notes |
|---|---|
| `SUPABASE_ANON_KEY` | Use the copy button — truncated pastes cause 401s |
| `SUPABASE_DB_URL` | **Session pooler**, port **5432** |

The database URL must be the session pooler
(`aws-0-ap-southeast-2.pooler.supabase.com`), username
`postgres.hgnzignikbpdbbyubahu`. The direct connection is IPv6-only and
unreachable from GitHub runners. Port 6543 is transaction mode and won't
work with `pg_dump`. Special characters in the password need URL
encoding — `/` becomes `%2F`.

### Backups

`Weekly backup` produces a dump as a GitHub artifact. **They expire
after 90 days** — a rolling window, not an archive. Download one every
few months and keep it somewhere you own.

### Keepalive

A free Supabase project pauses after a week without database activity.
`Keep database awake` queries the `heartbeat` table on weekdays. Delete
both workflows if the project moves to a paid plan.

If a request returns 404 shortly after creating a table, PostgREST's
schema cache is stale: `notify pgrst, 'reload schema';`

### Adding a user

1. Supabase → Authentication → Users → Add user, auto-confirm
2. ```sql
   update farm_user
      set display_name = 'Name', phone = '04xx xxx xxx',
          role = 'manager', active = true
    where id = (select id from auth.users where email = 'them@example.com');
   ```

Roles: `viewer` reads, `manager` records, `owner` also deletes. New
accounts land inactive and see nothing until switched on. `display_name`
and `phone` fill the LPA "treated by" field automatically.

**Don't disable the email provider** to stop signups — that turns off
sign-in too. The setting you want is "Allow new users to sign up".

---

## 7. Still to do

- **Five drenches have no operator name.** LPA requires it. Fix by
  clicking each row in `/reports`.
- **Two possible duplicate sires** — is `Davelle Cool Beau` the same
  animal as `Davelle Cool Beau N51`? `Quicksilver` and
  `Bre. Quicksilver (P)`? Their progeny stay split across two lines
  until this is settled.
- **2021 vaccination and 2022 drench** imported with dates only — no
  product, batch or withholding period.
- **`n/B/R` column** — meaning unknown. Values `R` and `Br`. Currently
  free text as `marking_code`.
- **Icons** — drop `icon-192.png` and `icon-512.png` into `public/` for
  a proper home-screen icon.

Flagged rows from both imports are in `supabase/seed/notes/`.
