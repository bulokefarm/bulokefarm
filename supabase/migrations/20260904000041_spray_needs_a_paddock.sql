-- ============================================================
-- Buloke Farm — a spray record must name a paddock
-- Apply after 20260904000040_spray_records.sql.
-- Safe to run more than once.
--
-- 40 let an application be recorded against free text instead of a
-- paddock, so that spot spraying a laneway or a boundary still had
-- somewhere to go. That was the wrong trade. The free-text case is
-- invisible to `paddock_graze_block()` — the one piece of this that
-- does more than print — so the records most likely to be forgotten
-- were also the ones the guard could never catch. A laneway that gets
-- sprayed is a piece of country stock walk down; if it is worth
-- recording it is worth having a paddock row.
--
-- `paddock_desc` therefore stops being an alternative to the paddock
-- and becomes a note about where inside it — 'north fenceline',
-- 'around the troughs'. Renamed to `location_note` so the old meaning
-- cannot creep back in.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Rename, before anything reads the column by its old name.
-- ------------------------------------------------------------

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema='public' and table_name='spray_event'
                and column_name='paddock_desc')
     and not exists (select 1 from information_schema.columns
              where table_schema='public' and table_name='spray_event'
                and column_name='location_note')
  then
    -- Views that read the column must go first; section 3 rebuilds them.
    drop view if exists v_spray_report;
    alter table spray_event rename column paddock_desc to location_note;
    raise notice 'spray_event.paddock_desc renamed to location_note';
  end if;
end $$;

comment on column spray_event.location_note is
  'Where within the paddock. Not a substitute for the paddock itself.';

-- ------------------------------------------------------------
-- 2. Require the paddock.
--
-- Any application already on file without one is NAMED, not guessed
-- at and not deleted. The constraint is skipped until they are fixed,
-- so this migration can be re-run after you assign them.
-- ------------------------------------------------------------

do $$
declare
  orphans int;
  r       record;
begin
  select count(*) into orphans from spray_event where paddock_id is null;

  if orphans > 0 then
    raise notice '% spray application(s) have no paddock. NOT NULL not applied.', orphans;
    for r in select id, applied_on, location_note, crop_treated
               from spray_event where paddock_id is null order by applied_on loop
      raise notice '  % — % — %', r.applied_on,
                   coalesce(r.location_note, '(nowhere recorded)'),
                   coalesce(r.crop_treated, '(no crop)');
    end loop;
    raise notice 'Assign a paddock to each, then run this migration again.';
  else
    alter table spray_event alter column paddock_id set not null;
    raise notice 'spray_event.paddock_id is now required';
  end if;
end $$;

-- The check from 40 allowed free text to stand in for the paddock.
-- With the column required it is dead weight, and while it exists it
-- reads as though the alternative is still on offer.
alter table spray_event drop constraint if exists spray_event_has_a_place;

-- A paddock with spray history cannot be deleted out from under it.
-- `on delete set null` was harmless when the column was nullable and
-- is a hole now: it would blank the one field the guard reads.
alter table spray_event drop constraint if exists spray_event_paddock_id_fkey;
alter table spray_event add  constraint spray_event_paddock_id_fkey
  foreign key (paddock_id) references paddock(id) on delete restrict;

-- ------------------------------------------------------------
-- 3. Rebuild the report view.
--
-- `place` is the paddock, full stop. The note rides alongside it
-- rather than standing in for it.
-- ------------------------------------------------------------

drop view if exists v_spray_report;

create view v_spray_report with (security_invoker = on) as
select
  se.id                                    as event_id,
  sp.id                                    as product_id,
  se.applied_on,
  se.paddock_id,
  p.name                                   as paddock_name,
  p.colour                                 as paddock_colour,
  p.name                                   as place,
  se.location_note,
  p.area_ha                                as paddock_area_ha,
  se.crop_treated,
  se.area_ha,
  se.water_rate_l_ha,
  se.method,
  se.wind_direction,
  se.wind_speed_kmh,
  se.applied_by,
  se.applied_by_contact,
  coalesce(se.applied_by, u.display_name)      as applied_by_shown,
  coalesce(se.applied_by_contact, u.phone)     as contact_shown,
  se.notes                                 as event_notes,

  sp.product_name,
  sp.active_ingredient,
  sp.chemical_rate,
  sp.batch_number,
  sp.graze_withhold_days,
  sp.harvest_withhold_days,
  sp.esi_days,
  sp.notes                                 as product_notes,

  -- Derived, never stored. NULL when the withhold is unknown, which
  -- reads on the report as a gap rather than as "safe today".
  (se.applied_on + sp.graze_withhold_days)   as safe_to_graze,
  (se.applied_on + sp.harvest_withhold_days) as safe_to_harvest,
  (se.applied_on + sp.graze_withhold_days) > farm_today() as graze_withheld,

  (select count(*) from record_change_log l
    where l.table_name = 'spray_event'   and l.row_id = se.id) as event_edits,
  (select count(*) from record_change_log l
    where l.table_name = 'spray_product' and l.row_id = sp.id) as product_edits
from spray_event se
left join spray_product sp on sp.spray_event_id = se.id
left join paddock       p  on p.id = se.paddock_id
left join farm_user     u  on u.id = se.recorded_by;

-- ------------------------------------------------------------
-- 4. Verification:
--
--   select count(*) from spray_event where paddock_id is null;  -- 0
--   \d spray_event      -- paddock_id ... not null
--
-- And that a paddock carrying spray history now refuses to vanish:
--   delete from paddock where id = <one that has been sprayed>;
--   ERROR:  update or delete on table "paddock" violates foreign key
-- ------------------------------------------------------------

notify pgrst, 'reload schema';
