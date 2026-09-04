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
| `public/map.html` | `/map` | Laptop. Tracing paddock boundaries on satellite imagery, and spraying. |

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

**Days on feed** — every herd row and animal card shows how long stock
have been on a ration, what it is, and the projected empty date; and for
90 days afterwards, how long the finished run lasted. Costs no extra
query: it rides on `v_animal_current`. Taking a mob off is
**Record → Manage → Feed store → the load → "the feeder ran dry"**, or
the *Fed until* field on the row in `/reports`.

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
gully got two rolls; who ate it comes from `paddock_stay`. The Irwins
grain runs are the exception — they came from a per-animal sheet and
name their animals directly, so both shapes have to be counted.

**Spraying is a record against the ground, not the stock.** Section 2 is
a chemical put into an animal; Section 3B is a chemical put onto a
paddock. They share nothing useful — 3B has no animals attached at the
time and its withholding period governs *grazing*, not slaughter — so
they are separate tables. A tank mix is one `spray_event` with a
`spray_product` row per product, each carrying its own batch number and
withholds, because that is how the labels read and how the mix clears.

**Three ways in, one record.** Spraying can be entered from **Record →
Spraying** on the phone, from a selected paddock on `/map`, or from
**+ Record spraying** on `/reports`. The map is where the job is
usually thought about, so it also hatches any paddock inside a grazing
withhold and labels it `NO GRAZE`. All three write the same
`spray_event` plus one `spray_product` per thing in the tank.

**Every spray names paddocks, plural.** A boom run crosses three
paddocks on one tank, one wind reading, one batch number; recorded as
three events that is three chances to type the batch differently.
`spray_paddock` joins them, same shape as `treatment_animal`. Area and
`location_note` sit on the join, because 8 ha of one paddock and 0.3 ha
along the fence of another is still one run. A paddock cannot be
deleted while it holds spray history.

Migration 40 let free text stand in for the paddock so a laneway had
somewhere to go; 41 took it back, because the free-text case was
invisible to `paddock_graze_block()` — the records least likely to be
remembered were the ones the guard could never catch. A laneway worth
spraying is a laneway worth a paddock row.

**`record_spray()` writes a pass in one transaction.** A join table
cannot enforce "at least one" the way NOT NULL could, and the browser
sends one statement at a time — so pass, paddocks and products could
half-save, and being told it failed after the pass was already on file
gets the same spray entered twice. The function refuses an empty
paddock list, and counts the rows that actually landed rather than
trusting the length of what was sent: an id that is not a paddock joins
to nothing and would otherwise leave a pass covering nowhere.

**No safe-to-graze date is stored.** It is `applied_on + withhold`, and
the binding one is the latest across the mix. `v_paddock_withhold` does
that arithmetic and `move_animals` refuses a paddock still inside it.
A withhold that is null means *unknown*, never zero: the paddock is
held for 60 days and the report names the gap rather than clearing it
by guesswork. Overriding the refusal is allowed and is written onto the
`paddock_stay` reason, so a deliberate call stays visible.

**A run is not a drop.** Rolling out a bale feeds them that day. A self
feeder they stay on for weeks. Both are LPA 3C records and both count
against the store, but only a run (`feed_event.is_run`) accrues days on
feed. Without the distinction, every cow in a paddock that once got a
bale reads as on a finishing ration, climbing daily, forever.

**An empty silo is not a mob off feed.** `feed_source.exhausted_on`
means there is nothing left to feed out. `feed_event.ended_on` means the
animals came off. For a self feeder those are weeks apart, and only the
second stops the clock. Nothing infers one from the other: the estimate
says when it is likely, the yard says when it is true.

**PIC is ownership, not location.** `animal.property_id` is whose the
animal is — for NVD, NLIS and tax. `paddock.property_id` is which land.
With two PICs on one property those are different things, and the
paddock's PIC must never be used to filter a herd.

**A calving puts the calf on the ground.** Recording a calving used to
write one row against the cow, and the calf was a line in her history
with nothing in the herd to tag, sex or drench. `record_calving()`
writes the calving, the calf, its status and its paddock in one
transaction, the same shape as `record_spray()`. The calf carries this
year's letter and no number — `stock_code` stays null until a tag is
decided in the yard, so it shows as `X ?` under the year's drop and
twins don't collide on the unique index. The open joining nearest the
date names the sire and is resolved by it. When the tag is written
later, `animal_code_parts` fills the letter and number in from it.
`year_letter()` takes the letter the herd already uses for that year,
falling back to the NLIS cycle (no I or O; 2005 was A, so 2026 is X);
sheep get the colour letter instead, see below.
A row on **Due** opens the cow's card, so the calving is two taps from
the list of who is due.

**A lamb is recorded against the paddock, not the ewe.** Sheep run as
mobs: the rams go out to a paddock of ewes, and at lambing what is
seen is a lamb in the back gully, not which ewe it came from.
`record_drop()` takes what is actually known — paddock, day, how many,
the ram that was out with that mob, sex if checked — and puts each
lamb in the herd the same way as a calf: this year's letter, no
number, classed lamb, in that paddock, dam null. The form suggests the
ram from the natural joinings that name the paddock and are due about
then. No calving row is written and no ewe's expectation is resolved,
because guessing a ewe would say something the record doesn't know.
Numbers go on at marking through **Record → Manage → Tag the drop**,
one row per untagged animal by paddock.

**A mob comes off Due as a group.** A mob joining writes one joining
per ewe and one expectation per ewe, and since lambs are recorded by
paddock none of those rows ever resolves on its own. When lambing is
over, the mob's heading on **Due** offers *Lambing over*:
`close_expectations()` marks every joining behind the mob with the
outcome `closed` — season over, result not recorded per dam — with a
note, and `refresh_expectation()` drops the expectations as it always
has when no live joining remains. No ewe is called lambed or empty;
the joining's change log keeps the before and after; a closed joining
sits with the untested ones in the conception-rate views rather than
counting as a failure. An expectation with no joining behind it is
refused by name, not deleted. A ewe you do know about gets her lambing
recorded, or her joining marked empty, before the mob is closed.

**Sheep run a different alphabet.** Cattle stock codes carry the NLIS
year letter — X for 2026 — and the app colours them from a palette of
its own. Sheep tags are coloured on the NLIS eight-year cycle and the
code starts with the colour: B black 2024, W white 2025, O orange
2026, G light green 2027, P purple 2028, Y yellow 2029, R red 2030,
S sky blue 2031, then round again. `year_letter(date, species)` hands
out both. For cattle the herd is the record — the letter tagged cattle
born that year already carry wins over the arithmetic; untagged
placeholders don't vote, since they are this function's own output.
For sheep the cycle is the rule as stated and nothing votes. The tag
block for a sheep is drawn in the colour its letter names, so it is
the colour in the ear; the card names the colour and the drop. Light
tags get dark ink.

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

spray_event ─┬─ spray_product                  LPA 3B, tank mix = many products
             └─ spray_paddock ── paddock       one pass, many paddocks

feed_source ─┬─ feed_event ──┬─ paddock         LPA 3C / 3D
             │               ├─ feed_event_animal
             │               └─ feed_event_ref   tags as written on paper
             └─ feed_adjustment                  recounts, spoilage

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
| `v_spray_report` | LPA 3B, one row per product with derived graze and cut dates |
| `v_paddock_withhold` | Paddocks stock should not be grazing yet. Empty is normal |
| `v_feed_event` / `v_feed_store` | LPA 3C / 3D, with what's left in the shed |
| `v_feed_cover` | Who a feeding event covers, by paddock or by name |
| `v_feed_load` | Per load: head, intake rate, projected empty date |
| `v_animal_feed` / `v_animal_feed_last` | The run an animal is on, and the one it came off |
| `v_feed_unmapped` | Animals named on the paper feed record but not on file |
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

**UTC.** The session timezone is `Australia/Melbourne` (migration 39),
because `current_date` on UTC is yesterday here until 10am AEST. In the
browser, **never `toISOString()` for a calendar date** — it returns the
UTC day, so anything recorded before 10am was dated a day early on the
LPA record. Build dates from local parts (`today()` in `index.html`,
`localDay()` in `reports.html`, `localToday()` in `map.html`), and do
date arithmetic anchored at UTC midnight with `setUTCDate` so no zone
enters into it at all. `fmt()` already parses `d+"T00:00:00"` as local
and is correct — that was the model to follow.

**A CDN at runtime.** `vendor/supabase.js` must be a real self-contained
bundle, ~210 KB with no `import` statements in it. What esm.sh serves at
`/@supabase/supabase-js@2` is a four-line *stub* whose imports are
absolute paths relative to esm.sh; saved locally they resolve against
our own origin, Pages answers with its 404 HTML, and the module fails on
MIME type. The `try/catch` in each page then falls through to esm.sh, so
the app still works and the vendored copy silently does nothing. That
shipped and ran for months. Check with
`grep -n 'import "' public/vendor/supabase.js` — it must print nothing.
Build instructions are in `public/vendor/readme.md`.

---

## 4. Repository

```
public/                 served as-is by Cloudflare Pages
  vendor/supabase.js    the client, self-hosted, not a CDN (see its readme)
  _headers              cache and security headers, per clean URL
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
| 34 | Days on feed on the herd view; store balance from the written amounts |
| 35 | Feeder dry ≠ silo empty. Intake rate, projected empty date, `feed_run_end()` |
| 36 | The two Irwins loads rebuilt; `feed_event_ref` for tags not yet on file |
| 37 | A run they stay on vs a one-off drop (`is_run`) |
| 38 | The run they just came off, kept alongside the one they are on |
| 39 | Melbourne time, not UTC. `farm_today()`, and the due dates it exposed |
| 40–42 | Spraying: LPA 3B, `record_spray()`, many paddocks per pass, grazing withholds on `move_animals` |
| 43 | A calving creates the calf: `record_calving()`, `year_letter()`, tag parts filled from `stock_code` |
| 44 | A lamb seen in a paddock, ewe not known: `record_drop()` |
| 45 | Lambing over for a mob: joining outcome `closed`, `close_expectations()`, closed is untested in the rate views |
| 46 | A sheep's letter is its tag colour: `year_letter(date, species)`, the callers pass species, today's `X ?` lambs repaired to `O ?` |

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
exists`, `or replace`, `drop policy if exists`. Keep it that way, and
**prove it by actually re-running them**, in order, three times, against
a scratch database with realistic data. A single forward pass hides a
whole class of bug: migrations 34–38 each applied perfectly the first
time and, on the second, variously aborted, deleted a delivery record
that had just been created, and silently took an entire mob off feed.
None of it was visible until the second run.

```bash
# a scratch Postgres is enough; no Supabase needed for the shape
initdb -D /tmp/pg/data -A trust && pg_ctl -D /tmp/pg/data -o "-p 5433" start
for pass in 1 2 3; do
  for f in supabase/migrations/*.sql; do
    psql -p 5433 -d scratch -v ON_ERROR_STOP=1 -f "$f" || echo "FAIL $f pass $pass"
  done
done
```

### Rules learned the hard way

- **Check which definition is current.** Views get redefined and the
  last one wins. `grep -rn "view v_name" supabase/migrations/` before
  touching one, or you will rebuild it from a version that has since
  gained columns and silently drop them.
- **`create or replace view` can only append columns.** Adding one at
  the front, renaming, or reordering needs `drop view if exists` first.
- **Appending to a view breaks every earlier migration that built it.**
  Once migration 38 adds a column to `v_animal_current`, re-running 34
  or 35 tries to replace it with fewer columns and aborts with *cannot
  drop columns from view*. Every migration that appends to a view a
  later one also appends to needs a guard that steps aside:

  ```sql
  do $guard$
  begin
    if not exists (select 1 from information_schema.columns
                    where table_name = 'v_animal_current'
                      and column_name = 'off_feed_on') then
      execute $v$ create or replace view v_animal_current ... $v$;
    end if;
  end $guard$;
  ```

  Guarded so far: `v_animal_current` and `v_animal_feed` (34),
  `v_feed_load` and `v_animal_current` (35). The nested `$guard$` /
  `$v$` quoting is required — plain `$$` collides with the body.
- **A backfill is a one-time statement with a permanent trigger.** A
  repair `update` at the end of a migration re-fires on every later run,
  against data a subsequent migration has since changed its mind about.
  Migration 34 closed feeding runs when the store emptied; 35 overturned
  that rule, but 34's backfill kept enforcing it on every re-run, zeroing
  days-on-feed for the whole mob. Guard backfills on whether the later
  migration exists, not just on whether the rows look untouched.
- **Key an idempotent update on something stable.** "Update any row that
  isn't already correct" matches the row a previous run of the same
  migration just inserted. Migration 36 keyed the June feed source that
  way and, on the second run, rewrote the March delivery into a duplicate
  June one. Key on the relationship — the event that points at it —
  rather than on the values being set.
- **An insert matching zero rows is not an error.** `insert ... select
  ... from animal where stock_code = any(array[...])` silently writes
  nothing if none of the tags exist. That is how 3.95 tonne of grain
  never reached Section 3C: seed 20 referenced animals that seed 30
  creates. Order seeds so references exist first, or check the row count.
- **Drop dependent views before touching a column they read**, and
  recreate them explicitly. `cascade` drops them silently and leaves
  them gone. Current chains: `v_animal_current` ← `v_animal_clearance`;
  `v_cryo_location` ← `v_ai_semen`, `v_embryo`; `v_stock_year` and
  `v_stock_year_class` ← `v_stock_year_animal` ← `v_stock_entry`,
  `v_stock_exit`.
- **Adding an argument to a function creates a second function.**
  `create or replace` only replaces a matching argument list, so the old
  form survives and a call with the original arity then matches both —
  Postgres refuses it as ambiguous rather than choosing. `drop function`
  with the full old signature first. Migration 40 does this to
  `move_animals`.
- **`alter type ... add value` cannot be used in the transaction that
  added it.** The migration adding an enum value and the load using it
  are two separate runs. The SQL editor runs a paste as one
  transaction, so a view in the same file that names the new value as
  a literal fails too — migration 45 compares `outcome::text` for that
  reason. A plpgsql body may name it; that is not checked until it runs.
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
- **Single-letter globals get shadowed.** `viewDetail` destructured its
  queries as `const [w, t, c, sh] = await Promise.all(...)`, shadowing
  the module-level vocabulary helper `w(key, species)` for the whole
  function. Every female's detail page threw *w is not a function*, and
  because it was an `async` view called from `render`, it surfaced as an
  unhandled rejection with a blank screen rather than an obvious error.
  `node --check` will not catch this; shadowing is legal JavaScript.

### Deploying

`git push` to `main`. Cloudflare Pages rebuilds in under a minute. There
is no build step — it serves `public/` as-is.

Pages settings: framework preset **None**, build command **empty**,
output directory **public**.

**`_headers` must name the clean URLs.** Pages serves `/` and `/reports`,
not `/index.html`, so a `/*.html` rule matches the filename nobody
requests and applies to nothing — `X-Frame-Options` was missing from
every page for months without a symptom. Add a block per page path.
Verify with `curl -sI https://admin.bulokefarm.com.au/`, which is also
the quickest confirmation a deploy has actually landed.

**Never add `_redirects`** rewriting `/foo` to `/foo.html`. Pages already
serves clean URLs and the rule causes a redirect loop.

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
database doesn't hold — `select * from v_cryo_unmapped` — and six lines
of the Irwins feed record name stock that isn't on file:
**V 06, V 10, V 11, V 17, W 05** — `select * from v_feed_unmapped`.
Afterwards, re-run the update in migration 33 and
`select feed_resolve_refs();`. Both numbers should drop hard.

Head counts on `v_feed_load` already include the unresolved tags, so the
projected empty dates are right today — the paper says six head ate the
June load and six is what the tonnage divides by. Counting only animals
on file read 148 days instead of 74.

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

**Seed order.** `30_historical.sql` creates V 23 and V 25, but
`20_treatments_2026.sql` attaches the 17 March grain feeding to them and
runs first, so it matched nothing and the load vanished. Migration 36
rebuilds it, but a clean rebuild would lose it again. Renumber the
historical seed ahead of the treatments, or make the treatment inserts
report a zero row count instead of passing silently.

**Due dates that may be a day early.** The browser computed `due_on` by
mixing a UTC anchor with local day arithmetic, so a joining and a due
date on opposite sides of a daylight-saving change land a day short —
the ordinary June-joined, March-due pattern. Fixed going forward in
migration 39; the stored values are listed by
`select * from v_due_date_check`. A `drift` of exactly 1 is the bug,
anything else was a deliberate adjustment, so they are not rewritten
automatically. The one-line accept is in the migration's comments.

**Smaller things.** The masthead head count ignores the species scope.
`n/B/R` (`marking_code`) meaning still unknown. `TOL 20-P1065`'s EID is
the placeholder `3SBES046ASR06xxx`.

Flagged rows from every import are in `supabase/seed/notes/`.
