-- ============================================================
-- 79. The butcher sees what goes by carrier, and gets the labels.
--
-- The butcher packs the boxes the carrier takes away, and sticks a
-- shipping label on each. Until now they saw the deliveries only as a
-- line under each box; the list the carrier works from, and the labels
-- themselves, came to them some other way — an email, a print-out
-- carried in.
--
-- Three things, for a harvest whose sheets are released to them:
--
--   butcher_delivery()  the delivery list as Sales -> Delivery has it:
--                       who, where, which day, how many cartons, the
--                       instructions, the carrier's number; where and
--                       when the carrier collects; and the label files.
--                       It is what the manifest is made from, so the
--                       butcher can download the same manifest.
--
--   the collection      which day the carrier collects, and whether the
--                       collection is a row of the manifest, were things
--                       ticked on the Delivery page and forgotten when
--                       it closed. They are the harvest's now
--                       (collect_on, collect_row), so the manifest is
--                       the same file whoever downloads it.
--
--   the labels          once the manifest is in the carrier's system it
--                       makes a label per carton. The farm uploads that
--                       file on the Delivery page; the butcher downloads
--                       it from their sheets. The files are kept in a
--                       private bucket, harvest-files, one folder per
--                       harvest:  <farm id>/<harvest id>/<file name>.
--
-- Who may touch a file is one question, asked by harvest_file_ok():
-- the farm's owner and manager may add and remove; they and a viewer
-- may read; the butcher may read, and only once the harvest is
-- released. Nobody on another farm, and nobody signed out, gets
-- anything: the bucket is not public and there is no other rule on it.
--
-- A database with no file storage (a local stack with it switched off)
-- skips the bucket and its rules and lists no files; everything else
-- here still works.
--
-- Safe to run more than once.
-- ============================================================

alter table harvest add column if not exists collect_on  date;
alter table harvest add column if not exists collect_row boolean not null default true;

comment on column harvest.collect_on is
  'The day the carrier collects the cartons from the butcher. Blank means the pick-up day.';
comment on column harvest.collect_row is
  'Whether the collection is the first row of the carrier''s manifest for this harvest.';

-- ------------------------------------------------------------
-- 1. Who may read or change a file of a harvest
-- ------------------------------------------------------------

create or replace function harvest_file_ok(p_name text, p_write boolean) returns boolean
language plpgsql stable security definer set search_path = public as $$
declare
  fid   uuid := current_farm();
  role  text := my_role()::text;
  parts text[] := string_to_array(coalesce(p_name, ''), '/');
  h     harvest;
begin
  if fid is null or role is null then return false; end if;
  -- <farm id>/<harvest id>/<file name>, and nothing else.
  if array_length(parts, 1) is distinct from 3 or parts[1] <> fid::text
     or parts[2] !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
     or parts[3] !~ '^[A-Za-z0-9][A-Za-z0-9._-]{0,159}$' then
    return false;
  end if;
  select * into h from harvest where id = parts[2]::uuid and farm_id = fid;
  if not found then return false; end if;
  if p_write then return role in ('owner', 'manager'); end if;
  return role in ('owner', 'manager', 'viewer')
      or (role = 'butcher' and h.butcher_released_at is not null);
end $$;

comment on function harvest_file_ok(text, boolean) is
  'May the person signed in read (or, p_write, add and remove) this file of a harvest? The path is <farm id>/<harvest id>/<file name>. The butcher reads, and only a released harvest.';

revoke execute on function harvest_file_ok(text, boolean) from public, anon;
grant  execute on function harvest_file_ok(text, boolean) to authenticated;

-- ------------------------------------------------------------
-- 2. Somewhere for the files to live
-- ------------------------------------------------------------

do $$
begin
  if to_regclass('storage.buckets') is null or to_regclass('storage.objects') is null then
    raise notice 'No file storage on this database: the harvest-files bucket and its rules are skipped.';
    return;
  end if;

  insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  values ('harvest-files', 'harvest-files', false, 26214400,
          array['application/pdf', 'image/png', 'image/jpeg'])
  on conflict (id) do update
    set public = false, file_size_limit = excluded.file_size_limit,
        allowed_mime_types = excluded.allowed_mime_types;

  execute 'drop policy if exists harvest_files_read   on storage.objects';
  execute 'drop policy if exists harvest_files_add    on storage.objects';
  execute 'drop policy if exists harvest_files_remove on storage.objects';

  execute $p$create policy harvest_files_read on storage.objects
    for select to authenticated
    using (bucket_id = 'harvest-files' and public.harvest_file_ok(name, false))$p$;
  execute $p$create policy harvest_files_add on storage.objects
    for insert to authenticated
    with check (bucket_id = 'harvest-files' and public.harvest_file_ok(name, true))$p$;
  execute $p$create policy harvest_files_remove on storage.objects
    for delete to authenticated
    using (bucket_id = 'harvest-files' and public.harvest_file_ok(name, true))$p$;
  -- No update rule: a file is added or removed, never written over.
end $$;

-- ------------------------------------------------------------
-- 3. The delivery list, as the butcher (and Sales) reads it
-- ------------------------------------------------------------

create or replace function butcher_delivery(p_harvest uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  fid   uuid := current_farm();
  role  text := my_role()::text;
  h     harvest;
  files jsonb := '[]'::jsonb;
begin
  if fid is null or role is null then
    raise exception 'Sign in first';
  end if;
  select * into h from harvest where id = p_harvest and farm_id = fid;
  if not found or (role = 'butcher' and h.butcher_released_at is null) then
    raise exception 'That harvest is not available';
  end if;

  -- The label files: whatever is in this harvest's folder, oldest first.
  -- The name shown is the file's own, without the stamp put in front of
  -- it to keep two uploads of "labels.pdf" apart.
  if to_regclass('storage.objects') is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
             'path', o.name,
             'name', regexp_replace(split_part(o.name, '/', 3), '^[0-9]{10,}-', ''),
             'size', (o.metadata->>'size')::bigint,
             'type', o.metadata->>'mimetype',
             'added_at', o.created_at) order by o.created_at), '[]'::jsonb)
      into files
      from storage.objects o
     where o.bucket_id = 'harvest-files'
       and o.name like fid::text || '/' || h.id::text || '/%';
  end if;

  return jsonb_build_object(
    'role', role,
    'farm', (select jsonb_build_object('id', f.id, 'name', f.name, 'phone', b.phone, 'email', b.email,
                                       'order_prefix', coalesce(b.order_prefix, 'BF'))
               from farm f left join farm_business b on b.farm_id = f.id
              where f.id = fid),
    'harvest', jsonb_build_object(
      'id', h.id, 'code', h.code, 'kind', h.kind, 'title', h.title,
      'pickup_on', h.pickup_on, 'delivery_on', h.delivery_on,
      'collect_on', h.collect_on, 'collect_row', h.collect_row,
      'released', h.butcher_released_at is not null),
    -- Where and when the carrier collects, if that is a row of the
    -- manifest: ticked, the place complete, and a day to do it on.
    'collect', (
      select jsonb_build_object(
               'name', b.collect_name, 'street', b.collect_street, 'suburb', b.collect_suburb,
               'state', b.collect_state, 'postcode', b.collect_postcode,
               'window', coalesce(nullif(b.collect_window, ''), '11:00-18:00'),
               'note', coalesce(nullif(b.collect_note, ''), 'Pick up from ' || b.collect_name),
               'on', coalesce(h.collect_on, h.pickup_on),
               'zone', (select z.zone from v_delivery_postcode z
                         where z.farm_id = fid and z.postcode = b.collect_postcode
                         order by z.carrier limit 1))
        from farm_business b
       where b.farm_id = fid and h.collect_row
         and coalesce(h.collect_on, h.pickup_on) is not null
         and nullif(b.collect_name, '') is not null and nullif(b.collect_street, '') is not null
         and nullif(b.collect_suburb, '') is not null and nullif(b.collect_state, '') is not null
         and nullif(b.collect_postcode, '') is not null),
    'deliveries', coalesce((
      select jsonb_agg(to_jsonb(d) order by d.order_no)
        from (select v.order_no, v.ref, v.carrier_ref, v.to_name, v.to_phone, v.customer_email,
                     v.to_street, v.to_suburb, v.to_state, v.to_postcode,
                     v.ship_type, v.ship_instructions, v.deliver_on,
                     v.cartons, v.kg, v.carrier_no, v.tracking_url,
                     (select z.zone from v_delivery_postcode z
                       where z.farm_id = fid and z.postcode = v.to_postcode
                       order by z.carrier limit 1) as zone
                from v_order v
               where v.farm_id = fid and v.harvest_id = h.id
                 and v.fulfilment = 'delivery' and v.status <> 'cancelled') d), '[]'::jsonb),
    'files', files);
end $$;

comment on function butcher_delivery(uuid) is
  'A harvest''s deliveries, where and when the carrier collects, and its label files: what the manifest is made from. The butcher gets it for a released harvest only.';

revoke execute on function butcher_delivery(uuid) from public, anon;
grant  execute on function butcher_delivery(uuid) to authenticated;

notify pgrst, 'reload schema';
