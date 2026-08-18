-- ============================================================
-- Buloke Farm — the two Irwins grain loads, recorded properly
-- Apply after 20260802000035_feed_run_estimate.sql.
-- Safe to run more than once.
--
-- The paper record has two loads into silo 28:
--
--   17/3/26   3.95 tonne   V 11, V 17, W 05, V 23, V 25
--    7/6/26   4.00 tonne   V 17, W 01, V 16, V 20, V 06, V 10
--
-- Neither was recorded correctly.
--
-- THE MARCH LOAD WAS NEVER CREATED. 20_treatments_2026.sql attaches
-- feeding periods with `select ... from animal where stock_code =
-- any(array[...])`. V 11, V 17 and W 05 are Dad's cattle under the
-- second PIC and are not imported yet; V 23 and V 25 are created in
-- 30_historical.sql, which runs AFTER the treatment file. So at that
-- moment none of the five existed, the select returned nothing, and
-- an insert of zero rows is not an error. 3.95 tonne of grain simply
-- never appeared in Section 3C.
--
-- THE JUNE LOAD SURVIVED BUT WAS EDITED. It picked up only the three
-- animals that exist — W 01, V 16, V 20 — and its date was later
-- changed to 17 April. There is no April load. It is 7 June.
--
-- ONE SOURCE WAS DOING THE WORK OF TWO. Each delivery is its own
-- consignment with its own date, tonnage and RAM declaration, and
-- Section 3D wants a line for each. One row cannot carry two.
--
-- WHAT IS STILL MISSING, DELIBERATELY. V 06, V 10, V 11, V 17 and
-- W 05 are not invented here. They are held as written references
-- against the event, the way cryo_txn.female_ref holds a cow the
-- register names but the herd does not yet contain. When Dad's PIC
-- is imported, run feed_resolve_refs() and they attach themselves.
-- Until then the head counts are honestly short and say why.
-- ============================================================

-- ------------------------------------------------------------
-- 1. The date that was wrong.
--
-- Narrow on purpose: only the Irwins event sitting on 17 April,
-- which is the one edit we know about. If it has already been put
-- right this matches nothing and does nothing.
-- ------------------------------------------------------------

update feed_event fe
   set fed_on = date '2026-06-07',
       notes  = coalesce(nullif(fe.notes, '') || ' ', '')
                || 'Date corrected to 7 Jun 2026 from the paper record; had been edited to 17 Apr.'
  from feed_source fs
 where fs.id = fe.feed_source_id
   and fs.feedstuff ilike '%irwins%'
   and fe.fed_on = date '2026-04-17';

-- ------------------------------------------------------------
-- 2. Section 3D: one line per delivery.
--
-- The existing row keeps the June load — the surviving event already
-- points at it, so nothing has to be repointed. March gets a new row.
-- ------------------------------------------------------------

-- Identified by the event that points at it, not by its own date.
-- Keying the update on "any Irwins source that isn't already June"
-- looked fine on a fresh database and was destructive on the second
-- run: it matched the March row created moments earlier and rewrote
-- it into a duplicate June row, losing the March delivery. Step 1
-- has already moved the surviving event onto 7 June, so the source
-- it points at is unambiguous, and on later runs the March event
-- points at the March source and is never selected.
update feed_source
   set received_on = date '2026-06-07',
       quantity    = 4.00,
       unit        = 'tonne',
       batch_ref   = 'silo 28 · 7 Jun 26',
       amount      = '4.00 tonne',
       feed_type   = coalesce(feed_type, 'grain'),
       storage     = coalesce(storage, 'Silo 28, self feeder'),
       origin      = coalesce(origin, 'Irwins'),
       ram_free    = true,
       notes       = 'Certified safe, zero restricted animal material.'
 where id = (select fe.feed_source_id
               from feed_event fe
               join feed_source fs2 on fs2.id = fe.feed_source_id
              where fs2.feedstuff ilike '%irwins%'
                and fe.fed_on = date '2026-06-07'
              order by fe.created_at
              limit 1);

insert into feed_source (feedstuff, feed_type, batch_ref, received_on,
                         quantity, unit, amount, origin, ram_free,
                         storage, notes)
select 'Irwins Grain Free Optimiser', 'grain', 'silo 28 · 17 Mar 26',
       date '2026-03-17', 3.95, 'tonne', '3.95 tonne', 'Irwins', true,
       'Silo 28, self feeder',
       'Certified safe, zero restricted animal material.'
 where not exists (select 1 from feed_source
                    where feedstuff ilike '%irwins%'
                      and batch_ref = 'silo 28 · 17 Mar 26');

-- ------------------------------------------------------------
-- 3. Section 3C: the March feed-out that was never written.
-- ------------------------------------------------------------

insert into feed_event (fed_on, feed_source_id, amount, qty, method, notes)
select date '2026-03-17',
       fs.id, '3.95 tonne', 3.95, 'Self feeder',
       'Rebuilt from the paper record. Certified safe, zero restricted animal material.'
  from feed_source fs
 where fs.batch_ref = 'silo 28 · 17 Mar 26'
   and not exists (select 1 from feed_event fe
                    where fe.feed_source_id = fs.id
                      and fe.fed_on = date '2026-03-17');

-- ------------------------------------------------------------
-- 4. Who was on each load, as written on the paper.
--
-- Same shape as cryo_txn.female_ref: the written tag is kept even
-- when it resolves, so the record still says what the sheet said.
-- ------------------------------------------------------------

create table if not exists feed_event_ref (
  feed_event_id uuid not null references feed_event(id) on delete cascade,
  stock_code    text not null,
  note          text,
  primary key (feed_event_id, stock_code)
);

comment on table feed_event_ref is
  'Animals named on the paper feeding record. Resolved into feed_event_animal by feed_resolve_refs() as they appear in the herd; unresolved ones stay visible in v_feed_unmapped rather than being dropped.';

alter table feed_event_ref enable row level security;
drop policy if exists feed_event_ref_read   on feed_event_ref;
drop policy if exists feed_event_ref_insert on feed_event_ref;
drop policy if exists feed_event_ref_update on feed_event_ref;
drop policy if exists feed_event_ref_delete on feed_event_ref;
create policy feed_event_ref_read   on feed_event_ref for select to authenticated using (can_read());
create policy feed_event_ref_insert on feed_event_ref for insert to authenticated with check (can_write());
create policy feed_event_ref_update on feed_event_ref for update to authenticated using (can_write()) with check (can_write());
create policy feed_event_ref_delete on feed_event_ref for delete to authenticated using (my_role() = 'owner');

-- March load.
insert into feed_event_ref (feed_event_id, stock_code, note)
select fe.id, v.code, v.note
  from feed_event fe
  join feed_source fs on fs.id = fe.feed_source_id
  cross join (values
    ('V 11', 'second PIC — not imported yet'),
    ('V 17', 'second PIC — not imported yet'),
    ('W 05', 'second PIC — not imported yet'),
    ('V 23', null),
    ('V 25', null)) as v(code, note)
 where fs.feedstuff ilike '%irwins%'
   and fe.fed_on = date '2026-03-17'
on conflict do nothing;

-- June load.
insert into feed_event_ref (feed_event_id, stock_code, note)
select fe.id, v.code, v.note
  from feed_event fe
  join feed_source fs on fs.id = fe.feed_source_id
  cross join (values
    ('V 17', 'second PIC — not imported yet'),
    ('W 01', null),
    ('V 16', null),
    ('V 20', null),
    ('V 06', 'second PIC — not imported yet'),
    ('V 10', 'second PIC — not imported yet')) as v(code, note)
 where fs.feedstuff ilike '%irwins%'
   and fe.fed_on = date '2026-06-07'
on conflict do nothing;

-- ------------------------------------------------------------
-- 5. Resolve what can be resolved. Re-runnable, by design:
--    run it again after Dad's PIC lands and the rest attach.
-- ------------------------------------------------------------

create or replace function feed_resolve_refs()
returns integer language plpgsql security invoker as $$
declare n integer;
begin
  insert into feed_event_animal (feed_event_id, animal_id)
  select r.feed_event_id, a.id
    from feed_event_ref r
    join animal a
      on a.stock_code = r.stock_code
     and a.origin <> 'reference'
   on conflict do nothing;
  get diagnostics n = row_count;
  return n;
end $$;

comment on function feed_resolve_refs() is
  'Attaches paper-named animals to their feeding events as they appear in the herd. Run again after any herd import.';

select feed_resolve_refs();

-- ------------------------------------------------------------
-- 6. Say plainly what is still short.
-- ------------------------------------------------------------

create or replace view v_feed_unmapped with (security_invoker = on) as
select
  fe.fed_on,
  coalesce(fs.feedstuff, fe.ration) as feedstuff,
  r.stock_code,
  coalesce(r.note, 'not in the herd')      as why,
  fe.id                                    as feed_event_id
from feed_event_ref r
join feed_event fe on fe.id = r.feed_event_id
left join feed_source fs on fs.id = fe.feed_source_id
where not exists (
  select 1 from animal a
   where a.stock_code = r.stock_code and a.origin <> 'reference')
order by fe.fed_on, r.stock_code;

-- ------------------------------------------------------------
-- 7. The head count the paper actually says.
--
-- v_feed_load divides the tonnage by head to project an empty date.
-- Counting only animals that exist made the June load read 148 days
-- instead of 74 — three of the six are Dad's and not imported, so
-- the feeder looked half as busy as it is. The paper says six head
-- ate it, and six head is what the estimate must divide by, whether
-- or not the herd table can name them yet.
-- ------------------------------------------------------------

create or replace view v_feed_load with (security_invoker = on) as
select
  fe.id                                as feed_event_id,
  fe.feed_source_id,
  fe.fed_on,
  fe.ended_on,
  fs.feedstuff,
  fs.unit,
  fe.qty,
  feed_qty_kg(fe.qty, fs.unit)         as qty_kg,
  fs.intake_kg_head_day                as rate,
  hd.head,
  case when feed_qty_kg(fe.qty, fs.unit) is not null
        and fs.intake_kg_head_day > 0
        and hd.head > 0
       then round(feed_qty_kg(fe.qty, fs.unit)
                  / (hd.head * fs.intake_kg_head_day))
  end                                  as est_days,
  case when feed_qty_kg(fe.qty, fs.unit) is not null
        and fs.intake_kg_head_day > 0
        and hd.head > 0
       then fe.fed_on + (round(feed_qty_kg(fe.qty, fs.unit)
                  / (hd.head * fs.intake_kg_head_day)))::int
  end                                  as est_empty_on,
  (current_date - fe.fed_on)           as days_out,
  hd.head_unmapped
from feed_event fe
join feed_source fs on fs.id = fe.feed_source_id
left join lateral (
  select
    (select count(distinct c.animal_id) from v_feed_cover c
      where c.feed_event_id = fe.id)
    + (select count(*) from feed_event_ref r
        where r.feed_event_id = fe.id
          and not exists (select 1 from animal a
                           where a.stock_code = r.stock_code
                             and a.origin <> 'reference'))   as head,
    (select count(*) from feed_event_ref r
      where r.feed_event_id = fe.id
        and not exists (select 1 from animal a
                         where a.stock_code = r.stock_code
                           and a.origin <> 'reference'))     as head_unmapped
) hd on true;

notify pgrst, 'reload schema';
