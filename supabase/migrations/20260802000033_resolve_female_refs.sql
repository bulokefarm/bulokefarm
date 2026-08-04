-- ============================================================
-- Buloke Farm — matching the cows named on the register
-- Apply after 20260802000032_straw_markings.sql.
--
-- The register names a cow however she was known at the time: 'SD U 08',
-- 'Bul L 74', 'Tonnie T14', 'Pi 134'. SD is South Devon and Bul is
-- Buloke — breed and herd labels, not part of the tag. The tag is the
-- letter and number on the end.
--
-- Doing this in a function rather than in the import means it can be
-- run again. Every time a herd is added — Rupari's next — the same
-- statement picks up whoever has become resolvable, and the ones that
-- never resolve stay honestly unmatched with the written name intact.
-- ============================================================

create or replace function cryo_ref_code(ref text)
returns text language sql immutable as $$
  select case when m is null then null else
    upper(m[1]) || ' ' ||
    -- Two digits is the house style: S 05, T 02. Three stay as they
    -- are. lpad would truncate 122 to 12, which is worse than useless.
    case when length(m[2]) >= 2 then m[2] else '0' || m[2] end
  end
  from regexp_match(
         regexp_replace(coalesce(ref, ''),
           '^\s*(SD|Bul|Bu|Buloke|Rup|Rupari|B)\.?\s+', '', 'i'),
         '([A-Za-z]{1,2})\s?0*([0-9]{1,3})\s*$') as m;
$$;

comment on function cryo_ref_code(text) is
  'Pulls the stock code out of a written reference. Breed and herd prefixes are dropped; the trailing letter and number is the tag.';

-- ------------------------------------------------------------
-- Apply it. Safe to run again at any time.
-- ------------------------------------------------------------

update cryo_txn t
   set female_id = a.id
  from animal a
 where t.female_id is null
   and t.female_ref is not null
   and a.origin <> 'reference'
   and a.species = 'cattle'
   and a.stock_code = cryo_ref_code(t.female_ref);

-- ------------------------------------------------------------
-- Show the working, so an unmatched row says why.
-- ------------------------------------------------------------

drop view if exists v_cryo_unmapped;
create view v_cryo_unmapped with (security_invoker = on) as
select
  t.female_ref,
  cryo_ref_code(t.female_ref)                        as reads_as,
  count(*)                                           as times,
  min(t.on_date)                                     as first_used,
  max(t.on_date)                                     as last_used,
  string_agg(distinct coalesce(s.sire_name, e.pairing), '; ') as to_which,
  case
    when cryo_ref_code(t.female_ref) is null then 'no tag in the name'
    else 'tag reads clean but no such animal'
  end                                                as why
from cryo_txn t
left join ai_semen s on s.id = t.ai_semen_id
left join embryo   e on e.id = t.embryo_id
where t.female_id is null and t.female_ref is not null
group by t.female_ref
order by why, count(*) desc, t.female_ref;

comment on view v_cryo_unmapped is
  'Females named on the register but not on file. reads_as shows what the tag was taken to be, so a bad reading is visible rather than silent.';

notify pgrst, 'reload schema';
