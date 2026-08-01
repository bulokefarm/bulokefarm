-- ============================================================
-- Buloke Farm — feed stock adjustments
-- Apply after 10_feed_store.sql. Safe to run more than once.
--
-- What's left = what came in, plus adjustments, minus what went out.
-- Recounts, spoilage and top-ups are recorded rather than applied by
-- rewriting the original quantity, so the store balance stays
-- explainable: you can see why 40 rolls became 36.
-- ============================================================

create table if not exists feed_adjustment (
  id             uuid primary key default gen_random_uuid(),
  feed_source_id uuid not null references feed_source(id) on delete cascade,
  adjusted_on    date not null default current_date,
  qty_delta      numeric(10,2) not null,   -- negative for loss, positive for a top-up
  reason         text not null,            -- 'Recount', 'Weather damage', 'More delivered'
  notes          text,
  recorded_by    uuid references farm_user(id) default auth.uid(),
  created_at     timestamptz not null default now(),
  check (qty_delta <> 0)
);
create index if not exists feed_adjustment_source_idx
  on feed_adjustment (feed_source_id, adjusted_on desc);

drop trigger if exists feed_adjustment_changed on feed_adjustment;
create trigger feed_adjustment_changed
  after update or delete on feed_adjustment
  for each row execute function log_record_change();

-- ------------------------------------------------------------
-- Store balance, rebuilt.
-- ------------------------------------------------------------

drop view if exists v_feed_store;

create view v_feed_store with (security_invoker = on) as
with used as (
  select feed_source_id, coalesce(sum(qty),0) as qty_out,
         count(*) as feed_outs, max(fed_on) as last_fed
    from feed_event where feed_source_id is not null
   group by feed_source_id
), adj as (
  select feed_source_id, coalesce(sum(qty_delta),0) as qty_adj, count(*) as adjustments
    from feed_adjustment group by feed_source_id
)
select
  fs.id, fs.feedstuff, fs.feed_type, fs.batch_ref, fs.received_on,
  fs.quantity, fs.unit, fs.amount, fs.origin, fs.home_grown,
  fs.cvd_ref, fs.residue_cert, fs.ram_free, fs.storage,
  fs.signed_by, fs.exhausted_on, fs.notes,
  coalesce(u.qty_out, 0)        as used,
  coalesce(a.qty_adj, 0)        as adjusted,
  coalesce(u.feed_outs, 0)      as feed_outs,
  coalesce(a.adjustments, 0)    as adjustments,
  u.last_fed,
  case when fs.quantity is not null
       then round(fs.quantity + coalesce(a.qty_adj,0) - coalesce(u.qty_out,0), 2)
  end as remaining,
  case when fs.quantity is not null and fs.quantity + coalesce(a.qty_adj,0) > 0
       then round(100 * (fs.quantity + coalesce(a.qty_adj,0) - coalesce(u.qty_out,0))
                      / (fs.quantity + coalesce(a.qty_adj,0)))
  end as pct_left
from feed_source fs
left join used u on u.feed_source_id = fs.id
left join adj  a on a.feed_source_id = fs.id;

-- ------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------

alter table feed_adjustment enable row level security;
drop policy if exists feed_adjustment_read   on feed_adjustment;
drop policy if exists feed_adjustment_insert on feed_adjustment;
drop policy if exists feed_adjustment_update on feed_adjustment;
drop policy if exists feed_adjustment_delete on feed_adjustment;
create policy feed_adjustment_read   on feed_adjustment for select to authenticated using (can_read());
create policy feed_adjustment_insert on feed_adjustment for insert to authenticated with check (can_write());
create policy feed_adjustment_update on feed_adjustment for update to authenticated using (can_write()) with check (can_write());
create policy feed_adjustment_delete on feed_adjustment for delete to authenticated using (my_role() = 'owner');
