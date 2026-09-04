-- 46. A sheep's year letter is its tag colour.
--
-- Cattle stock codes carry the NLIS year letter — X for 2026. Sheep
-- tags are coloured on the NLIS eight-year cycle, and the code on the
-- sheet starts with the colour: O 12 is a 2026 lamb, orange tag. The
-- two mobs run two alphabets, and year_letter() (43) only knew one, so
-- a lamb recorded today was put on the ground as X ?.
--
--   2024 B black      2028 P purple
--   2025 W white      2029 Y yellow
--   2026 O orange     2030 R red
--   2027 G light green   2031 S sky blue
--
-- year_letter() gains a species. For cattle the herd is still the
-- record — the letter the cattle born that year actually carry wins
-- over the arithmetic — but only animals with a tag are counted now.
-- Untagged placeholders are the output of this function, not evidence,
-- and counting them would have let today's X ? lambs vote for X. For
-- sheep the colour cycle is the rule as stated, and nothing votes: a
-- tag written against the cycle is a tag to correct, not a precedent.
--
-- Adding an argument makes a second function, and a one-argument call
-- would then match both. The old form is dropped first; record_calving
-- and record_drop are the only callers and are redefined here to pass
-- the species.
--
-- Re-runnable: drop if exists, create or replace, and a repair keyed
-- on what is wrong rather than on what a previous run wrote.

drop function if exists year_letter(date);

create or replace function year_letter(p_on date, p_species species_t default 'cattle')
returns text language sql stable set search_path = public as $$
  with cycle as (
    select case when p_species = 'sheep'
      then substr('BWOGPYRS', ((((extract(year from p_on)::int - 2024) % 8) + 8) % 8) + 1, 1)
      else substr('ABCDEFGHJKLMNPQRSTUVWXYZ',
                  ((((extract(year from p_on)::int - 2005) % 24) + 24) % 24) + 1, 1)
      end as letter)
  select coalesce(
    (select a.year_letter
       from animal a, cycle
      where a.dob is not null
        and extract(year from a.dob) = extract(year from p_on)
        and p_species = 'cattle'
        and a.species = p_species
        and a.origin <> 'reference'
        and a.stock_code is not null
        and a.year_letter ~ '^[A-Z]$'
      group by a.year_letter, cycle.letter
      order by count(*) desc, (a.year_letter = cycle.letter) desc, a.year_letter
      limit 1),
    (select letter from cycle))
$$;

comment on function year_letter(date, species_t) is
  'The stock-code year letter for a date and species. Cattle: what tagged cattle born that year already carry, else the NLIS letter cycle (no I or O; 2005 = A). Sheep: the tag-colour initial, B W O G P Y R S from 2024, always.';

-- ------------------------------------------------------------
-- 1. record_calving, as in 43, with the dam's species passed through.
-- ------------------------------------------------------------

create or replace function record_calving(
    p_dam_id    uuid,
    p_calved_on date,
    p_outcome   text    default 'live',
    p_assisted  boolean default null,
    p_notes     text    default null,
    p_sex       sex_t   default 'unknown')
returns uuid language plpgsql security invoker set search_path = public as $$
declare
  dam   animal%rowtype;
  exp   expected_calving%rowtype;
  stay  paddock_stay%rowtype;
  calf  uuid;
begin
  select * into dam from animal where id = p_dam_id;
  if not found then
    raise exception 'No such animal';
  end if;
  if dam.origin = 'reference' then
    raise exception '% was never on the property', coalesce(dam.stock_code, dam.name, 'That animal');
  end if;
  if p_calved_on is null then
    raise exception 'A calving needs a date';
  end if;
  if p_outcome is null or p_outcome not in ('live', 'stillborn', 'died') then
    raise exception 'Outcome must be live, stillborn or died';
  end if;

  select e.* into exp
    from expected_calving e
   where e.dam_id = dam.id
     and e.resolved_calving_id is null
     and (e.due_on is null or abs(p_calved_on - e.due_on) <= 60)
   order by abs(coalesce(e.due_on, p_calved_on) - p_calved_on)
   limit 1;

  if p_outcome <> 'stillborn' then
    insert into animal (species, origin, sex, dob, year_letter,
                        dam_id, sire_id, property_id)
    values (dam.species, 'bred', coalesce(p_sex, 'unknown'), p_calved_on,
            year_letter(p_calved_on, dam.species), dam.id, exp.sire_id,
            coalesce(dam.property_id,
                     (select id from property where is_primary limit 1)))
    returning id into calf;

    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    values (calf, p_calved_on,
            case when p_outcome = 'died' then 'died'::life_state_t else 'alive'::life_state_t end,
            case when dam.species = 'sheep' then 'lamb'::animal_class_t else 'calf'::animal_class_t end,
            'Born');

    if p_outcome = 'live' then
      select * into stay from paddock_stay
       where animal_id = dam.id and moved_out is null
       order by moved_in desc limit 1;
      if found then
        insert into paddock_stay (animal_id, paddock_id, moved_in, reason)
        values (calf, stay.paddock_id, greatest(p_calved_on, stay.moved_in),
                'Born, with ' || coalesce(dam.stock_code, dam.name, 'its dam'));
      end if;
    end if;
  end if;

  insert into calving (joining_id, dam_id, calved_on, calf_id, assisted, outcome, notes)
  values (exp.joining_id, dam.id, p_calved_on, calf, p_assisted, p_outcome,
          nullif(trim(p_notes), ''));

  return calf;
end $$;

-- ------------------------------------------------------------
-- 2. record_drop, as in 44, with the species passed through.
-- ------------------------------------------------------------

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
    values (p_species, 'bred', coalesce(p_sex, 'unknown'), p_on, year_letter(p_on, p_species),
            p_sire_id, owner_pic, nullif(trim(p_notes), ''))
    returning id into one;

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

-- ------------------------------------------------------------
-- 3. The lambs already on the ground under the wrong letter.
--
-- Only placeholders: an animal with a tag has the letter its tag
-- carries, whatever this function thinks. Keyed on the letter being
-- wrong, so a second run finds nothing to do.
-- ------------------------------------------------------------

update animal a
   set year_letter = year_letter(a.dob, a.species)
 where a.species = 'sheep'
   and a.stock_code is null
   and a.origin = 'bred'
   and a.dob is not null
   and a.year_letter is distinct from year_letter(a.dob, a.species);

notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select year_letter(farm_today(), 'sheep'), year_letter(farm_today(), 'cattle');  -- O, X
--   select year_letter, count(*) from animal
--    where species = 'sheep' and stock_code is null group by 1;                        -- O only
-- ------------------------------------------------------------
