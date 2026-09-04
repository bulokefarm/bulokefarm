-- 43. A calving puts the calf in the herd.
--
-- Recording a calving wrote one row against the cow and stopped. The
-- calf existed only as a line in her history: nothing in the herd,
-- nothing to tag, sex or weigh, and the note on the form said to add
-- it "later, once you've decided on a number". Later never came in
-- the same session, and a calf that is not on the list is a calf that
-- misses its first drench.
--
-- record_calving() writes the calf, its status, its paddock and the
-- calving in one transaction, the same shape as record_spray(). The
-- browser sends one statement at a time, so done as four inserts from
-- the app the calf could land without the calving or the calving
-- without the calf, and being told it failed after the calf was on
-- file gets the same calf entered twice.
--
-- The calf gets this year's letter and no number — the tag is decided
-- in the yard, not by the database — so it shows in the herd under
-- the year's drop with a placeholder, and stock_code stays null until
-- someone writes one. The unique index on (species, stock_code) only
-- constrains non-null codes, so twins are fine.
--
-- Re-runnable: create or replace throughout.

-- ------------------------------------------------------------
-- 1. Which letter is this year.
--
-- The NLIS year letters skip I and O: 24 letters, 2005 was A, 2026 is
-- X. The herd is the record, though — if the animals born in that year
-- already carry a letter, that letter wins over the arithmetic.
-- ------------------------------------------------------------

create or replace function year_letter(p_on date)
returns text language sql stable set search_path = public as $$
  with cycle as (
    select substr('ABCDEFGHJKLMNPQRSTUVWXYZ',
                  ((((extract(year from p_on)::int - 2005) % 24) + 24) % 24) + 1, 1) as letter)
  select coalesce(
    (select a.year_letter
       from animal a, cycle
      where a.dob is not null
        and extract(year from a.dob) = extract(year from p_on)
        and a.origin <> 'reference'
        and a.year_letter ~ '^[A-Z]$'
      group by a.year_letter, cycle.letter
      order by count(*) desc, (a.year_letter = cycle.letter) desc, a.year_letter
      limit 1),
    (select letter from cycle))
$$;

comment on function year_letter(date) is
  'The stock-code year letter for a date: what the herd already uses for that year, else the NLIS cycle (no I or O; 2005 = A).';

-- ------------------------------------------------------------
-- 2. The calving, and the calf it puts on the ground.
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

  -- The joining this answers: the open expectation for this dam
  -- nearest the date, the same rule calving_resolves applies. Naming
  -- the joining here means the joining register sees the result and
  -- the calf knows its sire.
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
            year_letter(p_calved_on), dam.id, exp.sire_id,
            coalesce(dam.property_id,
                     (select id from property where is_primary limit 1)))
    returning id into calf;

    -- A calf that died soon after is still a birth for the trading
    -- account: natural increase and a death, both on the one day.
    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    values (calf, p_calved_on,
            case when p_outcome = 'died' then 'died'::life_state_t else 'alive'::life_state_t end,
            case when dam.species = 'sheep' then 'lamb'::animal_class_t else 'calf'::animal_class_t end,
            'Born');

    -- Where the dam is now is where the calf is. A late entry after a
    -- move still can't put the calf in a paddock before it existed.
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

comment on function record_calving(uuid, date, text, boolean, text, sex_t) is
  'Record a calving and, unless stillborn, the calf: in the herd under this year''s letter with no number, in the dam''s paddock, sired per the open joining. Returns the calf id, null if stillborn.';

-- ------------------------------------------------------------
-- 3. A tag written later fills in the letter and number.
--
-- year_letter and herd_number are the parts of stock_code, and the
-- edit form only writes stock_code. The calf is created with a letter
-- and no code; when 'X 07' is typed the number has to follow, or the
-- drop grouping reads the calf as untagged forever. Only fires when
-- the code parses as letter + number, so a code written some other
-- way is kept as written.
-- ------------------------------------------------------------

create or replace function animal_code_parts()
returns trigger language plpgsql as $$
declare m text[];
begin
  m := regexp_match(coalesce(new.stock_code, ''), '^\s*([A-Za-z])\s*(\d{1,4})\s*$');
  if m is not null then
    new.year_letter := upper(m[1]);
    new.herd_number := m[2]::int;
  end if;
  return new;
end $$;

drop trigger if exists animal_code_parts on animal;
create trigger animal_code_parts
  before insert or update of stock_code on animal
  for each row execute function animal_code_parts();

-- ------------------------------------------------------------
-- 4. Verification, once applied:
--
--   select year_letter(farm_today());                -- 'X' in 2026
--   select record_calving('<dam uuid>', farm_today());
--   select stock_code, year_letter, class, paddock_name, dam_code, sire_name
--     from v_animal_current where dam_id = '<dam uuid>' and stock_code is null;
--   select * from expected_calving where dam_id = '<dam uuid>';  -- resolved
-- ------------------------------------------------------------
