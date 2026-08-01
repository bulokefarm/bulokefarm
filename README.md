# Buloke Farm

Cattle records for 267 North Canal Rd, Trafalgar. PIC 3BWWY089.

Three static pages talking to a Supabase Postgres database. No build
step, no server, no framework. The whole app is about 24 KB over the wire.

| Page | Path | For |
|---|---|---|
| `index.html` | `/` | The phone app — herd, map, family tree, recording |
| `map-editor.html` | `/map` | Tracing paddock boundaries on satellite imagery. Laptop. |
| `reports.html` | `/reports` | LPA records, printable. Editing and change history. Laptop. |

## Layout

```
public/                 served as-is by Cloudflare Pages
supabase/
  migrations/           schema — applied in filename order
  seed/                 data loads, run once, in numeric order
    notes/              flagged rows from each import
    tools/              the xlsx -> SQL converters
.github/workflows/
```

**Migrations define shape; seeds carry data.** Keeping them apart matters:
migrations run first on a rebuild, so anything depending on imported
records has to be a seed. That's why the joining-outcome backfill lives
in `seed/90_joining_backfill.sql` and not in the migration that adds the
column.

## Deploying

Cloudflare Pages builds nothing. Point it at `public/` and it serves.

1. Push this repo to `buloke-farm` on GitHub.
2. Cloudflare → Workers & Pages → Create → Pages → connect the repo.
   - Framework preset: **None**
   - Build command: *leave empty*
   - Output directory: `public`
3. Deploy. You get `<project>.pages.dev` — confirm it works there first.
4. Pages project → Custom domains → add `admin.bulokefarm.com.au`.
   Cloudflare gives you a CNAME target.
5. Add that CNAME wherever the zone actually lives — check the
   nameservers in VIPControl, it's either VentraIP or Squarespace.
   **Add only the `admin` record.** Nothing else in the zone changes, so
   the Squarespace site is untouched.

The custom domain must exist in the Pages dashboard *before* the CNAME,
or it resolves to a 522.

After that, `git push` to `main` deploys. There is nothing else to do.

## Database

Project `production`, region **Oceania (Sydney)** — deliberately not
Singapore; the Vocus path from Trafalgar to `ap-southeast-1` is broken.

```bash
npx supabase link --project-ref hgnzignikbpdbbyubahu
npx supabase db push
```

Rebuilding from empty: migrations, then seeds in numeric order —
`10_herd`, `20_treatments_2026`, `30_historical`, `90_joining_backfill`.

Every migration is written to be safely re-runnable. Keep it that way. A
migration that can't be retried is a bad afternoon on a database with
real records in it.

Two rules learned the hard way here:

- `create or replace view` can only **append** columns. Adding one at the
  front, renaming, or reordering needs `drop view if exists` first.
- Drop dependent views **before** touching any column they read.

### Settings to check

- **Authentication → Providers → Email → disable public sign-ups.**
  There's no signup form in the app, but the endpoint is open by default.
  Users get created from the dashboard, then activated in SQL.
- **Authentication → URL Configuration → Site URL:**
  `https://admin.bulokefarm.com.au`. Password-reset links point here.

### Keys

The anon key is in the HTML and that is correct — it is designed to be
public, and row level security is what protects the data. Every table
denies by default, then grants read to active farm users, write to
managers and owners, delete to owners only.

The **service_role** key bypasses RLS entirely. It must never appear in
this repo, in the HTML, or in a chat window.

## GitHub secrets

| Secret | Value |
|---|---|
| `SUPABASE_URL` | `https://hgnzignikbpdbbyubahu.supabase.co` |
| `SUPABASE_ANON_KEY` | the anon key |
| `SUPABASE_DB_URL` | connection string, Project Settings → Database |

`keepalive.yml` pokes the database on weekdays, because a free project
pauses after a week idle and this app goes quiet between musters.
`backup.yml` dumps weekly to a build artifact, because the free plan has
no backups and these records carry retention obligations. Both become
unnecessary on the paid plan — delete them then.

## Adding a user

1. Supabase → Authentication → Users → Add user, auto-confirm.
2. ```sql
   update farm_user
      set display_name = 'Name', phone = '04xx xxx xxx',
          role = 'manager', active = true
    where id = (select id from auth.users where email = 'them@example.com');
   ```

Roles: `viewer` reads, `manager` records, `owner` also deletes. New
accounts land inactive and see nothing until switched on.

`display_name` and `phone` fill the LPA "treated by (name and contact)"
field automatically, which is the whole reason for separate logins.

## Design notes

**Nothing is silently rewritten.** Treatments, feeding, consignments,
weights, calvings, joinings and animal records all have change-log
triggers capturing the before and after with who and when. Feed stock
uses adjustments rather than editing the original quantity. Paddocks are
retired, not deleted, and their boundary at the time is kept. Corrections
are normal; invisible corrections are not.

**Derived values are never stored.** Age, growth rate, head counts,
stocking rate, slaughter-clear dates and feed remaining are all computed
on read. The spreadsheet stored about a third of its columns as
calculations, and they went stale.

**An animal is on hand if its life state is `alive` or absent.** Sold and
died animals stay in the pedigree and the family tree but count towards
nothing.

## Installing on a phone

Open `admin.bulokefarm.com.au` in Safari or Chrome and choose *Add to
Home Screen*. The manifest makes it open full screen without browser
chrome. Drop `icon-192.png` and `icon-512.png` into `public/` when you
have artwork.
