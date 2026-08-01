-- ============================================================
-- Buloke Farm — heartbeat
-- One readable row so the keep-awake job performs a genuine database
-- query. Contains nothing, exposes nothing.
-- Drop this once the project is on a paid plan.
-- ============================================================

create table if not exists heartbeat (ok boolean primary key default true);
insert into heartbeat (ok) values (true) on conflict do nothing;

alter table heartbeat enable row level security;
drop policy if exists heartbeat_anon on heartbeat;
create policy heartbeat_anon on heartbeat for select to anon, authenticated using (true);
