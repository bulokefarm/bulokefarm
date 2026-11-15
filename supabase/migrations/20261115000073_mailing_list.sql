-- ============================================================
-- 73. The mailing list: who has asked to hear about the next
--     harvest, and who has asked not to.
--
-- A customer is someone who has ordered. A subscriber is someone who
-- gave an email address so they could be told when there is meat to
-- order. Most of one are not the other, so they are two tables; a
-- subscriber who has also ordered is found by their email, not by a
-- link someone has to keep in step (v_subscriber).
--
-- The list arrives from Mailchimp, where it has lived since 2016, as
-- three exports: subscribed, unsubscribed, and "cleaned" — Mailchimp's
-- word for an address that bounced. All three are kept. The second
-- and third are the more important: a list that only remembers who
-- said yes will, the first time it is re-imported or retyped, write
-- to someone who said no.
--
--   subscribed     may be written to
--   unsubscribed   asked not to be. Never written to
--   bounced        the address does not work. Never written to
--
-- status_on is when it became that, and it is what settles a
-- disagreement: when the same address comes in again — next month's
-- export, a form on the website — the later change wins, and if the
-- two are the same moment the one that is not "subscribed" wins.
-- Nothing an import does can turn a later "no" back into a "yes".
--
-- Changes are logged like every other record (06).
--
-- Safe to run more than once.
-- ============================================================

create table if not exists subscriber (
  id          uuid primary key default gen_random_uuid(),
  farm_id     uuid not null default current_farm() references farm(id),
  email       text not null,
  first_name  text,                  -- as given; often the whole name
  last_name   text,
  state       text,                  -- as they said, not guessed from an IP address
  status      text not null default 'subscribed'
                check (status in ('subscribed', 'unsubscribed', 'bounced')),
  status_on   timestamptz not null default now(),
  status_note text,                  -- the campaign it bounced on; the reason they gave
  opted_in_on timestamptz,
  source      text,                  -- 'Mailchimp: Embed Form', 'manual'
  recorded_by uuid references farm_user(id) default auth.uid(),
  created_at  timestamptz not null default now(),
  constraint subscriber_email_ck check (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);
create unique index if not exists subscriber_email_uq on subscriber (farm_id, lower(email));
create index if not exists subscriber_farm_idx on subscriber (farm_id);

comment on table subscriber is
  'The mailing list, with everyone who has left it. Only status = subscribed may be written to.';

drop trigger if exists subscriber_changed on subscriber;
create trigger subscriber_changed after update or delete on subscriber
  for each row execute function log_record_change();

alter table subscriber enable row level security;

drop policy if exists subscriber_read   on subscriber;
drop policy if exists subscriber_insert on subscriber;
drop policy if exists subscriber_update on subscriber;
drop policy if exists subscriber_delete on subscriber;
create policy subscriber_read on subscriber
  for select to authenticated using (farm_id = (select current_farm()) and can_read());
create policy subscriber_insert on subscriber
  for insert to authenticated with check (farm_id = (select current_farm()) and can_write());
create policy subscriber_update on subscriber
  for update to authenticated
  using      (farm_id = (select current_farm()) and can_write())
  with check (farm_id = (select current_farm()) and can_write());
create policy subscriber_delete on subscriber
  for delete to authenticated using (farm_id = (select current_farm()) and my_role() = 'owner');

grant select, insert, update, delete on subscriber to authenticated;

-- A subscriber, and whether they have ever ordered.
create or replace view v_subscriber with (security_invoker = on) as
select s.id, s.farm_id, s.email, s.first_name, s.last_name, s.state, s.status, s.status_on,
       s.status_note, s.opted_in_on, s.source, s.created_at,
       c.id                     as customer_id,
       c.name                   as customer_name,
       coalesce(c.orders, 0)    as orders
  from subscriber s
  left join lateral (
    select vc.id, vc.name, vc.orders
      from v_customer vc
     where vc.farm_id = s.farm_id and lower(vc.email) = lower(s.email)
     order by vc.orders desc, vc.created_at
     limit 1) c on true;

grant select on v_subscriber to authenticated;

-- ------------------------------------------------------------
-- Bringing a list in.
--
-- p_status is what the file is a list of: 'subscribed',
-- 'unsubscribed' or 'bounced'. p_rows is
--   [{email, first_name, last_name, state, opted_in_on, changed_on,
--     note, source}, ...]
-- with changed_on the moment each became that status, as the export
-- says; missing, it is taken as now.
--
-- Someone new is added. Someone already on the list keeps what is
-- known about them unless the file says more, and changes status
-- only if the file's change is the later one (see above). A row
-- that changes nothing writes nothing, so re-importing the same
-- export is not forty lines in the change log.
--
-- Runs as the caller: RLS decides who may. Returns counts.
-- ------------------------------------------------------------

create or replace function import_subscribers(p_status text, p_rows jsonb) returns jsonb
language plpgsql set search_path = public as $$
declare
  n_rows    int;
  n_valid   int;
  n_added   int;
  n_changed int;
begin
  if p_status not in ('subscribed', 'unsubscribed', 'bounced') then
    raise exception 'A list is of subscribed, unsubscribed or bounced addresses';
  end if;
  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'Nothing to import';
  end if;
  n_rows := jsonb_array_length(p_rows);

  with incoming as (
    select distinct on (lower(btrim(x ->> 'email')))
           lower(btrim(x ->> 'email'))                                as email,
           nullif(btrim(x ->> 'first_name'), '')                      as first_name,
           nullif(btrim(x ->> 'last_name'), '')                       as last_name,
           nullif(upper(btrim(x ->> 'state')), '')                    as state,
           nullif(x ->> 'opted_in_on', '')::timestamptz               as opted_in_on,
           coalesce(nullif(x ->> 'changed_on', '')::timestamptz, now()) as status_on,
           nullif(btrim(x ->> 'note'), '')                            as note,
           nullif(btrim(x ->> 'source'), '')                          as source
      from jsonb_array_elements(p_rows) as t(x)
     where btrim(coalesce(x ->> 'email', '')) ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
     order by lower(btrim(x ->> 'email')), coalesce(nullif(x ->> 'changed_on', '')::timestamptz, now()) desc),
  added as (
    insert into subscriber (email, first_name, last_name, state, status, status_on, status_note, opted_in_on, source)
    select i.email, i.first_name, i.last_name, i.state, p_status, i.status_on, i.note, i.opted_in_on, i.source
      from incoming i
     where not exists (select 1 from subscriber s
                        where s.farm_id = current_farm() and lower(s.email) = i.email)
    returning 1),
  changed as (
    update subscriber s
       set first_name  = coalesce(s.first_name, i.first_name),
           last_name   = coalesce(s.last_name, i.last_name),
           state       = coalesce(s.state, i.state),
           opted_in_on = coalesce(s.opted_in_on, i.opted_in_on),
           source      = coalesce(s.source, i.source),
           status      = case when w.wins then p_status else s.status end,
           status_on   = case when w.wins then i.status_on else s.status_on end,
           status_note = case when w.wins then i.note else s.status_note end
      from (select n.*, e.id as sid,
                   (n.status_on > e.status_on
                      or (n.status_on = e.status_on and p_status <> 'subscribed')) as wins
              from incoming n
              join subscriber e on e.farm_id = current_farm() and lower(e.email) = n.email) i
     cross join lateral (select i.wins) w
     where s.id = i.sid
       and (   (w.wins and (s.status, s.status_on, s.status_note) is distinct from (p_status, i.status_on, i.note))
            or (s.first_name is null and i.first_name is not null)
            or (s.last_name  is null and i.last_name  is not null)
            or (s.state      is null and i.state      is not null)
            or (s.opted_in_on is null and i.opted_in_on is not null)
            or (s.source     is null and i.source     is not null))
    returning 1)
  select (select count(*) from incoming), (select count(*) from added), (select count(*) from changed)
    into n_valid, n_added, n_changed;

  return jsonb_build_object('rows', n_rows, 'added', n_added, 'changed', n_changed,
                            'unchanged', n_valid - n_added - n_changed,
                            'skipped', n_rows - n_valid);
end $$;

revoke execute on function import_subscribers(text, jsonb) from public, anon;
grant  execute on function import_subscribers(text, jsonb) to authenticated;

notify pgrst, 'reload schema';
