-- ============================================================
-- Buloke Farm — change log for compliance records
-- Apply after 08_feeding.sql, then run 10_feed_store.sql.
-- Safe to run more than once.
--
-- Treatment and feeding records can be corrected — people mistype
-- batch numbers — but a record you can silently rewrite proves less
-- than one you can't. Every update and delete is kept, with who and
-- when. Inserts are not logged: the row itself is the record.
-- ============================================================

create table if not exists record_change_log (
  id          bigserial primary key,
  table_name  text        not null,
  row_id      uuid        not null,
  action      text        not null check (action in ('update','delete')),
  old_row     jsonb,
  new_row     jsonb,
  changed_by  uuid references farm_user(id) default auth.uid(),
  changed_at  timestamptz not null default now()
);
create index if not exists record_change_log_row_idx
  on record_change_log (table_name, row_id, changed_at desc);
create index if not exists record_change_log_when_idx
  on record_change_log (changed_at desc);

create or replace function log_record_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' then
    -- Ignore no-op saves so the log stays readable.
    if to_jsonb(old) - 'created_at' = to_jsonb(new) - 'created_at' then
      return new;
    end if;
    insert into record_change_log (table_name, row_id, action, old_row, new_row)
    values (tg_table_name, old.id, 'update', to_jsonb(old), to_jsonb(new));
    return new;
  else
    insert into record_change_log (table_name, row_id, action, old_row)
    values (tg_table_name, old.id, 'delete', to_jsonb(old));
    return old;
  end if;
end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'treatment','feed_event','feed_source','weight_event','calving','animal'
  ] loop
    execute format('drop trigger if exists %I_changed on %I', t, t);
    execute format('create trigger %I_changed after update or delete on %I
                    for each row execute function log_record_change()', t, t);
  end loop;
end $$;

-- The log is readable by anyone who can read the records, and
-- writable by nobody: only the triggers put rows in it.
alter table record_change_log enable row level security;
drop policy if exists record_change_log_read on record_change_log;
create policy record_change_log_read on record_change_log
  for select to authenticated using (can_read());

-- ------------------------------------------------------------
-- Expose the primary key so records can be edited from the report.
--
-- These must be DROPPED, not replaced. `create or replace view` can
-- only append columns to the end of an existing view — adding `id`
-- at the front is a reshape, and Postgres refuses it.
-- ------------------------------------------------------------

drop view if exists v_treatment_report;
drop view if exists v_feed_event;

create view v_treatment_report with (security_invoker = on) as
select
  t.id,
  t.treated_on, t.description, t.product_name, t.batch_number,
  t.product_expiry, t.dose_rate, t.route,
  t.withholding_days, t.esi_days, t.safe_for_slaughter,
  t.treated_by, t.treated_by_contact,
  coalesce(t.treated_by, u.display_name)   as treated_by_shown,
  coalesce(t.treated_by_contact, u.phone)  as contact_shown,
  t.adverse_reaction, t.broken_needle, t.notes,
  count(ta.animal_id)                      as head,
  string_agg(a.stock_code, ', ' order by a.stock_code) as tags,
  (select count(*) from record_change_log l
    where l.table_name='treatment' and l.row_id=t.id) as edits
from treatment t
left join farm_user u on u.id = t.recorded_by
left join treatment_animal ta on ta.treatment_id = t.id
left join animal a on a.id = ta.animal_id
group by t.id, u.display_name, u.phone;

create view v_feed_event with (security_invoker = on) as
select
  fe.id, fe.fed_on, fe.ended_on, fe.amount, fe.method, fe.notes,
  fe.feed_source_id, fe.ration,
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
          and (s.moved_out is null or s.moved_out >= fe.fed_on)) end   as head,
  (select count(*) from record_change_log l
    where l.table_name='feed_event' and l.row_id=fe.id)                as edits
from feed_event fe
left join feed_source fs on fs.id = fe.feed_source_id
left join paddock     p  on p.id  = fe.paddock_id
left join farm_user   u  on u.id  = fe.recorded_by;

-- ------------------------------------------------------------
-- What changed, in plain language.
--   select * from v_record_history where table_name = 'treatment';
-- ------------------------------------------------------------

create or replace view v_record_history with (security_invoker = on) as
select
  l.id, l.table_name, l.row_id, l.action, l.changed_at,
  coalesce(u.display_name, 'unknown') as changed_by,
  case when l.action = 'delete' then 'record deleted'
       else (select string_agg(format('%s: %s → %s', k,
                     coalesce(l.old_row->>k,'(blank)'),
                     coalesce(l.new_row->>k,'(blank)')), '; ' order by k)
               from jsonb_object_keys(l.new_row) k
              where l.old_row->k is distinct from l.new_row->k
                and k not in ('created_at','recorded_by'))
  end as summary,
  l.old_row
from record_change_log l
left join farm_user u on u.id = l.changed_by;
