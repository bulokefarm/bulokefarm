-- ============================================================
-- 59. Bringing stock on.
--
-- Stock could leave the place through the app and could be born on
-- it, but could not arrive. The nineteen purchased animals on file
-- all came in through the spreadsheet import; nothing on any page
-- created an animal that was not a calf or a lamb. The database had
-- been ready for it since 09 — consignment has carried a direction,
-- in or out, from the start — and the trading account has counted
-- purchases from the beginning. Only the way in was missing.
--
-- receive_stock() is the opposite of consign_animals(), in one
-- transaction, the same shape as record_calving() and record_drop():
-- the inward consignment, each animal, its status, its link to the
-- consignment and its paddock all land, or none do.
--
-- By tag or by head count. A mob of sixty wethers off a truck has
-- no tags worth typing, so they go in the way lambs do: no stock
-- code, numbered later through Tag the drop. With a birth date they
-- take that year's letter; without one they have none, because
-- guessing a letter would say something the record does not know.
--
-- Two ways in:
--   purchased  origin purchased, purchased_on the day they arrived,
--              the vendor's PIC in the address book (added if new),
--              an inward consignment for LPA 5A. They count as
--              purchases in the year of that date, whenever it was,
--              so stock bought years ago and never recorded can be
--              entered truthfully.
--   bred       bred here and not yet on file. No consignment. They
--              enter on their birth date if it is known, so natural
--              increase lands in the year they were born.
--
-- Whose they are is one of this farm's own PICs — the primary unless
-- named — because with two PICs on one farm that is a decision, not a
-- default, at the moment of purchase.
--
-- Safe to run more than once.
-- ============================================================

create or replace function receive_stock(
  p_on              date,
  p_species         species_t,
  p_how             text             default 'purchased',
  p_class           animal_class_t   default null,
  p_sex             sex_t            default 'unknown',
  p_tags            text[]           default null,
  p_count           integer          default null,
  p_paddock_id      uuid             default null,
  p_property_id     uuid             default null,
  p_vendor_name     text             default null,
  p_vendor_pic      text             default null,
  p_nvd_kind        nvd_kind_t       default null,
  p_nvd_serial      text             default null,
  p_breed           text             default null,
  p_born            date             default null,
  p_notes           text             default null,
  p_ignore_withhold boolean          default false
) returns uuid[]
language plpgsql set search_path = public as $$
declare
  fid     uuid := current_farm();
  bought  boolean := (p_how = 'purchased');
  tags    text[];
  t       text;
  m       text[];
  n       int;
  dup     text;
  own     property%rowtype;
  pk      paddock%rowtype;
  vendor  uuid;
  vpic    text := nullif(upper(regexp_replace(coalesce(p_vendor_pic, ''), '\s', '', 'g')), '');
  vname   text := nullif(trim(coalesce(p_vendor_name, '')), '');
  nvd     text := nullif(upper(trim(coalesce(p_nvd_serial, ''))), '');
  note    text := nullif(trim(coalesce(p_notes, '')), '');
  cons    uuid;
  eff     date;
  letter  text;
  reason  text;
  ids     uuid[] := '{}';
  one     uuid;
  i       int;
begin
  if fid is null then
    raise exception 'No farm for this session';
  end if;
  if p_on is null then
    raise exception 'It needs a date';
  end if;
  if p_on > farm_today() then
    raise exception 'That date has not happened yet';
  end if;
  if p_how is null or p_how not in ('purchased', 'bred') then
    raise exception 'Bought in, or bred here';
  end if;
  if p_born is not null and p_born > p_on then
    raise exception 'Born after they arrived';
  end if;

  -- Tags as the herd writes them: a letter or two, a space, two
  -- digits at least. Anything else is kept as it was typed — a
  -- vendor's tag is whatever the vendor made it.
  if p_tags is not null then
    foreach t in array p_tags loop
      t := trim(coalesce(t, ''));
      continue when t = '';
      m := regexp_match(t, '^([A-Za-z]{1,2})\s*0*(\d{1,4})$');
      if m is not null then
        t := upper(m[1]) || ' ' || case when length(m[2]) >= 2 then m[2] else '0' || m[2] end;
      else
        t := upper(t);
      end if;
      if t = any(tags) then
        raise exception '% is on the list twice', t;
      end if;
      tags := tags || t;
    end loop;
  end if;

  n := coalesce(array_length(tags, 1), 0);
  if n = 0 then
    if p_count is null or p_count < 1 or p_count > 500 then
      raise exception 'How many: between 1 and 500, or list their tags';
    end if;
    n := p_count;
  elsif n > 500 then
    raise exception 'That is % tags; 500 at a time', n;
  else
    select string_agg(a.stock_code, ', ' order by a.stock_code) into dup
      from animal a
     where a.farm_id = fid and a.species = p_species
       and a.origin <> 'reference' and a.stock_code = any(tags);
    if dup is not null then
      raise exception 'Already on file: %', dup;
    end if;
  end if;

  -- Whose they are.
  if p_property_id is not null then
    select * into own from property
     where id = p_property_id and farm_id = fid and is_own;
    if not found then
      raise exception 'That PIC is not one of this farm''s own';
    end if;
  else
    select * into own from property
     where farm_id = fid and is_own
     order by is_primary desc, pic limit 1;
    if not found then
      raise exception 'This farm has no PIC of its own yet';
    end if;
  end if;

  if p_paddock_id is not null then
    select * into pk from paddock where id = p_paddock_id and farm_id = fid;
    if not found then
      raise exception 'No such paddock';
    end if;
    if pk.retired_on is not null then
      raise exception '% is a retired paddock', pk.name;
    end if;
  end if;

  -- Who from. The address book gains the vendor if it is new.
  if bought and vpic is not null then
    if vpic !~ '^[A-Z0-9]{8}$' then
      raise exception 'A PIC is eight letters and numbers: %', vpic;
    end if;
    if vpic = own.pic then
      raise exception 'Bought from % and owned by % is the same PIC', vpic, own.pic;
    end if;
    select id into vendor from property where farm_id = fid and pic = vpic;
    if vendor is null then
      insert into property (farm_id, pic, is_own, name)
      values (fid, vpic, false, vname)
      returning id into vendor;
    end if;
  end if;

  -- The movement onto the place: LPA 5A.
  if bought then
    begin
      insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
                               destination_kind, destination, destination_pic,
                               counterparty, head_declared, notes, declared_on)
      values ('in', p_on, p_nvd_kind, nvd, 'property',
              'From ' || coalesce(vname, vpic, 'vendor not recorded'), vpic,
              vname, n, note, p_on)
      returning id into cons;
    exception when unique_violation then
      raise exception 'NVD % is already on another consignment', nvd;
    end;
  end if;

  eff    := case when bought then p_on else coalesce(p_born, p_on) end;
  letter := case when p_born is not null then year_letter(p_born, p_species) end;
  reason := case when bought
                 then concat_ws(' ', 'Bought in',
                                case when coalesce(vname, vpic) is not null
                                     then 'from ' || coalesce(vname, vpic) end,
                                case when nvd is not null then '· NVD ' || nvd end)
                 else 'Bred here' end;

  for i in 1..n loop
    insert into animal (species, origin, sex, dob, breed, stock_code, year_letter,
                        property_id, origin_property_id, purchased_on, purchase_note, notes)
    values (p_species,
            case when bought then 'purchased'::origin_t else 'bred'::origin_t end,
            coalesce(p_sex, 'unknown'), p_born, nullif(trim(coalesce(p_breed, '')), ''),
            case when tags is not null then tags[i] end,
            case when tags is null then letter end,
            own.id,
            case when bought then vendor end,
            case when bought then p_on end,
            case when bought then concat_ws(' · ', case when nvd is not null then 'NVD ' || nvd end, note) end,
            case when not bought then note end)
    returning id into one;

    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    values (one, eff, 'alive', p_class, reason);

    ids := ids || one;
  end loop;

  if cons is not null then
    perform consign_animals(cons, ids);
  end if;

  -- Last, because a paddock inside a spray withhold refuses, and the
  -- refusal has to take everything above with it.
  if p_paddock_id is not null then
    perform move_animals(ids, p_paddock_id, p_on, reason, p_ignore_withhold);
  end if;

  return ids;
end $$;

revoke execute on function receive_stock(date, species_t, text, animal_class_t, sex_t, text[], integer,
  uuid, uuid, text, text, nvd_kind_t, text, text, date, text, boolean) from public, anon;
grant  execute on function receive_stock(date, species_t, text, animal_class_t, sex_t, text[], integer,
  uuid, uuid, text, text, nvd_kind_t, text, text, date, text, boolean) to authenticated;

comment on function receive_stock is
  'Stock onto the place, bought in or bred here, by tag or head count: inward consignment, animals, status and paddock in one transaction.';

notify pgrst, 'reload schema';
