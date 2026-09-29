-- ============================================================
-- 57. A login on more than one farm can switch between them.
--
-- farm_user.current_farm_id has been the switch since 53; what was
-- missing was any way to see the other farms. The farm_member policy
-- showed only the current farm's members and the farm policy only
-- the current farm, so a login with two memberships could not list
-- them. Now a login also sees its own membership rows, and the farms
-- behind them, and v_my_farms puts that in one place for the pages.
-- Switching is the page updating current_farm_id on its own profile,
-- which farm_user_update already allows; current_farm() only honours
-- the choice if there is an active membership there, so a wrong id
-- cannot land anyone on a farm they are not on.
--
-- Safe to run more than once.
-- ============================================================

drop policy if exists farm_member_read on farm_member;
create policy farm_member_read on farm_member
  for select to authenticated
  using (farm_id = (select current_farm()) or user_id = auth.uid());

drop policy if exists farm_read on farm;
create policy farm_read on farm
  for select to authenticated
  using (id = (select current_farm())
         or exists (select 1 from farm_member m
                     where m.farm_id = farm.id and m.user_id = auth.uid() and m.active));

create or replace view v_my_farms with (security_invoker = on) as
select f.id        as farm_id,
       f.slug,
       f.name,
       f.logo_url,
       m.role,
       f.id = current_farm() as is_current
  from farm_member m
  join farm f on f.id = m.farm_id
 where m.user_id = auth.uid()
   and m.active
 order by f.name;

grant select on v_my_farms to authenticated;

notify pgrst, 'reload schema';
