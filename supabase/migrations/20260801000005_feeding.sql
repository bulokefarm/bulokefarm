-- ============================================================
-- Buloke Farm — stock feed: sources and feeding events
-- Apply after 07_treatments_2026.sql
-- Safe to run more than once.
--
-- Two LPA sections are in play and they are different things:
--   3D  what feed came onto the property (a load of hay, a silo of grain)
--   3C  what was fed out, to what, when
--
-- Feeding is recorded against a PADDOCK, not against animals. Who ate
-- it is derived from paddock_stay, so putting hay out is one entry
-- rather than fourteen.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Feed sources — LPA Section 3D, introduced stock feed.
-- ------------------------------------------------------------

create table if not exists feed_source (
  id            uuid primary key default gen_random_uuid(),
  feedstuff     text not null,              -- 'Lucerne hay (round)'
  batch_ref     text,                       -- silo ID, load number, paddock cut from
  received_on   date,
  amount        text,                       -- '75 bales / 25 tonnes'
  origin        text,                       -- 'Dubbo NSW' or 'Home grown'
  home_grown    boolean not null default false,
  cvd_ref       text,                       -- commodity vendor declaration number
  residue_cert  boolean,                    -- residue analysis certificate held
  ram_free      boolean,                    -- certified free of restricted animal material
  storage       text,                       -- 'Hay shed 1', 'Silo 28'
  signed_by     text,
  notes         text,
  exhausted_on  date,                       -- when the load ran out
  recorded_by   uuid references farm_user(id) default auth.uid(),
  created_at    timestamptz not null default now()
);
create index if not exists feed_source_open_idx
  on feed_source (feedstuff) where exhausted_on is null;

-- ------------------------------------------------------------
-- 2. Feeding events — LPA Section 3C.
--    Target a paddock (usual) or specific animals (feeder mobs).
-- ------------------------------------------------------------

create table if not exists feed_event (
  id             uuid primary key default gen_random_uuid(),
  fed_on         date not null default current_date,
  ended_on       date,                      -- for a feeding period rather than one drop
  feed_source_id uuid references feed_source(id) on delete restrict,
  ration         text,                      -- free text when there's no source record
  paddock_id     uuid references paddock(id) on delete restrict,
  amount         text,                      -- '2 rolls', '3.95 tonne'
  method         text,                      -- 'Rolled out', 'Self feeder', 'Ring feeder'
  notes          text,
  recorded_by    uuid references farm_user(id) default auth.uid(),
  created_at     timestamptz not null default now(),
  check (ended_on is null or ended_on >= fed_on),
  check (feed_source_id is not null or ration is not null)
);
create index if not exists feed_event_date_idx    on feed_event (fed_on desc);
create index if not exists feed_event_paddock_idx on feed_event (paddock_id, fed_on desc);

-- Only for feeding that genuinely targets named animals.
create table if not exists feed_event_animal (
  feed_event_id uuid not null references feed_event(id) on delete cascade,
  animal_id     uuid not null references animal(id) on delete cascade,
  primary key (feed_event_id, animal_id)
);

-- ------------------------------------------------------------
-- 3. Bring the old per-animal feeding_period rows across.
-- ------------------------------------------------------------

do $$
declare r record; new_id uuid;
begin
  if exists (select 1 from information_schema.tables
              where table_name='feeding_period') then

    for r in
      select started_on, ended_on, ration, location, notes,
             array_agg(animal_id) as animals
        from feeding_period
       group by started_on, ended_on, ration, location, notes
    loop
      insert into feed_event (fed_on, ended_on, ration, method, notes)
      values (r.started_on, r.ended_on,
              coalesce(r.ration, 'Ration not recorded'), r.location, r.notes)
      returning id into new_id;

      insert into feed_event_animal (feed_event_id, animal_id)
      select new_id, unnest(r.animals)
      on conflict do nothing;
    end loop;

    drop table feeding_period;
  end if;
end $$;

-- A source record for the grain, so the RAM declaration lives where
-- LPA expects it rather than buried in a note.
insert into feed_source (feedstuff, batch_ref, storage, origin, ram_free, notes)
select 'Irwins Grain Free Optimiser', 'silo 28', 'Silo 28, self feeder',
       'Irwins', true, 'Certified safe, zero restricted animal material.'
where not exists (select 1 from feed_source where feedstuff='Irwins Grain Free Optimiser');

update feed_event
   set feed_source_id = (select id from feed_source where feedstuff='Irwins Grain Free Optimiser'),
       amount = case fed_on when '2026-03-17' then '3.95 tonne'
                            when '2026-06-07' then '4.00 tonne' else amount end,
       method = coalesce(method, 'Self feeder')
 where ration = 'Irwins Grain Free Optimiser' and feed_source_id is null;

-- ------------------------------------------------------------
-- 4. Views. Head count is derived, never typed.
-- ------------------------------------------------------------

create or replace view v_feed_event with (security_invoker = on) as
select
  fe.id, fe.fed_on, fe.ended_on, fe.amount, fe.method, fe.notes,
  coalesce(fs.feedstuff, fe.ration)                  as feedstuff,
  fs.batch_ref, fs.origin, fs.cvd_ref, fs.ram_free, fs.home_grown,
  fe.paddock_id, p.name                              as paddock_name,
  p.colour                                           as paddock_colour,
  u.display_name                                     as fed_by,
  (select count(*) from feed_event_animal fa where fa.feed_event_id = fe.id)
  + case when fe.paddock_id is null then 0 else
      (select count(*) from paddock_stay s
        where s.paddock_id = fe.paddock_id
          and s.moved_in <= fe.fed_on
          and (s.moved_out is null or s.moved_out >= fe.fed_on)) end
                                                     as head
from feed_event fe
left join feed_source fs on fs.id = fe.feed_source_id
left join paddock     p  on p.id  = fe.paddock_id
left join farm_user   u  on u.id  = fe.recorded_by;

-- Treatments, LPA Section 2 shape, one row per event.
create or replace view v_treatment_report with (security_invoker = on) as
select
  t.treated_on, t.description, t.product_name, t.batch_number,
  t.product_expiry, t.dose_rate, t.route,
  t.withholding_days, t.esi_days, t.safe_for_slaughter,
  coalesce(t.treated_by, u.display_name)      as treated_by,
  coalesce(t.treated_by_contact, u.phone)     as treated_by_contact,
  t.adverse_reaction, t.broken_needle,
  count(ta.animal_id)                         as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
left join animal a on a.id = ta.animal_id
group by t.id, u.display_name, u.phone;

-- ------------------------------------------------------------
-- 5. RLS
-- ------------------------------------------------------------

do $$
declare t text;
begin
  foreach t in array array['feed_source','feed_event','feed_event_animal'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists %I_read on %I', t, t);
    execute format('drop policy if exists %I_insert on %I', t, t);
    execute format('drop policy if exists %I_update on %I', t, t);
    execute format('drop policy if exists %I_delete on %I', t, t);
    execute format('create policy %I_read   on %I for select to authenticated using (can_read())', t, t);
    execute format('create policy %I_insert on %I for insert to authenticated with check (can_write())', t, t);
    execute format('create policy %I_update on %I for update to authenticated using (can_write()) with check (can_write())', t, t);
    execute format($f$create policy %I_delete on %I for delete to authenticated using (my_role() = 'owner')$f$, t, t);
  end loop;
end $$;
