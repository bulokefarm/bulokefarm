-- ============================================================
-- Buloke Farm — cattle module schema
-- Target: Supabase / PostgreSQL 15+
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- Reference / lookup
-- ------------------------------------------------------------

create type sex_t          as enum ('female', 'male', 'steer', 'unknown');
create type life_state_t   as enum ('alive', 'sold', 'died', 'slaughtered');
create type animal_class_t as enum ('calf', 'weaner', 'yearling', 'harvest', 'breeder', 'protector', 'bull');
create type cycle_t        as enum ('autumn', 'spring');
create type origin_t       as enum ('bred', 'purchased', 'reference');

-- A property (PIC) — yours or a vendor's.
create table property (
  id           uuid primary key default gen_random_uuid(),
  pic          text unique not null,          -- e.g. 3BWWY089
  name         text,
  is_own       boolean not null default false,
  address      text,
  created_at   timestamptz not null default now()
);

-- Herd / brand lineage: 'Buloke', 'Garratt'
create table heritage (
  id    uuid primary key default gen_random_uuid(),
  name  text unique not null
);

-- ------------------------------------------------------------
-- Animal: identity only. No computed fields, no event data.
--
-- NOTE: this table also holds "reference" animals — sires and dams
-- that were never on the property (AI bulls, vendor cows). They carry
-- origin='reference' and almost no other data. This keeps pedigree a
-- single self-join instead of a mess of nullable text columns.
-- ------------------------------------------------------------

create table animal (
  id             uuid primary key default gen_random_uuid(),

  -- identity
  stock_code     text,                        -- 'N 84' — year letter + number
  year_letter    text,                        -- 'N'
  herd_number    int,                         -- 84
  name           text,
  nlis_tag       text,                        -- 3BWWY089XBH0035
  origin         origin_t not null default 'bred',

  -- biology
  sex            sex_t not null default 'unknown',
  dob            date,
  breed          text,
  grade          text,                        -- 'P', '1/2', 'F1-W'
  coat_colour    text,
  polled         boolean,                     -- P/H column
  marking_code   text,                        -- 'n/B/R' column — meaning TBC

  -- provenance
  heritage_id    uuid references heritage(id),
  property_id    uuid references property(id),          -- current PIC
  origin_property_id uuid references property(id),      -- 'Original PIC'
  purchased_on   date,
  purchase_note  text,

  -- pedigree
  sire_id        uuid references animal(id),
  dam_id         uuid references animal(id),

  birth_weight_kg numeric(6,2),
  weaned_on      date,
  notes          text,

  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Stock codes recycle on a 26-year letter cycle, so uniqueness is only
-- enforced among animals actually on the property.
create unique index animal_stock_code_resident_uq
  on animal (stock_code) where origin <> 'reference' and stock_code is not null;
create unique index animal_nlis_uq
  on animal (nlis_tag) where nlis_tag is not null;
create index animal_dam_idx  on animal (dam_id);
create index animal_sire_idx on animal (sire_id);

-- ------------------------------------------------------------
-- Status is a dated transition, not a column.
-- 'Breader' -> 'Harvest' -> sold is a timeline.
-- ------------------------------------------------------------

create table animal_status (
  id           uuid primary key default gen_random_uuid(),
  animal_id    uuid not null references animal(id) on delete cascade,
  effective_on date not null,
  life_state   life_state_t not null,
  class        animal_class_t,
  reason       text,
  created_at   timestamptz not null default now(),
  unique (animal_id, effective_on)
);
create index animal_status_animal_idx on animal_status (animal_id, effective_on desc);

-- ------------------------------------------------------------
-- Weights: a time series, not two cells.
-- ------------------------------------------------------------

create table weight_event (
  id          uuid primary key default gen_random_uuid(),
  animal_id   uuid not null references animal(id) on delete cascade,
  weighed_on  date not null,
  weight_kg   numeric(7,2) not null check (weight_kg > 0),
  method      text,                         -- scale, tape, estimate
  notes       text,
  created_at  timestamptz not null default now(),
  unique (animal_id, weighed_on)
);

-- ------------------------------------------------------------
-- Treatments — shaped to satisfy LPA Section 2 in full, so an NVD
-- can be produced by query rather than by memory.
-- ------------------------------------------------------------

create table treatment (
  id                  uuid primary key default gen_random_uuid(),
  treated_on          date not null,
  description         text,                 -- mob/location description
  product_name        text not null,
  batch_number        text,
  product_expiry      date,
  dose_rate           text,
  route               text,                 -- pour-on, injection, oral
  withholding_days    int,
  esi_days            int,                  -- export slaughter interval
  safe_for_slaughter  date generated always as
                        (treated_on + coalesce(withholding_days,0)) stored,
  treated_by          text,
  treated_by_contact  text,
  adverse_reaction    text,
  broken_needle       boolean not null default false,
  equipment_clean     boolean,
  notes               text,
  created_at          timestamptz not null default now()
);

-- Many animals per treatment event.
create table treatment_animal (
  treatment_id uuid not null references treatment(id) on delete cascade,
  animal_id    uuid not null references animal(id) on delete cascade,
  primary key (treatment_id, animal_id)
);

-- ------------------------------------------------------------
-- Breeding. The '1st Join / 2nd Join' column pairs become rows.
-- ------------------------------------------------------------

create table joining (
  id                uuid primary key default gen_random_uuid(),
  dam_id            uuid not null references animal(id) on delete cascade,
  sire_id           uuid references animal(id),
  cycle             cycle_t,
  season            text,                   -- '2026-2027'
  attempt           int not null default 1, -- 1st join, 2nd join
  joined_on         date,
  gestation_days    int default 285,
  due_on            date,
  confidence        numeric(3,2) check (confidence between 0 and 1),
  notes             text,
  created_at        timestamptz not null default now(),
  unique (dam_id, season, attempt)
);
create index joining_dam_idx on joining (dam_id);

create table calving (
  id            uuid primary key default gen_random_uuid(),
  joining_id    uuid references joining(id) on delete set null,
  dam_id        uuid not null references animal(id) on delete cascade,
  calved_on     date not null,
  calf_id       uuid references animal(id),  -- null if stillborn
  assisted      boolean,
  outcome       text,                        -- live, stillborn, died
  notes         text,                        -- 'leg caught vet assist'
  created_at    timestamptz not null default now()
);

-- Projected drops. NOT animals — they have no identity yet.
-- Promoted into `animal` + `calving` when the calf hits the ground.
create table expected_calving (
  id            uuid primary key default gen_random_uuid(),
  joining_id    uuid references joining(id) on delete cascade,
  dam_id        uuid not null references animal(id) on delete cascade,
  sire_id       uuid references animal(id),
  season        text not null,               -- '2026-2027'
  cycle         cycle_t,
  due_on        date,
  resolved_calving_id uuid references calving(id),
  created_at    timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Feeding periods (On Feeder / Off Feeder)
-- ------------------------------------------------------------

create table feeding_period (
  id          uuid primary key default gen_random_uuid(),
  animal_id   uuid not null references animal(id) on delete cascade,
  started_on  date not null,
  ended_on    date,
  ration      text,
  location    text,
  days        int generated always as (ended_on - started_on) stored,
  notes       text
);

-- ------------------------------------------------------------
-- Movements: LPA 5A/5B. Purchases and sales in one shape.
-- ------------------------------------------------------------

create table movement (
  id              uuid primary key default gen_random_uuid(),
  direction       text not null check (direction in ('in','out')),
  moved_on        date not null,
  nvd_serial      text,
  nlis_upload_id  text,
  head_count      int,
  counterparty    text,                      -- vendor or buyer
  counterparty_pic text,
  destination     text,                      -- saleyard, PIC, paddock
  breed           text,
  sex             text,
  notes           text,
  created_at      timestamptz not null default now()
);

create table movement_animal (
  movement_id  uuid not null references movement(id) on delete cascade,
  animal_id    uuid not null references animal(id) on delete cascade,
  sale_weight_kg   numeric(7,2),
  carcass_weight_kg numeric(7,2),
  price_per_kg  numeric(8,3),
  amount_ex_gst numeric(12,2),
  gst           numeric(12,2),
  fees          numeric(12,2),
  primary key (movement_id, animal_id)
);

-- ------------------------------------------------------------
-- Derived view: everything the spreadsheet computed, computed on read.
-- ------------------------------------------------------------

create view v_animal_current with (security_invoker = on) as
select
  a.id,
  a.stock_code,
  a.name,
  a.sex,
  a.dob,
  a.breed,
  a.nlis_tag,
  dam.stock_code  as dam_code,
  dam.name        as dam_name,
  sire.name       as sire_name,
  (current_date - a.dob)                          as age_days,
  round((current_date - a.dob) / 30.4375, 2)      as age_months,
  round((current_date - a.dob) / 365.25, 2)       as age_years,
  s.life_state,
  s.class,
  w.weight_kg     as last_weight_kg,
  w.weighed_on    as last_weighed_on,
  case when w.weight_kg is not null and a.birth_weight_kg is not null
            and w.weighed_on > a.dob
       then round((w.weight_kg - a.birth_weight_kg) / (w.weighed_on - a.dob), 4)
  end as adg_kg_per_day
from animal a
left join animal dam  on dam.id  = a.dam_id
left join animal sire on sire.id = a.sire_id
left join lateral (
  select life_state, class from animal_status
  where animal_id = a.id and effective_on <= current_date
  order by effective_on desc limit 1
) s on true
left join lateral (
  select weight_kg, weighed_on from weight_event
  where animal_id = a.id order by weighed_on desc limit 1
) w on true
where a.origin <> 'reference';

-- ------------------------------------------------------------
-- Row Level Security. Single-tenant today, multi-user tomorrow.
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array[
    'property','heritage','animal','animal_status','weight_event',
    'treatment','treatment_animal','joining','calving','expected_calving',
    'feeding_period','movement','movement_animal'
  ] loop
    execute format('alter table %I enable row level security', t);
    execute format($f$
      create policy %I_authenticated on %I
      for all to authenticated using (true) with check (true)
    $f$, t, t);
  end loop;
end $$;
