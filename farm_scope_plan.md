# Farm scope — migration plan

**Status, 2026-09-28 late:** written and tested locally, not applied to
production. Migrations 52–55 exist in `supabase/migrations/`, the pages
are farm-aware, the seeds are under `seed/buloke/`. On a local copy of
yesterday's production dump, 53–55 applied three times over, every
view returned the same rows for Richard before and after, and a second
farm (Toland, test login) saw nothing of Buloke and could not link to
it. The four pages were then run against the local API with a
throwaway owner login: sign-in, herd, the new people screen with
add-by-email, reports, stock account, map. One catch found that way
and fixed: a local CLI stack grants the API nothing by default where
the cloud project grants everything, so 53 now grants its new
objects explicitly. All of it is commit cbdf263 on branch
`farm-scope`. What remains is on production and is Richard's to do:
§12. Two things seen in passing and not fixed: seeds 10 and 20 stop
part-way on a fresh database (a joining check constraint from 27 and
`feeding_period`, dropped by 05), so a rebuild from seeds has been
incomplete for some time and should be repaired in its own change.

A plan, not a migration. Nothing here has been applied. Written
2026-09-28 against migrations 01–49, revised the same day against
01–51 after the join-planning work landed (commits a96377b through
f1da793: migration 49 `planned_joining`, 50 and 51 data-only). The
next free migration number after 52 (the `ensure_rls` capture, below)
is **53**, so the three migrations here are 53, 54 and 55. Check `git status` is clean and no other session
is mid-migration before starting, because this touches every table.

## 0. What we are building

Today the database holds one farm. Every one of the 57 RLS policies
asks one question — *is this user an active viewer, manager or owner?*
— and answers it from a single global role on `farm_user`. Anyone who
is active sees everything. That is correct for one farm and wrong for
two.

The change adds a **farm** as the layer above the PIC:

```
farm            who runs the app on this land: name, address, logo, hostname
 └─ property    a PIC. Richard's, Dad's, and the vendor PICs in the address book
     └─ paddock which land (attached to the primary PIC, as now)
 └─ animal      whose (animal.property_id → a PIC of this farm), as now
```

**The two-PIC arrangement is untouched.** Richard and Dad remain two
`property` rows with `is_own = true` under the one farm, one of them
`is_primary`, the herd running as one mob across every paddock, and
`animal.property_id` still saying whose each animal is for NVD, NLIS
and tax. The "PIC is ownership, not location" rule from migration 18
stands. The per-PIC trading account split that migration 18 deferred
is still deferred and is orthogonal to this work: it will filter by
`animal.property_id` *within* a farm.

A second farmer is a second `farm` row with their own PIC(s), address,
logo and hostname, and a membership row for each of their users. They
share the database, the schema, the migrations and the Pages
deployment. They never see a Buloke row.

**Why one database and not two projects** is in the conversation that
produced this file; briefly: one migration run per change instead of
N, one backup, one keepalive, one dashboard, flat cost, and the
refactor is cheapest now while there is one farm's data to backfill.

## 1. Principles

1. **The pages send no `farm_id`.** Root tables default it from
   `current_farm()`; child tables derive it from their parent by
   trigger. A page that forgets is still correct, and a page that lies
   is refused by the policy's `with check`.
2. **Views do not change.** Every view is `security_invoker = on`, so
   once the base-table policies are farm-scoped the views are too.
   `v_stock_year_animal`'s `cross join animal`, `year_letter()`'s herd
   vote, `v_cryo_location` — all scoped for free.
3. **Role helpers keep their signatures.** `my_role()`, `can_read()`,
   `can_write()` go on working; only where the role comes *from*
   changes. So the policy rewrite is one added predicate, not a
   redesign.
4. **Security definer code never trusts the session for `farm_id`.**
   Trigger functions that run as owner copy `farm_id` from the row
   that fired them. `current_farm()` is for the signed-in path only.
5. **Groundwork first, cutover last, each re-runnable.** Three
   migrations. After 53 and 54 the app behaves exactly as today. 55 is
   the switch. Same shape as 18 → the eventual PIC split.

## 2. Prerequisites — do these first

- **Capture `rls_auto_enable()`.** Done: migration 52 creates the
  function and the `ensure_rls` event trigger if they are missing,
  and leaves them alone if present. Both are owned by `postgres` on
  the live database. The trigger has never had anything to do here,
  because every migration enables RLS by hand.
- **Get a baseline `supabase/schema.sql`.** The backup workflow had
  run every Sunday since August and succeeded, yet the file never
  appeared: its "did it move" test was `git diff --quiet`, which is
  silent about an untracked file. Fixed in commit 70f2a5d (stage,
  then compare the index). The fixed workflow still needs one run
  before 55: a repository admin presses *Run workflow* on
  `Weekly backup`, or it runs itself on Sunday 2026-10-04. The
  `roberts-r` GitHub login used from this machine is not an admin of
  `bulokefarm/bulokefarm`, so it cannot dispatch it.
- **A full `pg_dump` immediately before 55.** The backup job's dump is
  up to a week old.
- **49, 50 and 51 are committed** (done; 50 and 51 are data
  migrations and add no tables, policies or functions). Branch
  (`supabase branch` or a scratch project) and run 01–55 three times
  on a copy of production data before touching the real one. The
  seeds' `90_joining_backfill.sql` predates 50 and 51; a rebuild must
  run it before them, as the filename order already does.

## 3. Migration 53 — the farm, and who belongs to it

Additive. Nothing reads any of this yet.

```sql
create table farm (
  id           uuid primary key default gen_random_uuid(),
  slug         text unique not null,           -- 'buloke'. url-safe, never changes
  name         text not null,                  -- 'Buloke Farm'. app chrome, nav, login
  address      text,
  hostname     text unique,                    -- 'admin.bulokefarm.com.au'
  logo_url     text,                           -- storage url; null → /mark.png
  timezone     text not null default 'Australia/Melbourne',
  created_at   timestamptz not null default now()
);

-- One row per user per farm. Role and active move here from farm_user.
create table farm_member (
  farm_id      uuid not null references farm(id) on delete cascade,
  user_id      uuid not null references farm_user(id) on delete cascade,
  role         farm_role_t not null default 'viewer',
  active       boolean not null default false,
  created_at   timestamptz not null default now(),
  primary key (farm_id, user_id)
);

-- Which farm this login is working in. Most users have exactly one
-- membership and this is redundant; it exists so a second membership
-- is a column update, not a redesign.
alter table farm_user add column current_farm_id uuid references farm(id);
```

Backfill:

```sql
insert into farm (slug, name, address, hostname)
values ('buloke', 'Buloke Farm', '267 North Canal Rd, Trafalgar VIC 3824',
        'admin.bulokefarm.com.au')
on conflict (slug) do nothing;

insert into farm_member (farm_id, user_id, role, active)
select f.id, u.id, u.role, u.active from farm_user u, farm f where f.slug = 'buloke'
on conflict do nothing;

update farm_user set current_farm_id = (select id from farm where slug = 'buloke')
 where current_farm_id is null;
```

Helpers:

```sql
-- The farm this session works in. Security definer because farm_member
-- has RLS of its own and this is what the policies are built on.
create or replace function current_farm() returns uuid
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select u.current_farm_id from farm_user u
      join farm_member m on m.farm_id = u.current_farm_id and m.user_id = u.id and m.active
     where u.id = auth.uid()),
    (select m.farm_id from farm_member m
     where m.user_id = auth.uid() and m.active
     order by created_at limit 1))
$$;
revoke execute on function current_farm() from public, anon;
grant  execute on function current_farm() to authenticated;

-- Same name, same callers, new source of truth.
create or replace function my_role() returns farm_role_t
language sql stable security definer set search_path = public as $$
  select role from farm_member
   where user_id = auth.uid() and farm_id = current_farm() and active
$$;
```

`can_read()` and `can_write()` are unchanged. `handle_new_user()` keeps
creating the profile row but no longer sets a role or active flag
there; a new sign-up belongs to no farm until an owner adds a
`farm_member` row. The `role` and `active` columns on `farm_user` stay
until 55, then are dropped.

Policies on the new tables:

- `farm`: select where `id = current_farm()`; update where owner; no
  insert or delete from the API (farms are created in SQL, by you).
- `farm_member`: select where `farm_id = current_farm()`; all where
  `farm_id = current_farm() and my_role() = 'owner'`.
- `farm_user`: read narrows from "everyone" to "members of my current
  farm": `exists (select 1 from farm_member m where m.user_id =
  farm_user.id and m.farm_id = current_farm())`, plus your own row.
  `v_treatment_lpa` joins `farm_user` for the operator's name; still
  resolves, because the operator is a co-member.

A narrow anon-readable view for the login screen, so the page can show
the farm's name and logo before anyone has signed in:

```sql
create view v_farm_public with (security_invoker = off) as
select slug, name, logo_url, hostname from farm;
grant select on v_farm_public to anon, authenticated;
```

That exposes farm names and logos to anyone with the anon key. They
are on the letterhead of every report already; acceptable.

## 4. Migration 54 — `farm_id` on every table

Additive. Column added nullable, backfilled to the Buloke farm, then
set `not null`. Policies still do not look at it, so behaviour is
unchanged.

### 4.1 Which tables, and where the value comes from

**Root tables** — `farm_id uuid not null default current_farm()`,
index on `(farm_id)`:

| Table | Note |
|---|---|
| `property` | both own PICs and vendor PICs. The address book is per farm |
| `heritage` | Buloke, Garratt, Rupari are this farm's lineages |
| `animal` | including `origin = 'reference'` sires — each farm has its own |
| `paddock` | |
| `treatment` | |
| `feed_source` | |
| `consignment` | |
| `shearing` | |
| `ai_semen` | |
| `embryo` | |
| `spray_event` | |
| `movement`, `feeding_period` | legacy from 01, still have policies; scope them rather than leave a hole |

**Child tables** — `farm_id uuid not null`, filled by a `before insert`
trigger from the parent row, index on `(farm_id)`:

| Table | Parent |
|---|---|
| `animal_status`, `weight_event`, `joining`, `calving`, `planned_joining`, `expected_calving` | `animal` (`animal_id` / `dam_id`) |
| `treatment_animal` | `treatment` |
| `consignment_animal` | `consignment` |
| `shearing_animal` | `shearing` |
| `paddock_stay`, `paddock_lineage` (`parent_id`), `paddock_geometry_log` | `paddock` |
| `feed_event`, `feed_adjustment` | `feed_source` |
| `feed_event_animal`, `feed_event_ref` | `feed_event` |
| `spray_product`, `spray_paddock` | `spray_event` |
| `cryo_txn` | `coalesce(ai_semen, embryo)` |
| `movement_animal` | `movement` |
| `record_change_log` | the logged row: `(to_jsonb(old)->>'farm_id')::uuid` |

**Not scoped:** `heartbeat` (global), `user_pref` (per user; a user's
field visibility follows them. If a user ever works two farms with
different needs, add `farm_id` to its key then), `farm_user` (profile).

### 4.2 The child trigger is also the cross-farm guard

```sql
create or replace function farm_id_from_parent() returns trigger
language plpgsql set search_path = public as $$   -- security INVOKER, deliberately
declare parent_table text := tg_argv[0]; parent_col text := tg_argv[1]; f uuid;
begin
  execute format('select farm_id from %I where id = $1', parent_table)
     into f using (to_jsonb(new)->>parent_col)::uuid;
  if f is null then
    raise exception 'No % on this farm for %', parent_table, parent_col;
  end if;
  new.farm_id := f;
  return new;
end $$;

create trigger treatment_animal_farm before insert on treatment_animal
  for each row execute function farm_id_from_parent('treatment', 'treatment_id');
-- … one per child table
```

Because the function runs as the caller, the lookup is under RLS. A
row pointing at another farm's parent finds nothing, `f` is null, and
the insert is refused with a message. This matters: foreign-key checks
run as the table owner and *bypass* RLS, so without this a user of
farm B who somehow held one of farm A's uuids could hang a treatment
on farm A's cow. With it, they cannot. `cryo_txn` gets a variant that
tries `ai_semen_id` then `embryo_id`.

The security definer triggers (`sync_expected_calving`,
`resolve_expected_calving`, `refresh_expectation`,
`sync_expected_calving_del`, `plan_fulfilled`, `log_record_change`)
run as owner, so the guard trigger's RLS lookup would see everything.
They do not use it: each copies `farm_id` from the row that fired it
(`new.farm_id` on the joining, or the logged row's `farm_id` for the
change log). Add that to each insert they make. `plan_fulfilled()`
only updates `planned_joining.joining_id` on an existing row, so it
needs nothing.

### 4.3 Uniqueness that has to become per farm

| Today | Becomes | Why |
|---|---|---|
| `heritage.name` unique | `(farm_id, name)` | two farms can both have a "Garratt" line |
| `property.pic` unique | `(farm_id, pic)` | two farms can both sell to the same abattoir PIC |
| `animal_stock_code_resident_uq (species, stock_code)` | `(farm_id, species, stock_code)` | `R 97` on both farms |
| `animal_nlis_uq (nlis_tag)` | `(farm_id, nlis_tag)` | an animal sold from farm A to farm B on the app is legitimately on both |
| `consignment_nvd_uq (nvd_serial)` | `(farm_id, nvd_serial)` | NVD books are per PIC, not global |
| `property_one_primary on ((true)) where is_primary` | `on (farm_id) where is_primary` | **the important one.** Today the index says "one primary in the whole database"; the second farm's primary PIC would be refused |

Leave alone: `paddock_name_live_uq (property_id, name)` — property is
already per farm; `paddock_stay_one_current`; the `expected_calving`
and `joining` uniques, all keyed on animal ids.

`animal.property_id` gains a check that the PIC belongs to the same
farm, enforced the cheap way: the `with check` on `animal` insert and
update in 55 includes `exists (select 1 from property p where p.id =
property_id)`, which under RLS only finds this farm's PICs.

### 4.4 Functions that pick a property

- `record_calving()` line 103: `(select id from property where
  is_primary limit 1)` — add `and farm_id = current_farm()`. It is
  already scoped by RLS (invoker), the predicate makes that legible.
- `record_drop()` lines 87 and 90: same two fallbacks, same change.
- `split_paddock()`: copies `property_id` from the parent; `farm_id`
  comes from the default. Nothing to do.
- `year_letter()`: the herd vote reads `animal` as invoker → scoped.
  Nothing to do, but see §7 on seeds.

### 4.5 Backfill, then tighten

```sql
do $$
declare t text; f uuid := (select id from farm where slug = 'buloke');
begin
  foreach t in array array[ … every table in 4.1 … ] loop
    execute format('alter table %I add column if not exists farm_id uuid references farm(id)', t);
    execute format('update %I set farm_id = $1 where farm_id is null', t) using f;
    execute format('alter table %I alter column farm_id set not null', t);
    execute format('create index if not exists %I_farm_idx on %I (farm_id)', t, t);
  end loop;
end $$;
```

Then the defaults on root tables and the triggers on child tables.
`record_change_log` is `bigserial`-keyed and append-only; its backfill
is the same `update`.

## 5. Migration 55 — the cutover

Every policy from `auth_roles` 02, `paddocks` 03, `paddock_history`
04, `feeding` 05, `audit` 06, `feed_adjust` 08, `consignment` 09,
`animal_edit` 10, `heartbeat` 12, `joining_method` 13, `sheep` 19,
`cryo_store` 31, `irwins` 36, `spray` 40 and 42, and `join_planning`
49 is re-created with one added predicate. The existing loops make it
mechanical:

```sql
create policy %I_read   on %I for select to authenticated
  using (farm_id = (select current_farm()) and can_read());
create policy %I_insert on %I for insert to authenticated
  with check (farm_id = (select current_farm()) and can_write());
create policy %I_update on %I for update to authenticated
  using (farm_id = (select current_farm()) and can_write())
  with check (farm_id = (select current_farm()) and can_write());
create policy %I_delete on %I for delete to authenticated
  using (farm_id = (select current_farm()) and my_role() = 'owner');
```

`(select current_farm())` rather than `current_farm()` so the planner
evaluates it once as an init-plan instead of per row. With the
`(farm_id)` index from 54, `v_animal_current` and
`v_stock_year_animal` should plan the same as today plus one index
condition. Measure it: `explain analyze` on both views before 54 and
after 55, keep the two plans in the migration's notes.

Exceptions to the shape:

- `heartbeat`: unchanged, `using (true)` for anon.
- `user_pref`: unchanged, own row.
- `record_change_log`: select only, `farm_id = current_farm() and
  can_read()`.
- `farm_user`: per §3.
- `animal` insert/update `with check` adds the property-belongs-here
  test from §4.3.

Then, in the same file: drop `farm_user.role` and `farm_user.active`
(55 is the first point at which nothing reads them), and `notify
pgrst, 'reload schema'`.

55 is the only migration with a visible effect, and the effect for the
Buloke farm should be **none**. §8 says how to prove that.

## 6. The pages

Small, because the database does the work. The pages send no
`farm_id`, and reads come back scoped.

**Branding comes from the farm row.** After sign-in, one query:
`from("farm").select("name,address,logo_url")` (RLS returns the one
row). Before sign-in, `v_farm_public` by `location.hostname`. Points to
change, all currently hardcoded to "Buloke Farm":

| File | Lines (as of 2026-09-28) | What |
|---|---|---|
| `index.html` | 12–13, 302, 3883, 3939, 3965 | title, boot mark, login mark, header, login prompt |
| `nav.js` | 59, 68 | drawer heading and footer hostname |
| `map.html` | 8, 74 | title, the address under "Paddocks" |
| `reports.html` | 8, 115, 180, 196, 271 | title, masthead, `HOME` fallback |
| `stock.html` | 8, 107, 145, 150, 264 | same |

**Letterhead stays on the PIC.** `reports` and `stock` already read
`trading_name, address, pic` from the primary property. Keep that:
Dad's PIC may trade under a different name and the LPA record must
carry the PIC's name. Farm name is for the app chrome; property
trading name is for the paper. `map.html` line 228 already looks up
the primary property for new paddocks and is scoped by RLS.

**Logo.** The Buloke mark is the app's own mark: Richard drew it and
the app is his. It stays on the loading screen (`index.html` 302),
the login screen, the home-screen icons in `manifest.webmanifest` and
`apple-touch-icon.png`, and the favicon, for every farm. Those are
static per site anyway and could not vary by farm without a Pages
Function serving a manifest per hostname. The farm's own logo
appears once signed in: the header on the phone, the nav drawer
heading, and the masthead on `/reports` and `/stock`. `farm.logo_url`
points at a public Supabase Storage bucket `farm-logos` (one PNG per
farm, uploaded by you); those four `<img>` tags become
`src="${farm.logo_url || '/mark.png'}"`, so a farm with no logo
uploaded shows the app mark.

**Hostname.** All farms are served by the one Pages project. Buloke
keeps `admin.bulokefarm.com.au`. A new farm gets either a CNAME on
their own domain or `<slug>.<a neutral domain you register>`; both are
custom domains on the same Pages project. `farm.hostname` lets the
login screen pick the right name and logo. If a hostname is not in
`v_farm_public`, the login screen shows the app's neutral name; the
farm is still resolved correctly after sign-in from membership.

**Users.** Supabase Auth is shared: one email, one login, across all
farms. The sign-in flow at `index.html` 3895 does not change. The
"awaiting activation" state now means "no active `farm_member` row".
A Manage → Users screen listing `farm_member` for the farm, with
role and active toggles for owners, replaces the SQL bootstrap in 02.
That screen is worth building with 55, not after, because it is how
you will onboard Dad's login on the new farm.

## 7. Seeds and imports

The seeds are Buloke data, not schema. Move `10_herd.sql`,
`20_treatments_2026.sql`, `30_historical.sql`, `90_joining_backfill.sql`
and their notes under `supabase/seed/buloke/`. A rebuild for another
farm must not run them.

Seeds run as `postgres` in the SQL editor, which **bypasses RLS**, so
`current_farm()` is null there and `year_letter()`'s herd vote sees
every farm. Every seed and the xlsx → SQL converters in `seed/tools`
must therefore name the farm explicitly: a `\set farm 'buloke'` or a
`--farm` flag that writes `farm_id = (select id from farm where slug =
'buloke')` into each insert. The child triggers still fire for seeds
(they are invoker but the caller is `postgres`, so the lookup finds the
parent regardless), so only root inserts need it.

## 8. Testing — what "proved" means

On a local Supabase stack (`supabase start` with only the database
enabled; `supabase/config.toml` moves it to ports 544xx so the
reveal-dm project on this machine keeps 543xx), restored from the
backup workflow's dump of production, three full runs of 01–55 (the
README's rule, and 34–38 are the reason). Then:

**Nothing changed for Buloke.** Before 54, as Richard's login, select
`count(*)` and `md5(string_agg(t::text, '' order by 1))` from every
one of the 34 views and dump to a file. After 55, same login, same
script. The two files must be identical. That is the regression test
for the whole change.

**Farm B is invisible.** Insert `farm` B, a `farm_member` for a test
login, a primary property, ten animals, a paddock, a treatment. Then
as farm B's login:

- every view returns only B's rows; `v_animal_current` count is 10
- `insert into treatment_animal` naming one of Buloke's animal ids →
  refused by the trigger
- `select record_calving(<Buloke dam id>, …)` → "was never on the
  property" (RLS hides the dam)
- `insert into animal (stock_code 'R 97', species cattle, …)` succeeds
  even though Buloke has an `R 97`
- setting B's PIC `is_primary = true` succeeds while Buloke's is also
  primary
- `year_letter('2026-06-01')` votes only over B's herd
- `record_change_log` shows only B's changes
- `farm_user` shows only B's members

And as Richard's login, the same list in reverse.

**Cost.** `explain analyze` on `v_animal_current`,
`v_stock_year_animal`, `v_animal_feed`, before and after. Any plan
that gained a sequential scan is a missing index.

**Advisors.** `get_advisors` security and performance after 55. Expect
`current_farm()` to be flagged like `my_role()` is; document that it
is intentional in the migration header.

## 9. Onboarding the second farm — the checklist this enables

The second farm is Toland Merino (tolandmerino.com.au), a Merino
stud. That is a good first tenant for a reason beyond being first: a
sheep-only farm exercises the species scope, the colour-letter tags,
`record_drop()` and the shearing register with none of the cattle
paths, so anything that quietly assumed a cow will show up.

1. `insert into farm (slug, name, address, hostname, logo_url)`
2. `insert into property (farm_id, pic, is_own, is_primary, trading_name, address)`
   — one per PIC they run
3. They sign up at the app; you `insert into farm_member (farm_id,
   user_id, role, active)` — or do it from Manage → Users
4. Upload their logo to `farm-logos`, set `logo_url`
5. Add their hostname as a custom domain on the Pages project; they
   set the CNAME
6. Paddocks traced on `/map`; herd imported with the converter and
   `--farm <slug>`

No migration, no deployment, no new Supabase project. Two farms or
twenty is the same list.

## 10. What this deliberately leaves alone

- **Per-PIC trading account and LPA views.** Still the migration 18
  follow-up. Works within a farm; this plan does not touch it.
- **Timezone.** `farm_today()` and the session timezone (39) are
  Melbourne. `farm.timezone` is created and populated but nothing
  reads it. A farm in another state would see the day roll over at the
  wrong hour, as UTC did before 39. When that farm appears,
  `farm_today()` reads `farm.timezone` and the views that use
  `current_date` move to `farm_today()`. Not before, because the
  README's rule is not to build against a value you cannot test.
- **Farm switching in the UI.** `current_farm_id` exists; there is no
  button to change it. A user who works two farms updates it in SQL
  until someone actually needs the button.
- **Self-service sign-up to a farm.** Membership is granted by an
  owner, as now. No invite links.
- **Two Supabase projects.** Rejected; see the conversation. If it is
  ever wanted for a client who needs their data physically separate,
  the schema after 55 runs unchanged on a second project with one
  `farm` row, so the door is not closed.

## 12. Applying to production — Richard's checklist

Everything below is on the live project and is deliberately not done
from here. In this order, on a quiet evening:

1. **Run the backup workflow** (*Actions → Weekly backup → Run
   workflow*, needs a repo admin) or wait for Sunday. It now commits
   `supabase/schema.sql` for the first time and leaves a fresh dump
   artifact. Download that dump; it is the way back.
2. **Merge the `farm-scope` branch.** Pages deploys it. Until step 3
   the live pages will fail to load the herd — `v_me` does not exist
   yet — so do 2 and 3 together, within minutes.
3. **Paste 52, 53, 54, 55 into the SQL editor, in order.** Each is
   safe to run again if it stops part-way. 52 does nothing on
   production (both halves already exist). 53 and 54 have no visible
   effect. 55 is the switch.
4. **Open the phone app.** It should look exactly as it did: same
   herd, same name in the header, Dad's login the same. Under
   Record → Manage there is a new *Who can see this farm*.
5. **Advisors.** *Database → Advisors* will flag `current_farm()` and
   `add_member()` the way it flags `my_role()`; intentional.
6. **Toland, when they are ready** — §9, plus the SQL comment at the
   foot of migration 53. They sign up at the site first; you add them
   by email from *Who can see this farm*, or by the insert in 53.

If anything in step 4 is wrong, the dump from step 1 restores the
whole database from before step 3; the pages from before step 2 are
one revert away.

## 11. Effort and order

| Step | Rough size |
|---|---|
| Prerequisites (§2) | half a day, mostly the event trigger |
| 53 farm + membership + helpers | half a day |
| 54 columns, triggers, uniques, backfill | one to two days |
| 55 policies, cutover | one day |
| Pages: branding, logo, users screen | one day |
| Seeds under `buloke/`, `--farm` on the converters | half a day |
| Testing per §8, three runs, both logins | two days |

About a week of careful work, on a branch, with a fresh dump in hand
before 55 runs on production. Migrations 49–51 have landed, so nothing
is waiting on another thread. When 53–55 go in, add their rows to the
migrations table in the README after 51, and move the four seeds and
their notes under `seed/buloke/` in the same commit as 55.
