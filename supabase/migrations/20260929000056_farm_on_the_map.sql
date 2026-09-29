-- ============================================================
-- 56. Where the farm is, for the map.
--
-- The paddock editor opened on Buloke's coordinates for everyone:
-- Anna signed in and got Trafalgar under her own address. A farm with
-- paddocks is fine — the page fits the view to them — but a new farm
-- has none, and the first thing its owner does is trace them, so the
-- imagery has to start in the right place.
--
-- Two columns on farm, and v_me carries them to the page. Nothing is
-- geocoded at runtime: the address is looked up once, by hand, when
-- the farm is created, and written here.
--
-- Safe to run more than once.
-- ============================================================

alter table farm add column if not exists lat numeric(9,6);
alter table farm add column if not exists lng numeric(9,6);

comment on column farm.lat is 'Where the map opens for a farm with no paddocks yet. Looked up once from the address.';

update farm set lat = -38.1837289, lng = 146.1161005 where slug = 'buloke' and lat is null;
update farm set lat = -36.5973131, lng = 145.6901397 where slug = 'toland' and lat is null;

create or replace view v_me with (security_invoker = on) as
select m.user_id        as id,
       u.display_name,
       u.phone,
       m.role,
       m.active,
       m.farm_id,
       f.slug,
       f.name            as farm_name,
       f.address         as farm_address,
       f.logo_url,
       f.timezone,
       f.lat,
       f.lng
  from farm_member m
  join farm_user u on u.id = m.user_id
  join farm      f on f.id = m.farm_id
 where m.user_id = auth.uid()
   and m.farm_id = current_farm();

grant select on v_me to authenticated;

notify pgrst, 'reload schema';
