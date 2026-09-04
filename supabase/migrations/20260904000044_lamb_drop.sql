-- 44. A lamb on the ground, ewe not known.
--
-- Sheep are run as mobs. The rams go out to a paddock of ewes, and at
-- lambing what is seen is a lamb in the back gully, not which ewe it
-- came from. record_calving() (43) wants a dam, so it can't take that
-- record, and a lamb that can't be recorded is a lamb that isn't in
-- the herd for marking.
--
-- record_drop() records what is actually known: the paddock, the day,
-- how many, the ram that was out with that mob, and their sex if it
-- was checked. Each lamb goes into the herd under this year's letter
-- with no number (the same placeholder as 43), classed as a lamb, in
-- that paddock, sired by the ram, dam null. Numbers go on at marking
-- through the app's "Tag the drop" screen, and animal_code_parts (43)
-- fills the letter and number in from the tag.
--
-- No calving row is written: calving.dam_id is not null, and a row
-- naming no ewe would say nothing the animal row does not. Natural
-- increase in the trading account is counted off origin = 'bred' and
-- the date of birth, so the lambs are in the account regardless.
--
-- The species is a parameter so a calf seen in a paddock of cows can
-- be recorded the same way; the default is sheep because that is the
-- mob that needs it.
--
-- Re-runnable: create or replace throughout.

create or replace function record_drop(
    p_paddock_id uuid,
    p_on         date,
    p_species    species_t default 'sheep',
    p_count      int       default 1,
    p_sire_id    uuid      default null,
    p_sex        sex_t     default 'unknown',
    p_outcome    text      default 'live',
    p_notes      text      default null)
returns uuid[] language plpgsql security invoker set search_path = public as $$
declare
  pk        paddock%rowtype;
  sire      animal%rowtype;
  owner_pic uuid;
  ids       uuid[] := '{}';
  one       uuid;
  i         int;
begin
  select * into pk from paddock where id = p_paddock_id;
  if not found then
    raise exception 'No such paddock';
  end if;
  if pk.retired_on is not null then
    raise exception '% is a retired paddock', pk.name;
  end if;
  if p_on is null then
    raise exception 'A birth needs a date';
  end if;
  if p_count is null or p_count < 1 or p_count > 50 then
    raise exception 'How many: between 1 and 50';
  end if;
  if p_outcome is null or p_outcome not in ('live', 'died') then
    raise exception 'Outcome must be live or died';
  end if;
  if p_sire_id is not null then
    select * into sire from animal where id = p_sire_id;
    if not found then
      raise exception 'No such sire';
    end if;
    if sire.sex = 'female' then
      raise exception '% is a female', coalesce(sire.stock_code, sire.name, 'That animal');
    end if;
    if sire.species <> p_species then
      raise exception '% is not a % sire', coalesce(sire.stock_code, sire.name, 'That animal'), p_species;
    end if;
  end if;

  -- Whose they are. PIC is ownership, not location, so it comes from
  -- the mob standing in the paddock, not from the paddock's own PIC.
  select a.property_id into owner_pic
    from v_animal_current a
   where a.paddock_id = pk.id
     and a.species = p_species
     and (a.life_state is null or a.life_state = 'alive')
     and a.property_id is not null
   group by a.property_id
   order by count(*) desc
   limit 1;
  if owner_pic is null then
    select id into owner_pic from property where is_primary limit 1;
  end if;
  if owner_pic is null then
    select id into owner_pic from property order by pic limit 1;
  end if;

  for i in 1..p_count loop
    insert into animal (species, origin, sex, dob, year_letter, sire_id, property_id, notes)
    values (p_species, 'bred', coalesce(p_sex, 'unknown'), p_on, year_letter(p_on),
            p_sire_id, owner_pic, nullif(trim(p_notes), ''))
    returning id into one;

    -- A lamb found dead is still a birth for the trading account:
    -- natural increase and a death, both on the one day.
    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    values (one, p_on,
            case when p_outcome = 'died' then 'died'::life_state_t else 'alive'::life_state_t end,
            case when p_species = 'sheep' then 'lamb'::animal_class_t else 'calf'::animal_class_t end,
            case when p_species = 'sheep' then 'Born, ewe not known' else 'Born, cow not known' end);

    if p_outcome = 'live' then
      insert into paddock_stay (animal_id, paddock_id, moved_in, reason)
      values (one, pk.id, p_on, 'Born there');
    end if;

    ids := ids || one;
  end loop;

  return ids;
end $$;

comment on function record_drop(uuid, date, species_t, int, uuid, sex_t, text, text) is
  'Young seen in a paddock with the dam not known: one animal each, this year''s letter and no number, classed lamb or calf, in that paddock, sired as given. Returns their ids.';

-- ------------------------------------------------------------
-- Verification, once applied:
--
--   select record_drop('<paddock uuid>', farm_today(), 'sheep', 3, '<ram uuid>');
--   select year_letter, class, paddock_name, sire_name, dob
--     from v_animal_current where stock_code is null and species = 'sheep';
-- ------------------------------------------------------------
