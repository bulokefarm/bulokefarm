# Buloke Farm

Livestock records for 267 North Canal Rd, Trafalgar, Victoria.
PIC 3BWWY089.

Cattle and sheep on one property, with a second PIC to come. Replaces a
55-column spreadsheet and several others besides. Four static HTML pages
talking to a Supabase Postgres database. No build step, no server, no
framework — the phone app is about 41 KB over the wire.

Live at **https://admin.bulokefarm.com.au**

---

## 1. The pages

| File | Path | Where it's used |
|---|---|---|
| `public/index.html` | `/` | Phone. Herd, paddock map, family tree, tank store, all recording. |
| `public/reports.html` | `/reports` | Laptop. LPA records, shed work, joining register. Printable, editable, with change history. |
| `public/stock.html` | `/stock` | Laptop. Livestock trading account by financial year, for tax. |
| `public/map.html` | `/map` | Laptop. Tracing paddock boundaries on satellite imagery. |

The phone app links to the others under **Record → Manage → On a
laptop**. `public/nav.js` is the shared menu.

### What the app does

**Herd** — three views behind one toggle. *List* filtered by class,
*Paddocks* grouped by where stock are, *Family tree* showing descent
down either the dam or the sire line.

**Map** — paddock boundaries as flat SVG. No tiles, no map library: the
expensive work happens once in the boundary editor, and the phone just
draws stored coordinates.

**Due** — expected calvings and lambings by season, derived from
joinings.

**Record** — feed out, move mob, weights, treatments, joinings,
calvings, shed work, sale/consignment. Plus the flasks (tank store and
straw movements) and Manage (feed store, bulk update, field visibility).

**Stock account** — opening, purchases, natural increase, sales, deaths,
rations, closing. One schedule per species per financial year, with the
animals behind every figure.

---

## 2. Design decisions

These are the things to re-read before changing anything.

**Nothing is silently rewritten.** Treatments, feeding, consignments,
weights, calvings, joinings, shearing, straw movements and animal
records all have change-log triggers capturing before, after, who and
when. Corrections are normal; invisible corrections turn a compliance
record into an assertion.

**Derived values are never stored.** Age, growth rate, head counts,
stocking rate, slaughter-clear dates, feed remaining, straws on hand,
the whole trading account — all computed on read. Roughly a third of the
spreadsheet's columns were stored calculations, and they had gone stale.

**A count is the sum of its movements.** Feed stock and straws both work
this way: a delivery, a use, a discard, a recount are each a row, and
the number on screen is their total. A counter that can disagree with
its own working is worse than no counter.

**Reports show their working.** The trading account is counted off a
per-animal view, so opening a year lists the animals behind every
figure. It is allowed not to reconcile — a mismatch means a status
history that can't be true, and June is when you want to hear about it.

**Species is a scope, not a filter.** A ewe is not a breeder cow and a
lamb is not a calf, so the words on the buttons depend on which mob you
are looking at. Set once, it follows through the herd list, every record
form, Due and the reports.

**The register keeps what was written.** Straw movements name the cow as
she was written on the sheet — `SD U 08`, `Tonnie T14` — alongside a
nullable link to an animal. The text is the record; the link is an
improvement. `cryo_ref_code()` resolves what it can and is re-run
whenever a herd is imported.

**Feeding targets a paddock, not animals.** You record that the back
gully got two rolls; who ate it comes from `paddock_stay`.

**PIC is ownership, not location.** `animal.property_id` is whose the
animal is — for NVD, NLIS and tax. `paddock.property_id` is which land.
With two PICs on one property those are different things, and the
paddock's PIC must never be used to filter a herd.

**Reference animals.** `animal` also holds sires and dams that were
never on the property (`origin = 'reference'`). Pedigree stays a single
self-join instead of nullable text columns.

---

## 3. Data model

```
animal ──┬─ animal_status       dated life state + class transitions
         ├─ weight_event
         ├─ treatment_animal ── treatment      LPA section 2
         ├─ shearing_animal ─── shearing       shearing, crutching, marking
         ├─ paddock_stay ────── paddock        where, and where it's been
         ├─ consignment_animal─ consignment    NVD, waybill, LPA 5A/5B
         ├─ joining ─────────── calving        outcomes incl. empty
         │      └─ ai_semen                    which straw, for an AI
         └─ expected_calving                   derived from joining, by trigger

ai_semen ─┬─ cryo_txn ───────── animal         straw ledger, female as written
embryo  ──┘                                    two tanks, six locations each

feed_source ─┬─ feed_event ──── paddock        LPA 3C / 3D
             └─ feed_adjustment                recounts, spoilage

property            PIC. is_primary drives the page letterheads
farm_user           roles: viewer / manager / owner
user_pref           per-user field visibility
record_change_log   append-only audit trail
```

`animal.species` is `cattle` or `sheep`. Stock codes are unique **per
species** — `R 97` is a cow and also a ewe, and both are right.

### Key views

| View | For |
|---|---|
| `v_animal_current` | The herd, every column, with age, status, paddock, clearance |
| `v_paddock_current` | Paddocks with live head count and stocking rate |
| `v_treatment_report` | LPA section 2, with which PICs and species were on the run |
| `v_feed_event` / `v_feed_store` | LPA 3C / 3D, with what's left in the shed |
| `v_consignment` | LPA 5A / 5B |
| `v_shearing` | Shed work with head count and tags |
| `v_animal_clearance` | Withholding and export interval per animal |
| `v_joining_result` | The joining register — method, sire or straw, result |
| `v_joining_performance` | Conception rate by bull and season |
| `v_stock_year_animal` | One row per animal per bucket per year — the account's working |
| `v_stock_year` / `v_stock_year_class` | The trading account, counted off the above |
| `v_stock_entry` / `v_stock_exit` | When stock came on and left, sale/death/ration inferred |
| `v_ai_semen` / `v_embryo` | Lots with what's on hand and the shelf label |
| `v_cryo_location` | What is in each tank and canister |
| `v_cryo_unmapped` | Females named on the register but not on file, and why |
| `v_record_history` | Change log in plain language |

### Deliberately not used

**PostGIS.** Boundaries are GeoJSON in `jsonb`; the only geometry maths
needed is polygon area, which is a dozen lines.

**A frontend framework.** Four files, no build, no `node_modules`.

---

## 4. Repository

```
public/                 served as-is by Cloudflare Pages
  vendor/supabase.js    the client, self-hosted, not a CDN
supabase/
  migrations/           schema, applied in filename order
  seed/                 data loads, run once, in numeric order
    notes/              flagged rows from each import
    tools/              the xlsx -> SQL converters
  schema.sql            snapshot, written back by the backup workflow
.github/workflows/      keepalive and backup
```

**Migrations define shape; seeds carry data.** Migrations run first on a
rebuild, so anything depending on imported records has to be a seed.

### Migrations

| # | What |
|---|---|
| 01–12 | Core schema, users and RLS, paddocks, feed, change log, consignments, joinings, keepalive |
| 13 | Joining method: AI or bull out. `ai_semen`, per-dam gestation |
| 14 | Livestock trading account by financial year |
| 15 | Exit date on the herd view |
| 16 | Leaving the herd closes the paddock stay |
| 17 | The animals behind each trading-account figure |
| 18 | PIC groundwork: not-null, `is_primary`, PIC through the report views |
| 19 | Sheep: `species`, enum values, `shearing` |
| 20 | Stock codes unique per species |
| 21 | Species into the views the app reads |
| 22 | Trading account splits by species |
| 23 | Species on the reports |
| 24 | Sire identified by tag, not only by name |
| 25–30 | Expected calvings derived from joinings, and the repairs that took |
| 31 | The cryo store: tanks, locations, embryos, ledger |
| 32 | Straw markings split into marker, straw, size, goblet |
| 33 | Resolving the females named on the register |

### Seeds

| # | What |
|---|---|
| 10 | The 31 head from `Cattle Data.xlsx` |
| 20 | Autumn/winter 2026 drenches and grain |
| 30 | 50 historical animals, 29 consignments, back to 2011 |
| 40 | 90 sheep, joinings, drenches, shed work, sales |
| 50 | 50 semen lots, 20 embryo lots, 372 movements back to 2008 |
| 90 | Joining outcome backfill — must run last |

---

## 5. Making changes

1. Write the SQL into a **new numbered file** in `supabase/migrations/`
2. Commit and push
3. Paste the same SQL into the Supabase **SQL Editor** and run it

The file is the record; running it is execution. If you paste SQL that
isn't in a file, the repo quietly stops being true and a rebuild won't
reproduce the database. `supabase/schema.sql` is the check — the backup
job rewrites it weekly, so drift surfaces as a commit.

Every migration is written to be **safely re-runnable** — `if not
exists`, `or replace`, `drop policy if exists`. Keep it that way.

### Rules learned the hard way

- **Check which definition is current.** Views get redefined and the
  last one wins. `grep -rn "view v_name" supabase/migrations/` before
  touching one, or you will rebuild it from a version that has since
  gained columns and silently drop them.
- **`create or replace view` can only append columns.** Adding one at
  the front, renaming, or reordering needs `drop view if exists` first.
- **Drop dependent views before touching a column they read**, and
  recreate them explicitly. `cascade` drops them silently and leaves
  them gone. Current chains: `v_animal_current` ← `v_animal_clearance`;
  `v_cryo_location` ← `v_ai_semen`, `v_embryo`; `v_stock_year` and
  `v_stock_year_class` ← `v_stock_year_animal` ← `v_stock_entry`,
  `v_stock_exit`.
- **`alter type ... add value` cannot be used in the transaction that
  added it.** The migration adding an enum value and the load using it
  are two separate runs.
- **`on conflict` cannot infer a partial unique index** unless the
  statement repeats the predicate. Usually the predicate was
  unnecessary — nulls are already distinct.
- **`lpad` truncates.** `lpad('122', 2, '0')` is `'12'`.
- **Untyped literals in a `union` resolve against each other** before
  the insert target is considered. Cast enum values on every branch.
- **A repair that deletes rows must write the replacements** in the same
  migration. A trigger only fires on a write, so deleting and expecting
  it to rebuild leaves nothing behind.
- **Match on more than a name.** One bull can hold three blocks in a
  register and one cow two joinings in a season; taking the first match
  loses the others.

### Deploying

`git push` to `main`. Cloudflare Pages rebuilds in under a minute. There
is no build step — it serves `public/` as-is.

Pages settings: framework preset **None**, build command **empty**,
output directory **public**.

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

The Supabase client is self-hosted at `public/vendor/supabase.js`, with
esm.sh only as a fallback. Refresh it with:

```
curl -L "https://esm.sh/@supabase/supabase-js@2.111.0?bundle&target=es2020" \
  -o public/vendor/supabase.js
```

`?bundle` matters. Without it the file is a stub re-importing paths that
404 on our origin, the fallback quietly takes over, and every cold start
goes back to fetching from a CDN.

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

The same job writes `supabase/schema.sql` back to the repo whenever the
live schema differs from the last snapshot, so unrecorded SQL-editor
changes turn up as a Monday-morning commit.

### Keepalive

A free Supabase project pauses after a week without database activity.
`Keep database awake` queries the `heartbeat` table on weekdays.

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

**Rupari's herd.** The second PIC exists in the schema but the animals
aren't in. Until they are, 212 straw and embryo movements name a cow the
database doesn't hold — `select * from v_cryo_unmapped`. Re-run the
update in migration 33 afterwards and that number should drop hard.

**The valuation side of the trading account.** Head counts are done and
reconcile. Values need a purchase price on `animal`, a per-year
per-class valuation election, and a natural-increase figure. The
election is the accountant's call, and there are now two species of it.

**Rations are inferred**, not recorded: slaughtered with no consignment
to a saleyard, abattoir or agent. Near-deterministic given how
`consign_animals` works, but a fourth life state would settle it.

**LPA gaps.** Five cattle drenches have no operator name. The 2021
vaccination and 2022 drench have dates only. Both sheep drenches have no
product or batch. All fixable by clicking the row in `/reports`.

**Two possible duplicate sires** — is `Davelle Cool Beau` the same
animal as `Davelle Cool Beau N51`? `Quicksilver` and
`Bre. Quicksilver (P)`? Their progeny stay split across two lines until
this is settled.

**Seed data that would come back on a rebuild.** `10_herd.sql` still
contains eight joinings with `due_on = 1900-10-11` and no service date.
Migration 27 clears them and constrains against a repeat, but the seed
carries them.

**Smaller things.** The masthead head count ignores the species scope.
`n/B/R` (`marking_code`) meaning still unknown. `TOL 20-P1065`'s EID is
the placeholder `3SBES046ASR06xxx`.

Flagged rows from every import are in `supabase/seed/notes/`.
