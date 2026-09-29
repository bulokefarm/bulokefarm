--
-- PostgreSQL database dump
--

\restrict Qqwfq3B7RJ6PK1qJCGEsxUETcBhqRyguLYT3kzTe8PKFVmuVnivTpSwfSxihMKf

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.11 (Ubuntu 17.11-1.pgdg24.04+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: animal_class_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.animal_class_t AS ENUM (
    'calf',
    'weaner',
    'yearling',
    'harvest',
    'breeder',
    'protector',
    'bull',
    'lamb',
    'ram'
);


--
-- Name: consign_dir_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.consign_dir_t AS ENUM (
    'out',
    'in'
);


--
-- Name: cryo_kind_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cryo_kind_t AS ENUM (
    'received',
    'used',
    'discarded',
    'sent_out',
    'returned',
    'stocktake'
);


--
-- Name: cycle_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cycle_t AS ENUM (
    'autumn',
    'spring'
);


--
-- Name: destination_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.destination_t AS ENUM (
    'saleyard',
    'abattoir',
    'property',
    'agent',
    'other'
);


--
-- Name: farm_role_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.farm_role_t AS ENUM (
    'owner',
    'manager',
    'viewer'
);


--
-- Name: joining_method_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.joining_method_t AS ENUM (
    'natural',
    'ai'
);


--
-- Name: joining_outcome_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.joining_outcome_t AS ENUM (
    'unknown',
    'in_calf',
    'empty',
    'calved',
    'aborted',
    'lost',
    'closed'
);


--
-- Name: life_state_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.life_state_t AS ENUM (
    'alive',
    'sold',
    'died',
    'slaughtered'
);


--
-- Name: nvd_kind_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nvd_kind_t AS ENUM (
    'book',
    'envd'
);


--
-- Name: origin_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.origin_t AS ENUM (
    'bred',
    'purchased',
    'reference'
);


--
-- Name: paddock_change_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.paddock_change_t AS ENUM (
    'split',
    'merge',
    'reshape',
    'rename'
);


--
-- Name: sex_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sex_t AS ENUM (
    'female',
    'male',
    'steer',
    'unknown',
    'wether'
);


--
-- Name: shearing_kind_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.shearing_kind_t AS ENUM (
    'shearing',
    'crutching',
    'clip',
    'marking'
);


--
-- Name: species_t; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.species_t AS ENUM (
    'cattle',
    'sheep'
);


--
-- Name: animal_code_parts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.animal_code_parts() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $_$
declare m text[];
begin
  m := regexp_match(coalesce(new.stock_code, ''), '^\s*([A-Za-z]{1,2})\s*(\d{1,4})\s*$');
  if m is not null then
    new.year_letter := upper(m[1]);
    new.herd_number := m[2]::int;
  end if;
  return new;
end $_$;


--
-- Name: beat(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.beat() RETURNS timestamp with time zone
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  update heartbeat set beat_at = now() where ok returning beat_at;
$$;


--
-- Name: can_read(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.can_read() RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
  select my_role() is not null
$$;


--
-- Name: can_write(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.can_write() RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
  select my_role() in ('owner', 'manager')
$$;


--
-- Name: farm_today(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.farm_today() RETURNS date
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
  select (current_timestamp at time zone 'Australia/Melbourne')::date
$$;


--
-- Name: FUNCTION farm_today(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.farm_today() IS 'Today at the farm. Correct regardless of session timezone; prefer over current_date in new views.';


--
-- Name: close_expectations(uuid[], date, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.close_expectations(p_ids uuid[], p_on date DEFAULT public.farm_today(), p_note text DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  n       int;
  orphans text;
  stamp   text;
begin
  if p_ids is null or array_length(p_ids, 1) is null then
    raise exception 'Nothing chosen to close';
  end if;

  select string_agg(coalesce(a.stock_code, a.name, 'an unnamed dam'), ', ' order by a.stock_code)
    into orphans
    from expected_calving e
    join animal a on a.id = e.dam_id
   where e.id = any(p_ids)
     and e.resolved_calving_id is null
     and e.joining_id is null;
  if orphans is not null then
    raise exception 'No joining on file behind the expectation for %. Record the joining, or the calving, and close again.', orphans;
  end if;

  stamp := 'Closed ' || to_char(coalesce(p_on, farm_today()), 'DD Mon YYYY')
        || ': ' || coalesce(nullif(trim(p_note), ''), 'season over, result not recorded per dam');

  update joining j
     set outcome = 'closed',
         notes   = concat_ws(E'\n', nullif(trim(j.notes), ''), stamp)
    from expected_calving e
   where e.id = any(p_ids)
     and e.resolved_calving_id is null
     and e.joining_id = j.id
     and j.outcome not in ('empty','aborted','lost','calved','closed');

  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION close_expectations(p_ids uuid[], p_on date, p_note text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.close_expectations(p_ids uuid[], p_on date, p_note text) IS 'Season over for these expectations: the joining behind each is marked closed (result not recorded per dam), with the note, and the expectation comes off Due. Returns how many joinings were closed.';


--
-- Name: close_feed_runs_on_exhaustion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.close_feed_runs_on_exhaustion() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
begin
  -- Deliberately does nothing. An empty store does not take the
  -- cattle off feed; only feed_run_end() does that. Kept as a no-op
  -- so databases that already ran 034 lose the behaviour on upgrade
  -- rather than keeping a stale definition.
  return null;
end $$;


--
-- Name: consign_animals(uuid, uuid[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.consign_animals(p_consignment uuid, p_animal_ids uuid[], p_override_whp boolean DEFAULT false) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  c        consignment%rowtype;
  blocked  text;
  new_state life_state_t;
  n int;
begin
  select * into c from consignment where id = p_consignment;
  if not found then raise exception 'Consignment not found'; end if;

  if c.direction = 'out' and not p_override_whp then
    select string_agg(stock_code, ', ' order by stock_code) into blocked
      from v_animal_clearance
     where animal_id = any(p_animal_ids) and clear_domestic > c.consigned_on;
    if blocked is not null then
      raise exception 'Still inside a withholding period: %', blocked;
    end if;
  end if;

  insert into consignment_animal (consignment_id, animal_id)
  select p_consignment, unnest(p_animal_ids)
  on conflict do nothing;
  get diagnostics n = row_count;

  if c.direction = 'out' then
    new_state := case when c.destination_kind = 'abattoir'
                      then 'slaughtered'::life_state_t else 'sold'::life_state_t end;

    insert into animal_status (animal_id, effective_on, life_state, class, reason)
    select unnest(p_animal_ids), c.consigned_on, new_state, null,
           concat_ws(' ', 'Consigned to', c.destination,
                     case when c.nvd_serial is not null then '· NVD '||c.nvd_serial end)
    on conflict (animal_id, effective_on) do update
      set life_state = excluded.life_state, reason = excluded.reason;

    update paddock_stay set moved_out = c.consigned_on
     where animal_id = any(p_animal_ids) and moved_out is null;
  end if;

  update consignment set head_declared = (
    select count(*) from consignment_animal where consignment_id = p_consignment)
   where id = p_consignment;

  return n;
end $$;


--
-- Name: cryo_ref_code(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cryo_ref_code(ref text) RETURNS text
    LANGUAGE sql IMMUTABLE
    SET search_path TO 'public'
    AS $_$
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
$_$;


--
-- Name: FUNCTION cryo_ref_code(ref text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cryo_ref_code(ref text) IS 'Pulls the stock code out of a written reference. Breed and herd prefixes are dropped; the trailing letter and number is the tag.';


--
-- Name: feed_line_changed(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_line_changed() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
begin
  perform feed_source_close_if_empty(
    coalesce(new.feed_source_id, old.feed_source_id));
  return null;
end $$;


--
-- Name: feed_qty_kg(numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_qty_kg(qty numeric, unit text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    SET search_path TO 'public'
    AS $$
  select case lower(coalesce(unit, ''))
           when 'kg'     then qty
           when 'kgs'    then qty
           when 't'      then qty * 1000
           when 'tonne'  then qty * 1000
           when 'tonnes' then qty * 1000
           when 'ton'    then qty * 1000
           else null
         end
$$;


--
-- Name: feed_resolve_refs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_resolve_refs() RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare n integer;
begin
  insert into feed_event_animal (feed_event_id, animal_id)
  select r.feed_event_id, a.id
    from feed_event_ref r
    join animal a
      on a.stock_code = r.stock_code
     and a.origin <> 'reference'
   on conflict do nothing;
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION feed_resolve_refs(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.feed_resolve_refs() IS 'Attaches paper-named animals to their feeding events as they appear in the herd. Run again after any herd import.';


--
-- Name: feed_run_end(uuid, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_run_end(p_source uuid, p_on date DEFAULT CURRENT_DATE) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare n integer;
begin
  update feed_event
     set ended_on = greatest(p_on, fed_on)
   where feed_source_id = p_source
     and ended_on is null;
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION feed_run_end(p_source uuid, p_on date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.feed_run_end(p_source uuid, p_on date) IS 'Takes the mob off a feed run on the given day. Called when the feeder is seen empty — never inferred.';


--
-- Name: feed_source_close_if_empty(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_source_close_if_empty(sid uuid) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  qty_in numeric;
  used   numeric;
  adj    numeric;
  asof   date;
begin
  if sid is null then return; end if;

  select quantity into qty_in
    from feed_source where id = sid and exhausted_on is null;
  if qty_in is null then return; end if;

  select coalesce(sum(qty), 0), max(fed_on) into used, asof
    from feed_event where feed_source_id = sid;
  select coalesce(sum(qty_delta), 0) into adj
    from feed_adjustment where feed_source_id = sid;

  if qty_in + adj - used <= 0 then
    update feed_source
       set exhausted_on = coalesce(asof, current_date)
     where id = sid and exhausted_on is null;
  end if;
end $$;


--
-- Name: feed_source_quantity_changed(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feed_source_quantity_changed() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
begin
  perform feed_source_close_if_empty(new.id);
  return null;
end $$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into farm_user (id, display_name, role, active)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), 'viewer', false);
  return new;
end $$;


--
-- Name: log_paddock_geometry(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_paddock_geometry() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
begin
  if old.geometry is distinct from new.geometry then
    insert into paddock_geometry_log (paddock_id, geometry, area_ha, valid_from)
    values (old.id, old.geometry, old.area_ha, old.created_at);
  end if;
  return new;
end $$;


--
-- Name: log_record_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_record_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  if tg_op = 'UPDATE' then
    -- Ignore no-op saves so the log stays readable.
    if to_jsonb(old) - 'created_at' = to_jsonb(new) - 'created_at' then
      return new;
    end if;
    insert into record_change_log (table_name, row_id, action, old_row, new_row)
    values (tg_table_name, old.id, 'update', to_jsonb(old), to_jsonb(new));
    return new;
  else
    insert into record_change_log (table_name, row_id, action, old_row)
    values (tg_table_name, old.id, 'delete', to_jsonb(old));
    return old;
  end if;
end $$;


--
-- Name: move_animals(uuid[], uuid, date, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.move_animals(p_animal_ids uuid[], p_paddock_id uuid, p_on date DEFAULT public.farm_today(), p_reason text DEFAULT NULL::text, p_ignore_withhold boolean DEFAULT false) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  n       int;
  blocked text;
begin
  blocked := paddock_graze_block(p_paddock_id, p_on);

  if blocked is not null and not p_ignore_withhold then
    raise exception 'Spray withholding period. %', blocked
      using errcode = 'BF001',
            hint    = 'Call again with p_ignore_withhold => true to move them anyway.';
  end if;

  -- An override is a decision, so it goes on the record next to the
  -- reason someone typed, not into a log nobody reads.
  if blocked is not null then
    p_reason := trim(both ' ' from coalesce(p_reason, '') ||
                     ' [moved inside spray withholding period]');
  end if;

  update paddock_stay set moved_out = p_on
   where animal_id = any(p_animal_ids) and moved_out is null and moved_in <= p_on;

  insert into paddock_stay (animal_id, paddock_id, moved_in, reason)
  select unnest(p_animal_ids), p_paddock_id, p_on, p_reason;

  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION move_animals(p_animal_ids uuid[], p_paddock_id uuid, p_on date, p_reason text, p_ignore_withhold boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.move_animals(p_animal_ids uuid[], p_paddock_id uuid, p_on date, p_reason text, p_ignore_withhold boolean) IS 'Move stock, closing the old stay. Refuses a paddock under a spray grazing withhold unless overridden.';


--
-- Name: my_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.my_role() RETURNS public.farm_role_t
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select role from farm_user where id = auth.uid() and active
$$;


--
-- Name: paddock_graze_block(uuid, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.paddock_graze_block(p_paddock_id uuid, p_on date DEFAULT public.farm_today()) RETURNS text
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
  select case when count(*) = 0 then null else
    -- A mix can carry a known withhold AND a product nobody wrote one
    -- down for. Both are true, so both are said: the known date is not
    -- a clearance while an unrecorded product sits beside it.
    format('%s was sprayed with %s on %s.%s%s',
      max(p.name),
      string_agg(distinct sp.product_name, ', '),
      to_char(max(se.applied_on), 'DD Mon YYYY'),
      case when max(se.applied_on + sp.graze_withhold_days) is not null
           then ' Grazing is withheld until '
                || to_char(max(se.applied_on + sp.graze_withhold_days), 'DD Mon YYYY') || '.'
           else '' end,
      case when bool_or(sp.graze_withhold_days is null)
           then ' One of the products has no grazing withholding period recorded.'
           else '' end)
  end
  from spray_event   se
  join spray_paddock pk on pk.spray_event_id = se.id
  join spray_product sp on sp.spray_event_id = se.id
  join paddock       p  on p.id = pk.paddock_id
  where pk.paddock_id = p_paddock_id
    and se.applied_on <= p_on
    and ( se.applied_on + sp.graze_withhold_days > p_on
       or (sp.graze_withhold_days is null and se.applied_on > p_on - 60) )
$$;


--
-- Name: FUNCTION paddock_graze_block(p_paddock_id uuid, p_on date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.paddock_graze_block(p_paddock_id uuid, p_on date) IS 'Why stock should not go into this paddock on this date, or NULL if they can.';


--
-- Name: plan_fulfilled(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.plan_fulfilled() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update planned_joining
     set joining_id = new.id
   where dam_id = new.dam_id
     and season = new.season
     and joining_id is null
     and cancelled_on is null;
  return new;
end $$;


--
-- Name: record_calving(uuid, date, text, boolean, text, public.sex_t); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_calving(p_dam_id uuid, p_calved_on date, p_outcome text DEFAULT 'live'::text, p_assisted boolean DEFAULT NULL::boolean, p_notes text DEFAULT NULL::text, p_sex public.sex_t DEFAULT 'unknown'::public.sex_t) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
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


--
-- Name: FUNCTION record_calving(p_dam_id uuid, p_calved_on date, p_outcome text, p_assisted boolean, p_notes text, p_sex public.sex_t); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.record_calving(p_dam_id uuid, p_calved_on date, p_outcome text, p_assisted boolean, p_notes text, p_sex public.sex_t) IS 'Record a calving and, unless stillborn, the calf: in the herd under this year''s letter with no number, in the dam''s paddock, sired per the open joining. Returns the calf id, null if stillborn.';


--
-- Name: record_drop(uuid, date, public.species_t, integer, uuid, public.sex_t, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_drop(p_paddock_id uuid, p_on date, p_species public.species_t DEFAULT 'sheep'::public.species_t, p_count integer DEFAULT 1, p_sire_id uuid DEFAULT NULL::uuid, p_sex public.sex_t DEFAULT 'unknown'::public.sex_t, p_outcome text DEFAULT 'live'::text, p_notes text DEFAULT NULL::text) RETURNS uuid[]
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
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


--
-- Name: FUNCTION record_drop(p_paddock_id uuid, p_on date, p_species public.species_t, p_count integer, p_sire_id uuid, p_sex public.sex_t, p_outcome text, p_notes text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.record_drop(p_paddock_id uuid, p_on date, p_species public.species_t, p_count integer, p_sire_id uuid, p_sex public.sex_t, p_outcome text, p_notes text) IS 'Young seen in a paddock with the dam not known: one animal each, this year''s letter and no number, classed lamb or calf, in that paddock, sired as given. Returns their ids.';


--
-- Name: record_spray(date, jsonb, jsonb, text, numeric, text, text, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_spray(p_applied_on date, p_paddocks jsonb, p_products jsonb DEFAULT '[]'::jsonb, p_crop_treated text DEFAULT NULL::text, p_water_rate_l_ha numeric DEFAULT NULL::numeric, p_method text DEFAULT NULL::text, p_wind_direction text DEFAULT NULL::text, p_wind_speed_kmh numeric DEFAULT NULL::numeric, p_applied_by text DEFAULT NULL::text, p_applied_by_contact text DEFAULT NULL::text, p_notes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  ev uuid;
  n  int;
begin
  if p_paddocks is null or jsonb_array_length(p_paddocks) = 0 then
    raise exception 'A spray record must name at least one paddock.'
      using errcode = 'BF002';
  end if;

  insert into spray_event (applied_on, crop_treated, water_rate_l_ha, method,
                           wind_direction, wind_speed_kmh,
                           applied_by, applied_by_contact, notes)
  values (p_applied_on, p_crop_treated, p_water_rate_l_ha, p_method,
          p_wind_direction, p_wind_speed_kmh,
          p_applied_by, p_applied_by_contact, p_notes)
  returning id into ev;

  -- An area not given falls back to the paddock's mapped hectares,
  -- which is the whole-paddock case and the common one. Nothing is
  -- invented: if the paddock has no boundary yet it stays null and
  -- the report says so.
  insert into spray_paddock (spray_event_id, paddock_id, area_ha, location_note)
  select ev, x.paddock_id, coalesce(x.area_ha, p.area_ha), x.location_note
    from jsonb_to_recordset(p_paddocks)
           as x(paddock_id uuid, area_ha numeric, location_note text)
    join paddock p on p.id = x.paddock_id
  on conflict (spray_event_id, paddock_id) do nothing;

  get diagnostics n = row_count;

  -- The join above silently writes nothing for an id that is not a
  -- paddock, so the length check at the top can pass and still leave
  -- the pass covering nowhere. Count what actually landed. Raising
  -- rolls the whole function back, event included.
  if n = 0 then
    raise exception 'None of those paddocks exist.'
      using errcode = 'BF002';
  end if;

  if coalesce(jsonb_array_length(p_products), 0) > 0 then
    insert into spray_product (spray_event_id, product_name, active_ingredient,
                               chemical_rate, batch_number, graze_withhold_days,
                               harvest_withhold_days, esi_days, notes)
    select ev, y.product_name, y.active_ingredient, y.chemical_rate, y.batch_number,
           y.graze_withhold_days, y.harvest_withhold_days, y.esi_days, y.notes
      from jsonb_to_recordset(p_products)
             as y(product_name text, active_ingredient text, chemical_rate text,
                  batch_number text, graze_withhold_days int,
                  harvest_withhold_days int, esi_days int, notes text)
     where coalesce(trim(y.product_name), '') <> '';
  end if;

  return ev;
end $$;


--
-- Name: FUNCTION record_spray(p_applied_on date, p_paddocks jsonb, p_products jsonb, p_crop_treated text, p_water_rate_l_ha numeric, p_method text, p_wind_direction text, p_wind_speed_kmh numeric, p_applied_by text, p_applied_by_contact text, p_notes text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.record_spray(p_applied_on date, p_paddocks jsonb, p_products jsonb, p_crop_treated text, p_water_rate_l_ha numeric, p_method text, p_wind_direction text, p_wind_speed_kmh numeric, p_applied_by text, p_applied_by_contact text, p_notes text) IS 'Write one spray pass, its paddocks and its products in a single transaction.';


--
-- Name: refresh_expectation(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_expectation(p_dam uuid, p_season text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare best joining%rowtype;
begin
  if exists (select 1 from expected_calving
              where dam_id = p_dam and season = p_season
                and resolved_calving_id is not null) then
    delete from expected_calving
     where dam_id = p_dam and season = p_season and resolved_calving_id is null;
    return;
  end if;

  select j.* into best
    from joining j
   where j.dam_id = p_dam and j.season = p_season
     and j.due_on is not null
     and j.outcome not in ('empty','aborted','lost','calved','closed')
   order by (j.outcome = 'in_calf') desc,
            j.attempt desc,
            j.joined_on desc nulls last
   limit 1;

  delete from expected_calving
   where dam_id = p_dam and season = p_season and resolved_calving_id is null
     and (best.id is null or joining_id is distinct from best.id);

  if best.id is not null then
    insert into expected_calving (joining_id, dam_id, sire_id, season, cycle, due_on)
    values (best.id, best.dam_id, best.sire_id, best.season, best.cycle, best.due_on)
    on conflict (joining_id) do update
       set dam_id  = excluded.dam_id,
           sire_id = excluded.sire_id,
           season  = excluded.season,
           cycle   = excluded.cycle,
           due_on  = excluded.due_on;
  end if;
end $$;


--
-- Name: resolve_expected_calving(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.resolve_expected_calving() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare target uuid;
begin
  select e.id into target
    from expected_calving e
   where e.resolved_calving_id is null
     and (
       (new.joining_id is not null and e.joining_id = new.joining_id)
       or (new.joining_id is null
           and e.dam_id = new.dam_id
           and e.due_on is not null
           and abs(new.calved_on - e.due_on) <= 60)
     )
   order by abs(coalesce(e.due_on, new.calved_on) - new.calved_on)
   limit 1;

  if target is not null then
    update expected_calving set resolved_calving_id = new.id where id = target;
  end if;
  return new;
end $$;


--
-- Name: rls_auto_enable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rls_auto_enable() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


--
-- Name: set_animal_status(uuid[], public.life_state_t, public.animal_class_t, date, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_animal_status(p_animal_ids uuid[], p_life_state public.life_state_t DEFAULT NULL::public.life_state_t, p_class public.animal_class_t DEFAULT NULL::public.animal_class_t, p_on date DEFAULT CURRENT_DATE, p_reason text DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare n int;
begin
  if p_life_state is null and p_class is null then
    raise exception 'Nothing to change';
  end if;

  insert into animal_status (animal_id, effective_on, life_state, class, reason)
  select a.id, p_on,
         coalesce(p_life_state, prev.life_state, 'alive'),
         coalesce(p_class, prev.class),
         p_reason
    from unnest(p_animal_ids) as a(id)
    left join lateral (
      select life_state, class from animal_status
       where animal_id = a.id and effective_on <= p_on
       order by effective_on desc limit 1) prev on true
  on conflict (animal_id, effective_on) do update
     set life_state = excluded.life_state,
         class      = excluded.class,
         reason     = coalesce(excluded.reason, animal_status.reason);

  get diagnostics n = row_count;

  -- Out of the herd is out of the paddock. Dated the same day, so the
  -- grazing history reads correctly rather than showing her there
  -- until somebody happened to notice.
  if p_life_state is not null and p_life_state <> 'alive' then
    update paddock_stay
       set moved_out = p_on
     where animal_id = any(p_animal_ids)
       and moved_out is null;
  end if;

  return n;
end $$;


--
-- Name: split_paddock(uuid, jsonb, integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.split_paddock(p_parent uuid, p_children jsonb, p_stock_to_index integer DEFAULT 0, p_on date DEFAULT CURRENT_DATE) RETURNS SETOF uuid
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
declare
  c          jsonb;
  new_id     uuid;
  ids        uuid[] := '{}';
  parent_prop uuid;
  movers     uuid[];
begin
  if jsonb_array_length(p_children) < 2 then
    raise exception 'A split needs at least two new paddocks';
  end if;

  select property_id into parent_prop from paddock where id = p_parent;
  if not found then raise exception 'Parent paddock not found'; end if;

  -- Retire the parent first so its name is free for reuse.
  update paddock set retired_on = p_on,
         retired_reason = coalesce(retired_reason, 'Subdivided')
   where id = p_parent and retired_on is null;

  for c in select * from jsonb_array_elements(p_children) loop
    insert into paddock (property_id, name, code, colour, geometry, area_ha, notes)
    values (parent_prop, c->>'name', c->>'code',
            coalesce(c->>'colour', '#4F7A1F'), c->'geometry',
            (c->>'area_ha')::numeric, c->>'notes')
    returning id into new_id;

    insert into paddock_lineage (parent_id, child_id, change, changed_on)
    values (p_parent, new_id, 'split', p_on);

    ids := ids || new_id;
  end loop;

  -- Carry any stock currently in the parent into the nominated child.
  if p_stock_to_index is not null and p_stock_to_index < array_length(ids,1) then
    select array_agg(animal_id) into movers
      from paddock_stay where paddock_id = p_parent and moved_out is null;
    if movers is not null then
      perform move_animals(movers, ids[p_stock_to_index + 1], p_on, 'Paddock subdivided');
    end if;
  end if;

  return query select unnest(ids);
end $$;


--
-- Name: sync_expected_calving(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_expected_calving() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  if tg_op = 'UPDATE' and (old.dam_id, old.season) is distinct from (new.dam_id, new.season) then
    perform refresh_expectation(old.dam_id, old.season);
  end if;
  perform refresh_expectation(new.dam_id, new.season);
  return new;
end $$;


--
-- Name: sync_expected_calving_del(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_expected_calving_del() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  perform refresh_expectation(old.dam_id, old.season);
  return old;
end $$;


--
-- Name: year_letter(date, public.species_t); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.year_letter(p_on date, p_species public.species_t DEFAULT 'cattle'::public.species_t) RETURNS text
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $_$
  with cycle as (
    select case when p_species = 'sheep'
      then (array['BK','W','O','G','P','Y','R','BU'])
             [((((extract(year from p_on)::int - 2024) % 8) + 8) % 8) + 1]
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
$_$;


--
-- Name: FUNCTION year_letter(p_on date, p_species public.species_t); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.year_letter(p_on date, p_species public.species_t) IS 'The stock-code year letter for a date and species. Cattle: what tagged cattle born that year already carry, else the NLIS letter cycle (no I or O; 2005 = A). Sheep: the tag colour, BK W O G P Y R BU from 2024, always.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_semen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_semen (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sire_id uuid,
    sire_name text NOT NULL,
    breed text,
    straw_code text,
    batch_code text,
    tank text,
    supplier text,
    collected_on date,
    straws_in integer,
    notes text,
    retired_on date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    location smallint,
    marking text,
    horn_status text,
    price_per_straw numeric(8,2),
    cost_inc_gst numeric(10,2),
    mark_colour text,
    straw_desc text,
    straw_size text,
    goblet text,
    CONSTRAINT ai_semen_location_check CHECK (((location >= 1) AND (location <= 6))),
    CONSTRAINT ai_semen_straw_size_check CHECK ((straw_size = ANY (ARRAY['mini'::text, 'maxi'::text]))),
    CONSTRAINT ai_semen_straws_in_check CHECK ((straws_in >= 0))
);


--
-- Name: TABLE ai_semen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ai_semen IS 'Straws on hand. Count remaining is derived from joinings, never stored.';


--
-- Name: COLUMN ai_semen.tank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.tank IS 'Which flask. Two on the place.';


--
-- Name: COLUMN ai_semen.straws_in; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.straws_in IS 'What was delivered. Not the count on hand — that is the sum of the ledger.';


--
-- Name: COLUMN ai_semen.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.location IS 'Canister position 1-6. A location holds straws from many bulls.';


--
-- Name: COLUMN ai_semen.marking; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.marking IS 'Column B verbatim. The source for the four fields below.';


--
-- Name: COLUMN ai_semen.mark_colour; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.mark_colour IS 'Cane marker — Yellow, Green, No Mrk.';


--
-- Name: COLUMN ai_semen.straw_desc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.straw_desc IS 'The straw as described — white strws, red straws, White strw-green crimp top.';


--
-- Name: COLUMN ai_semen.straw_size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.straw_size IS 'mini or maxi.';


--
-- Name: COLUMN ai_semen.goblet; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_semen.goblet IS 'Goblet it sits in — red goblett, Orange Gob.';


--
-- Name: animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.animal (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    stock_code text,
    year_letter text,
    herd_number integer,
    name text,
    nlis_tag text,
    origin public.origin_t DEFAULT 'bred'::public.origin_t NOT NULL,
    sex public.sex_t DEFAULT 'unknown'::public.sex_t NOT NULL,
    dob date,
    breed text,
    grade text,
    coat_colour text,
    polled boolean,
    marking_code text,
    heritage_id uuid,
    property_id uuid,
    origin_property_id uuid,
    purchased_on date,
    purchase_note text,
    sire_id uuid,
    dam_id uuid,
    birth_weight_kg numeric(6,2),
    weaned_on date,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid(),
    gestation_days smallint,
    species public.species_t DEFAULT 'cattle'::public.species_t NOT NULL,
    CONSTRAINT animal_gestation_days_check CHECK (((gestation_days >= 250) AND (gestation_days <= 310))),
    CONSTRAINT animal_pic_required_ck CHECK (((origin = 'reference'::public.origin_t) OR (property_id IS NOT NULL)))
);


--
-- Name: COLUMN animal.property_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.animal.property_id IS 'The PIC this animal is registered to — whose it is, for NVD, NLIS and tax. Not where it grazes.';


--
-- Name: COLUMN animal.gestation_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.animal.gestation_days IS 'This cow''s own gestation length, learnt from her calvings. Null = use 285.';


--
-- Name: COLUMN animal.species; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.animal.species IS 'Everything on the books so far is cattle, so that is the default. Set explicitly on import.';


--
-- Name: animal_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.animal_status (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    animal_id uuid NOT NULL,
    effective_on date NOT NULL,
    life_state public.life_state_t NOT NULL,
    class public.animal_class_t,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid()
);


--
-- Name: COLUMN animal_status.effective_on; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.animal_status.effective_on IS 'The day the change took effect, not the day it was typed. For a sale or a death this is the date the animal left.';


--
-- Name: calving; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calving (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    joining_id uuid,
    dam_id uuid NOT NULL,
    calved_on date NOT NULL,
    calf_id uuid,
    assisted boolean,
    outcome text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid()
);


--
-- Name: consignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consignment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    direction public.consign_dir_t DEFAULT 'out'::public.consign_dir_t NOT NULL,
    consigned_on date DEFAULT CURRENT_DATE NOT NULL,
    nvd_kind public.nvd_kind_t,
    nvd_serial text,
    waybill_no text,
    nlis_upload_id text,
    nlis_sent_on date,
    destination_kind public.destination_t,
    destination text,
    destination_pic text,
    counterparty text,
    carrier text,
    vehicle_rego text,
    head_declared integer,
    notes text,
    q_owned_since_birth boolean,
    q_ram_fed boolean,
    q_byproduct_fed boolean,
    q_within_whp boolean,
    q_hgp_treated boolean,
    q_chemical_risk boolean,
    q_movement_restriction boolean,
    declared_by text,
    declared_on date,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: consignment_animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consignment_animal (
    consignment_id uuid NOT NULL,
    animal_id uuid NOT NULL,
    lot text,
    sale_weight_kg numeric(7,2),
    carcass_weight_kg numeric(7,2),
    price_per_kg numeric(8,3),
    amount_ex_gst numeric(12,2),
    gst numeric(12,2),
    fees numeric(12,2)
);


--
-- Name: cryo_txn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cryo_txn (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ai_semen_id uuid,
    embryo_id uuid,
    kind public.cryo_kind_t NOT NULL,
    qty numeric(6,2) NOT NULL,
    on_date date NOT NULL,
    female_id uuid,
    female_ref text,
    joining_id uuid,
    counterparty text,
    outcome text,
    confidence numeric(3,2),
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid DEFAULT auth.uid(),
    CONSTRAINT cryo_txn_confidence_check CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))),
    CONSTRAINT cryo_txn_one_subject_ck CHECK (((ai_semen_id IS NOT NULL) <> (embryo_id IS NOT NULL))),
    CONSTRAINT cryo_txn_sign_ck CHECK ((((kind = ANY (ARRAY['received'::public.cryo_kind_t, 'returned'::public.cryo_kind_t])) AND (qty > (0)::numeric)) OR ((kind = ANY (ARRAY['used'::public.cryo_kind_t, 'discarded'::public.cryo_kind_t, 'sent_out'::public.cryo_kind_t])) AND (qty < (0)::numeric)) OR ((kind = 'stocktake'::public.cryo_kind_t) AND (qty <> (0)::numeric))))
);


--
-- Name: COLUMN cryo_txn.qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cryo_txn.qty IS 'Signed. Received and returned add, used, discarded and sent_out take away, a stocktake corrects either way.';


--
-- Name: COLUMN cryo_txn.female_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cryo_txn.female_ref IS 'The female as written on the sheet. Kept even once female_id is filled in — it is what the record actually said.';


--
-- Name: embryo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.embryo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tank text,
    location smallint,
    donor_id uuid,
    donor_ref text,
    sire_id uuid,
    sire_ref text,
    pairing text,
    stage text,
    grade text,
    marking text,
    flush_ref text,
    collected_on date,
    units_in integer,
    cost_inc_gst numeric(10,2),
    notes text,
    retired_on date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid DEFAULT auth.uid(),
    CONSTRAINT embryo_location_check CHECK (((location >= 1) AND (location <= 6))),
    CONSTRAINT embryo_units_in_check CHECK ((units_in >= 0))
);


--
-- Name: TABLE embryo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.embryo IS 'Frozen embryos. donor_ref and sire_ref hold the names as written, since many are Rupari animals not yet on file.';


--
-- Name: expected_calving; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expected_calving (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    joining_id uuid,
    dam_id uuid NOT NULL,
    sire_id uuid,
    season text NOT NULL,
    cycle public.cycle_t,
    due_on date,
    resolved_calving_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid()
);


--
-- Name: farm_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.farm_user (
    id uuid NOT NULL,
    display_name text NOT NULL,
    role public.farm_role_t DEFAULT 'viewer'::public.farm_role_t NOT NULL,
    phone text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: feed_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_adjustment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    feed_source_id uuid NOT NULL,
    adjusted_on date DEFAULT CURRENT_DATE NOT NULL,
    qty_delta numeric(10,2) NOT NULL,
    reason text NOT NULL,
    notes text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT feed_adjustment_qty_delta_check CHECK ((qty_delta <> (0)::numeric))
);


--
-- Name: feed_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fed_on date DEFAULT CURRENT_DATE NOT NULL,
    ended_on date,
    feed_source_id uuid,
    ration text,
    paddock_id uuid,
    amount text,
    method text,
    notes text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    qty numeric(10,2),
    is_run boolean DEFAULT false NOT NULL,
    CONSTRAINT feed_event_check CHECK (((ended_on IS NULL) OR (ended_on >= fed_on))),
    CONSTRAINT feed_event_check1 CHECK (((feed_source_id IS NOT NULL) OR (ration IS NOT NULL)))
);


--
-- Name: COLUMN feed_event.is_run; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feed_event.is_run IS 'True when the animals stay on this feed (self feeder, ad lib). False for a single feed-out. Only a run accrues days on feed.';


--
-- Name: feed_event_animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_event_animal (
    feed_event_id uuid NOT NULL,
    animal_id uuid NOT NULL
);


--
-- Name: feed_event_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_event_ref (
    feed_event_id uuid NOT NULL,
    stock_code text NOT NULL,
    note text
);


--
-- Name: TABLE feed_event_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.feed_event_ref IS 'Animals named on the paper feeding record. Resolved into feed_event_animal by feed_resolve_refs() as they appear in the herd; unresolved ones stay visible in v_feed_unmapped rather than being dropped.';


--
-- Name: feed_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_source (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    feedstuff text NOT NULL,
    batch_ref text,
    received_on date,
    amount text,
    origin text,
    home_grown boolean DEFAULT false NOT NULL,
    cvd_ref text,
    residue_cert boolean,
    ram_free boolean,
    storage text,
    signed_by text,
    notes text,
    exhausted_on date,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    feed_type text,
    quantity numeric(10,2),
    unit text,
    intake_kg_head_day numeric(6,2)
);


--
-- Name: COLUMN feed_source.intake_kg_head_day; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feed_source.intake_kg_head_day IS 'Estimated intake per head per day. Drives the projected empty date only — never a stock figure.';


--
-- Name: heartbeat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heartbeat (
    ok boolean DEFAULT true NOT NULL,
    beat_at timestamp with time zone
);


--
-- Name: heritage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heritage (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


--
-- Name: joining; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.joining (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    dam_id uuid NOT NULL,
    sire_id uuid,
    cycle public.cycle_t,
    season text,
    attempt integer DEFAULT 1 NOT NULL,
    joined_on date,
    gestation_days integer DEFAULT 285,
    due_on date,
    confidence numeric(3,2),
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid(),
    outcome public.joining_outcome_t DEFAULT 'unknown'::public.joining_outcome_t NOT NULL,
    tested_on date,
    bull_out date,
    method text DEFAULT 'natural'::text NOT NULL,
    ai_semen_id uuid,
    paddock_id uuid,
    confidence_pct smallint,
    CONSTRAINT joining_confidence_ai_ck CHECK (((confidence_pct IS NULL) OR (method = 'ai'::text))),
    CONSTRAINT joining_confidence_check CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))),
    CONSTRAINT joining_confidence_pct_check CHECK (((confidence_pct >= 0) AND (confidence_pct <= 100))),
    CONSTRAINT joining_due_after_joined_ck CHECK (((due_on IS NULL) OR (joined_on IS NULL) OR (due_on > joined_on))),
    CONSTRAINT joining_due_needs_joined_ck CHECK (((due_on IS NULL) OR (joined_on IS NOT NULL))),
    CONSTRAINT joining_method_ck CHECK ((method = ANY (ARRAY['ai'::text, 'natural'::text]))),
    CONSTRAINT joining_method_fields_ck CHECK ((((method = 'ai'::text) AND (paddock_id IS NULL)) OR ((method = 'natural'::text) AND (ai_semen_id IS NULL))))
);


--
-- Name: COLUMN joining.gestation_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.joining.gestation_days IS 'What was used to work out due_on, copied from the dam at the time. Historical, not current.';


--
-- Name: COLUMN joining.due_on; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.joining.due_on IS 'Worked out from joined_on plus gestation. Meaningless without a service date, so the two are constrained together.';


--
-- Name: COLUMN joining.paddock_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.joining.paddock_id IS 'Bull out only: the mob he ran with. Kept after the paddock is retired.';


--
-- Name: COLUMN joining.confidence_pct; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.joining.confidence_pct IS 'AI only. Operator''s judgement of the insemination, 0-100, recorded before the result is known.';


--
-- Name: paddock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paddock (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    property_id uuid,
    name text NOT NULL,
    code text,
    colour text DEFAULT '#4F7A1F'::text,
    geometry jsonb,
    area_ha numeric(8,2),
    sort_order integer DEFAULT 0,
    notes text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    retired_on date,
    retired_reason text
);


--
-- Name: paddock_geometry_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paddock_geometry_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    paddock_id uuid NOT NULL,
    geometry jsonb,
    area_ha numeric(8,2),
    valid_from timestamp with time zone,
    valid_to timestamp with time zone DEFAULT now() NOT NULL,
    changed_by uuid DEFAULT auth.uid()
);


--
-- Name: paddock_lineage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paddock_lineage (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    change public.paddock_change_t NOT NULL,
    changed_on date DEFAULT CURRENT_DATE NOT NULL,
    notes text,
    recorded_by uuid DEFAULT auth.uid()
);


--
-- Name: paddock_stay; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paddock_stay (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    animal_id uuid NOT NULL,
    paddock_id uuid NOT NULL,
    moved_in date DEFAULT CURRENT_DATE NOT NULL,
    moved_out date,
    reason text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT paddock_stay_check CHECK (((moved_out IS NULL) OR (moved_out >= moved_in)))
);


--
-- Name: planned_joining; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planned_joining (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    dam_id uuid NOT NULL,
    method public.joining_method_t DEFAULT 'natural'::public.joining_method_t NOT NULL,
    sire_id uuid,
    ai_semen_id uuid,
    paddock_id uuid,
    season text NOT NULL,
    cycle public.cycle_t,
    planned_on date,
    gestation_days smallint,
    notes text,
    joining_id uuid,
    cancelled_on date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid DEFAULT auth.uid(),
    CONSTRAINT planned_joining_gestation_days_check CHECK (((gestation_days >= 130) AND (gestation_days <= 310))),
    CONSTRAINT planned_joining_method_fields_ck CHECK ((((method = 'ai'::public.joining_method_t) AND (paddock_id IS NULL)) OR ((method = 'natural'::public.joining_method_t) AND (ai_semen_id IS NULL))))
);


--
-- Name: TABLE planned_joining; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.planned_joining IS 'Who is to go to which bull or straw, and when. Not a mating: nothing here counts on Due, in conception rates or against the tank. joining_id is set by trigger when the joining is recorded; cancelled_on when the plan is dropped.';


--
-- Name: COLUMN planned_joining.planned_on; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.planned_joining.planned_on IS 'When it is meant to happen. Null is allowed: the who can be decided before the when.';


--
-- Name: COLUMN planned_joining.gestation_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.planned_joining.gestation_days IS 'Nominated for this plan only. Null = the dam''s own figure, else the species default. Does not rewrite the dam.';


--
-- Name: property; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pic text NOT NULL,
    name text,
    is_own boolean DEFAULT false NOT NULL,
    address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    trading_name text
);


--
-- Name: COLUMN property.is_primary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.property.is_primary IS 'The registration the property itself trades under. Drives page letterheads and where new paddocks are attached. Exactly one.';


--
-- Name: record_change_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.record_change_log (
    id bigint NOT NULL,
    table_name text NOT NULL,
    row_id uuid NOT NULL,
    action text NOT NULL,
    old_row jsonb,
    new_row jsonb,
    changed_by uuid DEFAULT auth.uid(),
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT record_change_log_action_check CHECK ((action = ANY (ARRAY['update'::text, 'delete'::text])))
);


--
-- Name: record_change_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.record_change_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: record_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.record_change_log_id_seq OWNED BY public.record_change_log.id;


--
-- Name: shearing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shearing (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shorn_on date NOT NULL,
    kind public.shearing_kind_t DEFAULT 'shearing'::public.shearing_kind_t NOT NULL,
    description text,
    contractor text,
    bales numeric(6,2),
    micron numeric(4,1),
    notes text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT shearing_bales_check CHECK ((bales >= (0)::numeric)),
    CONSTRAINT shearing_micron_check CHECK ((micron > (0)::numeric))
);


--
-- Name: shearing_animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shearing_animal (
    shearing_id uuid NOT NULL,
    animal_id uuid NOT NULL
);


--
-- Name: spray_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spray_event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    applied_on date NOT NULL,
    crop_treated text,
    water_rate_l_ha numeric(8,2),
    method text,
    wind_direction text,
    wind_speed_kmh numeric(5,1),
    applied_by text,
    applied_by_contact text,
    notes text,
    recorded_by uuid DEFAULT auth.uid(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT spray_event_wind_speed_kmh_check CHECK (((wind_speed_kmh IS NULL) OR (wind_speed_kmh >= (0)::numeric)))
);


--
-- Name: TABLE spray_event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.spray_event IS 'LPA Section 3B — one application of chemical to a paddock or crop.';


--
-- Name: COLUMN spray_event.water_rate_l_ha; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.spray_event.water_rate_l_ha IS 'Total spray volume per hectare. The chemical rate lives on each product.';


--
-- Name: spray_paddock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spray_paddock (
    spray_event_id uuid NOT NULL,
    paddock_id uuid NOT NULL,
    area_ha numeric(8,2),
    location_note text,
    CONSTRAINT spray_paddock_area_ha_check CHECK (((area_ha IS NULL) OR (area_ha > (0)::numeric)))
);


--
-- Name: TABLE spray_paddock; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.spray_paddock IS 'Which paddocks one pass covered. Area is per paddock, not per pass.';


--
-- Name: spray_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spray_product (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    spray_event_id uuid NOT NULL,
    product_name text NOT NULL,
    active_ingredient text,
    chemical_rate text,
    batch_number text,
    graze_withhold_days integer,
    harvest_withhold_days integer,
    esi_days integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT spray_product_esi_days_check CHECK (((esi_days IS NULL) OR (esi_days >= 0))),
    CONSTRAINT spray_product_graze_withhold_days_check CHECK (((graze_withhold_days IS NULL) OR (graze_withhold_days >= 0))),
    CONSTRAINT spray_product_harvest_withhold_days_check CHECK (((harvest_withhold_days IS NULL) OR (harvest_withhold_days >= 0)))
);


--
-- Name: TABLE spray_product; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.spray_product IS 'One product in one pass. A tank mix is several rows against one spray_event.';


--
-- Name: COLUMN spray_product.graze_withhold_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.spray_product.graze_withhold_days IS 'Label days before stock may graze. NULL means unknown, which is NOT the same as zero.';


--
-- Name: treatment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    treated_on date NOT NULL,
    description text,
    product_name text NOT NULL,
    batch_number text,
    product_expiry date,
    dose_rate text,
    route text,
    withholding_days integer,
    esi_days integer,
    safe_for_slaughter date GENERATED ALWAYS AS ((treated_on + COALESCE(withholding_days, 0))) STORED,
    treated_by text,
    treated_by_contact text,
    adverse_reaction text,
    broken_needle boolean DEFAULT false NOT NULL,
    equipment_clean boolean,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid()
);


--
-- Name: treatment_animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatment_animal (
    treatment_id uuid NOT NULL,
    animal_id uuid NOT NULL
);


--
-- Name: user_pref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_pref (
    user_id uuid NOT NULL,
    prefs jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: v_ai_semen; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_ai_semen WITH (security_invoker='on') AS
 SELECT s.id,
    s.sire_id,
    s.sire_name,
    s.breed,
    s.straw_code,
    s.batch_code,
    s.tank,
    s.supplier,
    s.collected_on,
    s.straws_in,
    s.notes,
    s.retired_on,
    s.created_at,
    s.created_by,
    s.location,
    s.marking,
    s.horn_status,
    s.price_per_straw,
    s.cost_inc_gst,
    s.mark_colour,
    s.straw_desc,
    s.straw_size,
    s.goblet,
    NULLIF(concat_ws(' · '::text, s.mark_colour, s.straw_desc, NULLIF(s.straw_size, ''::text), s.goblet), ''::text) AS shelf_label,
    COALESCE(t.on_hand, (0)::numeric) AS straws_left,
    COALESCE(t.used, (0)::numeric) AS straws_used,
    COALESCE(a.stock_code, a.name, s.sire_name) AS sire_label,
    t.last_moved
   FROM ((public.ai_semen s
     LEFT JOIN public.animal a ON ((a.id = s.sire_id)))
     LEFT JOIN LATERAL ( SELECT sum(cryo_txn.qty) AS on_hand,
            (- sum(cryo_txn.qty) FILTER (WHERE (cryo_txn.kind = 'used'::public.cryo_kind_t))) AS used,
            max(cryo_txn.on_date) AS last_moved
           FROM public.cryo_txn
          WHERE (cryo_txn.ai_semen_id = s.id)) t ON (true));


--
-- Name: v_animal_clearance; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_animal_clearance WITH (security_invoker='on') AS
 SELECT a.id AS animal_id,
    a.stock_code,
    max(t.safe_for_slaughter) AS clear_domestic,
    max((t.treated_on + COALESCE(t.esi_days, 0))) AS clear_export,
    max(t.treated_on) AS last_treated,
    (max(t.safe_for_slaughter) > CURRENT_DATE) AS within_whp,
    (max((t.treated_on + COALESCE(t.esi_days, 0))) > CURRENT_DATE) AS within_esi
   FROM ((public.animal a
     LEFT JOIN public.treatment_animal ta ON ((ta.animal_id = a.id)))
     LEFT JOIN public.treatment t ON ((t.id = ta.treatment_id)))
  WHERE (a.origin <> 'reference'::public.origin_t)
  GROUP BY a.id, a.stock_code;


--
-- Name: v_feed_cover; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_feed_cover WITH (security_invoker='on') AS
 SELECT fa.animal_id,
    fe.id AS feed_event_id,
    fe.fed_on,
    fe.ended_on,
    fe.feed_source_id,
    fe.ration,
    fe.paddock_id
   FROM (public.feed_event fe
     JOIN public.feed_event_animal fa ON ((fa.feed_event_id = fe.id)))
UNION
 SELECT s.animal_id,
    fe.id AS feed_event_id,
    fe.fed_on,
    fe.ended_on,
    fe.feed_source_id,
    fe.ration,
    fe.paddock_id
   FROM (public.feed_event fe
     JOIN public.paddock_stay s ON (((s.paddock_id = fe.paddock_id) AND (s.moved_in <= COALESCE(fe.ended_on, CURRENT_DATE)) AND ((s.moved_out IS NULL) OR (s.moved_out >= fe.fed_on)))))
  WHERE (fe.paddock_id IS NOT NULL);


--
-- Name: v_feed_load; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_feed_load WITH (security_invoker='on') AS
 SELECT fe.id AS feed_event_id,
    fe.feed_source_id,
    fe.fed_on,
    fe.ended_on,
    fs.feedstuff,
    fs.unit,
    fe.qty,
    public.feed_qty_kg(fe.qty, fs.unit) AS qty_kg,
    fs.intake_kg_head_day AS rate,
    hd.head,
        CASE
            WHEN ((public.feed_qty_kg(fe.qty, fs.unit) IS NOT NULL) AND (fs.intake_kg_head_day > (0)::numeric) AND (hd.head > 0)) THEN round((public.feed_qty_kg(fe.qty, fs.unit) / ((hd.head)::numeric * fs.intake_kg_head_day)))
            ELSE NULL::numeric
        END AS est_days,
        CASE
            WHEN ((public.feed_qty_kg(fe.qty, fs.unit) IS NOT NULL) AND (fs.intake_kg_head_day > (0)::numeric) AND (hd.head > 0)) THEN (fe.fed_on + (round((public.feed_qty_kg(fe.qty, fs.unit) / ((hd.head)::numeric * fs.intake_kg_head_day))))::integer)
            ELSE NULL::date
        END AS est_empty_on,
    (CURRENT_DATE - fe.fed_on) AS days_out,
    hd.head_unmapped
   FROM ((public.feed_event fe
     JOIN public.feed_source fs ON ((fs.id = fe.feed_source_id)))
     LEFT JOIN LATERAL ( SELECT (( SELECT count(DISTINCT c.animal_id) AS count
                   FROM public.v_feed_cover c
                  WHERE (c.feed_event_id = fe.id)) + ( SELECT count(*) AS count
                   FROM public.feed_event_ref r
                  WHERE ((r.feed_event_id = fe.id) AND (NOT (EXISTS ( SELECT 1
                           FROM public.animal a
                          WHERE ((a.stock_code = r.stock_code) AND (a.origin <> 'reference'::public.origin_t)))))))) AS head,
            ( SELECT count(*) AS count
                   FROM public.feed_event_ref r
                  WHERE ((r.feed_event_id = fe.id) AND (NOT (EXISTS ( SELECT 1
                           FROM public.animal a
                          WHERE ((a.stock_code = r.stock_code) AND (a.origin <> 'reference'::public.origin_t))))))) AS head_unmapped) hd ON (true));


--
-- Name: v_animal_feed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_animal_feed WITH (security_invoker='on') AS
 WITH runs AS (
         SELECT c.animal_id,
            c.fed_on,
            c.feed_event_id,
            COALESCE(fs.feedstuff, c.ration) AS feedstuff
           FROM ((public.v_feed_cover c
             JOIN public.feed_event fe ON (((fe.id = c.feed_event_id) AND fe.is_run)))
             LEFT JOIN public.feed_source fs ON ((fs.id = c.feed_source_id)))
          WHERE ((c.ended_on IS NULL) AND (c.fed_on <= CURRENT_DATE))
        ), latest AS (
         SELECT DISTINCT ON (runs.animal_id) runs.animal_id,
            runs.feed_event_id
           FROM runs
          ORDER BY runs.animal_id, runs.fed_on DESC
        )
 SELECT r.animal_id,
    min(r.fed_on) AS on_feed_since,
    (CURRENT_DATE - min(r.fed_on)) AS days_on_feed,
    count(*) AS open_runs,
    string_agg(DISTINCT r.feedstuff, ', '::text) AS feedstuff,
    max(l.est_empty_on) AS est_empty_on,
    (max(l.est_empty_on) - CURRENT_DATE) AS est_days_left
   FROM ((runs r
     JOIN latest lt ON ((lt.animal_id = r.animal_id)))
     LEFT JOIN public.v_feed_load l ON ((l.feed_event_id = lt.feed_event_id)))
  GROUP BY r.animal_id;


--
-- Name: v_animal_feed_last; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_animal_feed_last WITH (security_invoker='on') AS
 SELECT DISTINCT ON (c.animal_id) c.animal_id,
    c.fed_on AS last_run_from,
    c.ended_on AS off_feed_on,
    (c.ended_on - c.fed_on) AS days_fed_last,
    COALESCE(fs.feedstuff, c.ration) AS last_feedstuff
   FROM ((public.v_feed_cover c
     JOIN public.feed_event fe ON (((fe.id = c.feed_event_id) AND fe.is_run)))
     LEFT JOIN public.feed_source fs ON ((fs.id = c.feed_source_id)))
  WHERE (c.ended_on IS NOT NULL)
  ORDER BY c.animal_id, c.ended_on DESC, c.fed_on;


--
-- Name: weight_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weight_event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    animal_id uuid NOT NULL,
    weighed_on date NOT NULL,
    weight_kg numeric(7,2) NOT NULL,
    method text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by uuid DEFAULT auth.uid(),
    CONSTRAINT weight_event_weight_kg_check CHECK ((weight_kg > (0)::numeric))
);


--
-- Name: v_animal_current; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_animal_current WITH (security_invoker='on') AS
 SELECT a.id,
    a.stock_code,
    a.year_letter,
    a.herd_number,
    a.name,
    a.nlis_tag,
    a.origin,
    a.sex,
    a.dob,
    a.breed,
    a.grade,
    a.coat_colour,
    a.polled,
    a.marking_code,
    a.birth_weight_kg,
    a.weaned_on,
    a.notes,
    a.purchased_on,
    a.purchase_note,
    a.heritage_id,
    h.name AS heritage_name,
    a.property_id,
    pr.pic,
    a.origin_property_id,
    opr.pic AS origin_pic,
    a.sire_id,
    COALESCE(sire.name, sire.stock_code) AS sire_name,
    a.dam_id,
    dam.stock_code AS dam_code,
    dam.name AS dam_name,
    (CURRENT_DATE - a.dob) AS age_days,
    round((((CURRENT_DATE - a.dob))::numeric / 30.4375), 2) AS age_months,
    round((((CURRENT_DATE - a.dob))::numeric / 365.25), 2) AS age_years,
    s.life_state,
    s.class,
    w.weight_kg AS last_weight_kg,
    w.weighed_on AS last_weighed_on,
        CASE
            WHEN ((w.weight_kg IS NOT NULL) AND (a.birth_weight_kg IS NOT NULL) AND (w.weighed_on > a.dob)) THEN round(((w.weight_kg - a.birth_weight_kg) / ((w.weighed_on - a.dob))::numeric), 4)
            ELSE NULL::numeric
        END AS adg_kg_per_day,
    pk.id AS paddock_id,
    pk.name AS paddock_name,
    pk.colour AS paddock_colour,
    st.moved_in AS in_paddock_since,
    cl.clear_domestic,
    cl.within_whp,
    ex.effective_on AS exit_on,
    ex.life_state AS exit_state,
    ex.id AS exit_status_id,
    ex.reason AS exit_reason,
    a.species,
    a.gestation_days,
    sire.stock_code AS sire_code,
    fd.on_feed_since,
    fd.days_on_feed,
    fd.feedstuff AS on_feed_feedstuff,
    fd.est_empty_on,
    fd.est_days_left,
    lf.off_feed_on,
    lf.days_fed_last,
    lf.last_feedstuff
   FROM (((((((((((((public.animal a
     LEFT JOIN public.animal dam ON ((dam.id = a.dam_id)))
     LEFT JOIN public.animal sire ON ((sire.id = a.sire_id)))
     LEFT JOIN public.heritage h ON ((h.id = a.heritage_id)))
     LEFT JOIN public.property pr ON ((pr.id = a.property_id)))
     LEFT JOIN public.property opr ON ((opr.id = a.origin_property_id)))
     LEFT JOIN LATERAL ( SELECT animal_status.life_state,
            animal_status.class
           FROM public.animal_status
          WHERE ((animal_status.animal_id = a.id) AND (animal_status.effective_on <= CURRENT_DATE))
          ORDER BY animal_status.effective_on DESC
         LIMIT 1) s ON (true))
     LEFT JOIN LATERAL ( SELECT weight_event.weight_kg,
            weight_event.weighed_on
           FROM public.weight_event
          WHERE (weight_event.animal_id = a.id)
          ORDER BY weight_event.weighed_on DESC
         LIMIT 1) w ON (true))
     LEFT JOIN LATERAL ( SELECT paddock_stay.paddock_id,
            paddock_stay.moved_in
           FROM public.paddock_stay
          WHERE ((paddock_stay.animal_id = a.id) AND (paddock_stay.moved_out IS NULL))
         LIMIT 1) st ON (true))
     LEFT JOIN LATERAL ( SELECT animal_status.id,
            animal_status.effective_on,
            animal_status.life_state,
            animal_status.reason
           FROM public.animal_status
          WHERE ((animal_status.animal_id = a.id) AND (animal_status.life_state <> 'alive'::public.life_state_t))
          ORDER BY animal_status.effective_on
         LIMIT 1) ex ON (true))
     LEFT JOIN public.paddock pk ON ((pk.id = st.paddock_id)))
     LEFT JOIN public.v_animal_clearance cl ON ((cl.animal_id = a.id)))
     LEFT JOIN public.v_animal_feed fd ON ((fd.animal_id = a.id)))
     LEFT JOIN public.v_animal_feed_last lf ON ((lf.animal_id = a.id)))
  WHERE (a.origin <> 'reference'::public.origin_t);


--
-- Name: v_breeding_stock; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_breeding_stock WITH (security_invoker='on') AS
 SELECT id,
    name,
    stock_code,
    sex,
    origin,
    COALESCE(NULLIF(TRIM(BOTH FROM concat_ws(' '::text, stock_code, name)), ''::text), 'Unnamed'::text) AS label,
    species
   FROM public.animal a
  WHERE ((origin = 'reference'::public.origin_t) OR (sex = ANY (ARRAY['female'::public.sex_t, 'male'::public.sex_t])));


--
-- Name: v_consignment; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_consignment AS
SELECT
    NULL::uuid AS id,
    NULL::public.consign_dir_t AS direction,
    NULL::date AS consigned_on,
    NULL::public.nvd_kind_t AS nvd_kind,
    NULL::text AS nvd_serial,
    NULL::text AS waybill_no,
    NULL::text AS nlis_upload_id,
    NULL::date AS nlis_sent_on,
    NULL::public.destination_t AS destination_kind,
    NULL::text AS destination,
    NULL::text AS destination_pic,
    NULL::text AS counterparty,
    NULL::text AS carrier,
    NULL::text AS vehicle_rego,
    NULL::integer AS head_declared,
    NULL::text AS notes,
    NULL::boolean AS q_owned_since_birth,
    NULL::boolean AS q_ram_fed,
    NULL::boolean AS q_byproduct_fed,
    NULL::boolean AS q_within_whp,
    NULL::boolean AS q_hgp_treated,
    NULL::boolean AS q_chemical_risk,
    NULL::boolean AS q_movement_restriction,
    NULL::text AS declared_by,
    NULL::date AS declared_on,
    NULL::uuid AS recorded_by,
    NULL::timestamp with time zone AS created_at,
    NULL::text AS recorded_by_name,
    NULL::bigint AS head,
    NULL::text AS tags,
    NULL::numeric AS total_kg,
    NULL::numeric AS total_ex_gst,
    NULL::bigint AS edits,
    NULL::text AS species;


--
-- Name: v_embryo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_embryo WITH (security_invoker='on') AS
 SELECT e.id,
    e.tank,
    e.location,
    e.donor_id,
    e.donor_ref,
    e.sire_id,
    e.sire_ref,
    e.pairing,
    e.stage,
    e.grade,
    e.marking,
    e.flush_ref,
    e.collected_on,
    e.units_in,
    e.cost_inc_gst,
    e.notes,
    e.retired_on,
    e.created_at,
    e.created_by,
    COALESCE(t.on_hand, (0)::numeric) AS units_left,
    COALESCE(t.used, (0)::numeric) AS units_used,
    COALESCE(d.stock_code, d.name, e.donor_ref) AS donor_label,
    COALESCE(sa.stock_code, sa.name, e.sire_ref) AS sire_label,
    t.last_moved
   FROM (((public.embryo e
     LEFT JOIN public.animal d ON ((d.id = e.donor_id)))
     LEFT JOIN public.animal sa ON ((sa.id = e.sire_id)))
     LEFT JOIN LATERAL ( SELECT sum(cryo_txn.qty) AS on_hand,
            (- sum(cryo_txn.qty) FILTER (WHERE (cryo_txn.kind = 'used'::public.cryo_kind_t))) AS used,
            max(cryo_txn.on_date) AS last_moved
           FROM public.cryo_txn
          WHERE (cryo_txn.embryo_id = e.id)) t ON (true));


--
-- Name: v_cryo_location; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_cryo_location WITH (security_invoker='on') AS
 SELECT v_ai_semen.tank,
    v_ai_semen.location,
    'semen'::text AS holds,
    (count(*))::integer AS entries,
    sum(v_ai_semen.straws_left) AS units
   FROM public.v_ai_semen
  WHERE ((v_ai_semen.retired_on IS NULL) AND (v_ai_semen.tank IS NOT NULL))
  GROUP BY v_ai_semen.tank, v_ai_semen.location
UNION ALL
 SELECT v_embryo.tank,
    v_embryo.location,
    'embryo'::text AS holds,
    (count(*))::integer AS entries,
    sum(v_embryo.units_left) AS units
   FROM public.v_embryo
  WHERE ((v_embryo.retired_on IS NULL) AND (v_embryo.tank IS NOT NULL))
  GROUP BY v_embryo.tank, v_embryo.location
  ORDER BY 1, 2, 3;


--
-- Name: v_cryo_unmapped; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_cryo_unmapped WITH (security_invoker='on') AS
 SELECT t.female_ref,
    public.cryo_ref_code(t.female_ref) AS reads_as,
    count(*) AS times,
    min(t.on_date) AS first_used,
    max(t.on_date) AS last_used,
    string_agg(DISTINCT COALESCE(s.sire_name, e.pairing), '; '::text) AS to_which,
        CASE
            WHEN (public.cryo_ref_code(t.female_ref) IS NULL) THEN 'no tag in the name'::text
            ELSE 'tag reads clean but no such animal'::text
        END AS why
   FROM ((public.cryo_txn t
     LEFT JOIN public.ai_semen s ON ((s.id = t.ai_semen_id)))
     LEFT JOIN public.embryo e ON ((e.id = t.embryo_id)))
  WHERE ((t.female_id IS NULL) AND (t.female_ref IS NOT NULL))
  GROUP BY t.female_ref
  ORDER BY
        CASE
            WHEN (public.cryo_ref_code(t.female_ref) IS NULL) THEN 'no tag in the name'::text
            ELSE 'tag reads clean but no such animal'::text
        END, (count(*)) DESC, t.female_ref;


--
-- Name: VIEW v_cryo_unmapped; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_cryo_unmapped IS 'Females named on the register but not on file. reads_as shows what the tag was taken to be, so a bad reading is visible rather than silent.';


--
-- Name: v_dam_fertility; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_dam_fertility WITH (security_invoker='on') AS
 SELECT d.id AS dam_id,
    d.stock_code,
    d.name,
    count(j.id) AS joinings,
    count(*) FILTER (WHERE (j.outcome = ANY (ARRAY['in_calf'::public.joining_outcome_t, 'calved'::public.joining_outcome_t]))) AS held,
    count(*) FILTER (WHERE (j.outcome = 'empty'::public.joining_outcome_t)) AS empty,
    max(j.season) FILTER (WHERE (j.outcome = 'empty'::public.joining_outcome_t)) AS last_empty,
        CASE
            WHEN (count(*) FILTER (WHERE ((j.outcome)::text <> ALL (ARRAY['unknown'::text, 'closed'::text]))) > 0) THEN round(((100.0 * (count(*) FILTER (WHERE (j.outcome = ANY (ARRAY['in_calf'::public.joining_outcome_t, 'calved'::public.joining_outcome_t]))))::numeric) / (count(*) FILTER (WHERE ((j.outcome)::text <> ALL (ARRAY['unknown'::text, 'closed'::text]))))::numeric))
            ELSE NULL::numeric
        END AS pct_held
   FROM (public.animal d
     JOIN public.joining j ON ((j.dam_id = d.id)))
  GROUP BY d.id, d.stock_code, d.name;


--
-- Name: v_due_date_check; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_due_date_check WITH (security_invoker='on') AS
 SELECT id,
    joined_on,
    gestation_days,
    due_on AS due_on_recorded,
    (joined_on + gestation_days) AS due_on_calculated,
    ((joined_on + gestation_days) - due_on) AS drift
   FROM public.joining j
  WHERE ((joined_on IS NOT NULL) AND (gestation_days IS NOT NULL) AND (due_on IS NOT NULL) AND (due_on <> (joined_on + gestation_days)))
  ORDER BY joined_on;


--
-- Name: v_feed_event; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_feed_event WITH (security_invoker='on') AS
 SELECT fe.id,
    fe.fed_on,
    fe.ended_on,
    fe.amount,
    fe.qty,
    fe.method,
    fe.notes,
    fe.feed_source_id,
    fe.ration,
    COALESCE(fs.feedstuff, fe.ration) AS feedstuff,
    fs.feed_type,
    fs.batch_ref,
    fs.origin,
    fs.cvd_ref,
    fs.ram_free,
    fs.home_grown,
    fs.unit,
    fe.paddock_id,
    p.name AS paddock_name,
    p.colour AS paddock_colour,
    u.display_name AS fed_by,
    (( SELECT count(*) AS count
           FROM public.feed_event_animal fa
          WHERE (fa.feed_event_id = fe.id)) +
        CASE
            WHEN (fe.paddock_id IS NULL) THEN (0)::bigint
            ELSE ( SELECT count(*) AS count
               FROM public.paddock_stay s
              WHERE ((s.paddock_id = fe.paddock_id) AND (s.moved_in <= fe.fed_on) AND ((s.moved_out IS NULL) OR (s.moved_out >= fe.fed_on))))
        END) AS head,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'feed_event'::text) AND (l.row_id = fe.id))) AS edits
   FROM (((public.feed_event fe
     LEFT JOIN public.feed_source fs ON ((fs.id = fe.feed_source_id)))
     LEFT JOIN public.paddock p ON ((p.id = fe.paddock_id)))
     LEFT JOIN public.farm_user u ON ((u.id = fe.recorded_by)));


--
-- Name: v_feed_store; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_feed_store WITH (security_invoker='on') AS
 WITH used AS (
         SELECT feed_event.feed_source_id,
            COALESCE(sum(feed_event.qty), (0)::numeric) AS qty_out,
            count(*) AS feed_outs,
            max(feed_event.fed_on) AS last_fed
           FROM public.feed_event
          WHERE (feed_event.feed_source_id IS NOT NULL)
          GROUP BY feed_event.feed_source_id
        ), adj AS (
         SELECT feed_adjustment.feed_source_id,
            COALESCE(sum(feed_adjustment.qty_delta), (0)::numeric) AS qty_adj,
            count(*) AS adjustments
           FROM public.feed_adjustment
          GROUP BY feed_adjustment.feed_source_id
        )
 SELECT fs.id,
    fs.feedstuff,
    fs.feed_type,
    fs.batch_ref,
    fs.received_on,
    fs.quantity,
    fs.unit,
    fs.amount,
    fs.origin,
    fs.home_grown,
    fs.cvd_ref,
    fs.residue_cert,
    fs.ram_free,
    fs.storage,
    fs.signed_by,
    fs.exhausted_on,
    fs.notes,
    COALESCE(u.qty_out, (0)::numeric) AS used,
    COALESCE(a.qty_adj, (0)::numeric) AS adjusted,
    COALESCE(u.feed_outs, (0)::bigint) AS feed_outs,
    COALESCE(a.adjustments, (0)::bigint) AS adjustments,
    u.last_fed,
        CASE
            WHEN (fs.quantity IS NOT NULL) THEN round(((fs.quantity + COALESCE(a.qty_adj, (0)::numeric)) - COALESCE(u.qty_out, (0)::numeric)), 2)
            ELSE NULL::numeric
        END AS remaining,
        CASE
            WHEN ((fs.quantity IS NOT NULL) AND ((fs.quantity + COALESCE(a.qty_adj, (0)::numeric)) > (0)::numeric)) THEN round((((100)::numeric * ((fs.quantity + COALESCE(a.qty_adj, (0)::numeric)) - COALESCE(u.qty_out, (0)::numeric))) / (fs.quantity + COALESCE(a.qty_adj, (0)::numeric))))
            ELSE NULL::numeric
        END AS pct_left
   FROM ((public.feed_source fs
     LEFT JOIN used u ON ((u.feed_source_id = fs.id)))
     LEFT JOIN adj a ON ((a.feed_source_id = fs.id)));


--
-- Name: v_feed_unmapped; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_feed_unmapped WITH (security_invoker='on') AS
 SELECT fe.fed_on,
    COALESCE(fs.feedstuff, fe.ration) AS feedstuff,
    r.stock_code,
    COALESCE(r.note, 'not in the herd'::text) AS why,
    fe.id AS feed_event_id
   FROM ((public.feed_event_ref r
     JOIN public.feed_event fe ON ((fe.id = r.feed_event_id)))
     LEFT JOIN public.feed_source fs ON ((fs.id = fe.feed_source_id)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM public.animal a
          WHERE ((a.stock_code = r.stock_code) AND (a.origin <> 'reference'::public.origin_t)))))
  ORDER BY fe.fed_on, r.stock_code;


--
-- Name: v_joining_performance; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_joining_performance WITH (security_invoker='on') AS
 SELECT COALESCE(s.name, 'Sire not recorded'::text) AS sire,
    j.season,
    count(*) AS joinings,
    count(*) FILTER (WHERE (j.outcome = ANY (ARRAY['in_calf'::public.joining_outcome_t, 'calved'::public.joining_outcome_t]))) AS held,
    count(*) FILTER (WHERE (j.outcome = 'empty'::public.joining_outcome_t)) AS empty,
    count(*) FILTER (WHERE (j.outcome = ANY (ARRAY['aborted'::public.joining_outcome_t, 'lost'::public.joining_outcome_t]))) AS lost,
    count(*) FILTER (WHERE ((j.outcome)::text = ANY (ARRAY['unknown'::text, 'closed'::text]))) AS untested,
        CASE
            WHEN (count(*) FILTER (WHERE ((j.outcome)::text <> ALL (ARRAY['unknown'::text, 'closed'::text]))) > 0) THEN round(((100.0 * (count(*) FILTER (WHERE (j.outcome = ANY (ARRAY['in_calf'::public.joining_outcome_t, 'calved'::public.joining_outcome_t]))))::numeric) / (count(*) FILTER (WHERE ((j.outcome)::text <> ALL (ARRAY['unknown'::text, 'closed'::text]))))::numeric))
            ELSE NULL::numeric
        END AS pct_held
   FROM (public.joining j
     LEFT JOIN public.animal s ON ((s.id = j.sire_id)))
  GROUP BY COALESCE(s.name, 'Sire not recorded'::text), j.season;


--
-- Name: v_joining_result; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_joining_result WITH (security_invoker='on') AS
 SELECT j.id,
    j.dam_id,
    d.stock_code AS dam_code,
    d.name AS dam_name,
    j.method,
    j.sire_id,
    COALESCE(s.name, sem.sire_name) AS sire_name,
    j.ai_semen_id,
    sem.straw_code,
    sem.tank,
    j.paddock_id,
    p.name AS paddock_name,
    j.season,
    j.cycle,
    j.attempt,
    j.joined_on,
    j.bull_out,
    j.tested_on,
    j.gestation_days,
    j.due_on,
    j.confidence,
    j.outcome,
    j.notes,
    c.calved_on,
    c.outcome AS calving_outcome,
    calf.stock_code AS calf_code,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'joining'::text) AND (l.row_id = j.id))) AS edits,
    d.property_id,
    dpr.pic,
    d.species
   FROM (((((((public.joining j
     JOIN public.animal d ON ((d.id = j.dam_id)))
     LEFT JOIN public.property dpr ON ((dpr.id = d.property_id)))
     LEFT JOIN public.animal s ON ((s.id = j.sire_id)))
     LEFT JOIN public.ai_semen sem ON ((sem.id = j.ai_semen_id)))
     LEFT JOIN public.paddock p ON ((p.id = j.paddock_id)))
     LEFT JOIN public.calving c ON ((c.joining_id = j.id)))
     LEFT JOIN public.animal calf ON ((calf.id = c.calf_id)));


--
-- Name: v_paddock_all; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_paddock_all WITH (security_invoker='on') AS
 SELECT id,
    name,
    code,
    colour,
    area_ha,
    retired_on,
    retired_reason,
    (created_at)::date AS opened_on,
    ( SELECT string_agg(pp.name, ', '::text) AS string_agg
           FROM (public.paddock_lineage l
             JOIN public.paddock pp ON ((pp.id = l.parent_id)))
          WHERE (l.child_id = p.id)) AS replaced,
    ( SELECT string_agg(cp.name, ', '::text) AS string_agg
           FROM (public.paddock_lineage l
             JOIN public.paddock cp ON ((cp.id = l.child_id)))
          WHERE (l.parent_id = p.id)) AS became
   FROM public.paddock p;


--
-- Name: v_paddock_current; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_paddock_current AS
SELECT
    NULL::uuid AS id,
    NULL::text AS name,
    NULL::text AS code,
    NULL::text AS colour,
    NULL::jsonb AS geometry,
    NULL::numeric(8,2) AS area_ha,
    NULL::text AS notes,
    NULL::integer AS sort_order,
    NULL::date AS retired_on,
    NULL::bigint AS head,
    NULL::numeric AS head_per_ha,
    NULL::date AS grazing_since,
    NULL::boolean AS has_history;


--
-- Name: v_paddock_withhold; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_paddock_withhold WITH (security_invoker='on') AS
 WITH binding AS (
         SELECT pk.paddock_id,
            se.applied_on,
            sp.product_name,
            (se.applied_on + sp.graze_withhold_days) AS clears_on,
            (sp.graze_withhold_days IS NULL) AS unknown
           FROM ((public.spray_event se
             JOIN public.spray_paddock pk ON ((pk.spray_event_id = se.id)))
             JOIN public.spray_product sp ON ((sp.spray_event_id = se.id)))
          WHERE (((se.applied_on + sp.graze_withhold_days) > public.farm_today()) OR ((sp.graze_withhold_days IS NULL) AND (se.applied_on > (public.farm_today() - 60))))
        )
 SELECT b.paddock_id,
    p.name AS paddock_name,
    max(b.applied_on) AS last_sprayed,
    max(b.clears_on) AS safe_to_graze,
    bool_or(b.unknown) AS withhold_unknown,
    string_agg(DISTINCT b.product_name, ', '::text) AS products
   FROM (binding b
     JOIN public.paddock p ON ((p.id = b.paddock_id)))
  GROUP BY b.paddock_id, p.name;


--
-- Name: v_planned_joining; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_planned_joining WITH (security_invoker='on') AS
 SELECT pj.id,
    pj.dam_id,
    d.stock_code AS dam_code,
    d.name AS dam_name,
    d.species,
    pj.method,
    pj.sire_id,
    COALESCE(s.name, s.stock_code, sem.sire_name) AS sire_name,
    pj.ai_semen_id,
    sem.straw_code,
    sem.tank,
    pj.paddock_id,
    p.name AS paddock_name,
    pj.season,
    pj.cycle,
    pj.planned_on,
    pj.gestation_days AS nominated_days,
    COALESCE((pj.gestation_days)::integer, (d.gestation_days)::integer,
        CASE
            WHEN (d.species = 'sheep'::public.species_t) THEN 145
            ELSE 285
        END) AS gestation_used,
    (pj.planned_on + COALESCE((pj.gestation_days)::integer, (d.gestation_days)::integer,
        CASE
            WHEN (d.species = 'sheep'::public.species_t) THEN 145
            ELSE 285
        END)) AS forecast_on,
    pj.notes,
    pj.joining_id,
    pj.cancelled_on,
        CASE
            WHEN (pj.cancelled_on IS NOT NULL) THEN 'cancelled'::text
            WHEN (pj.joining_id IS NOT NULL) THEN 'joined'::text
            ELSE 'open'::text
        END AS status,
    pj.created_at,
    pj.created_by
   FROM ((((public.planned_joining pj
     JOIN public.animal d ON ((d.id = pj.dam_id)))
     LEFT JOIN public.animal s ON ((s.id = pj.sire_id)))
     LEFT JOIN public.ai_semen sem ON ((sem.id = pj.ai_semen_id)))
     LEFT JOIN public.paddock p ON ((p.id = pj.paddock_id)));


--
-- Name: v_record_history; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_record_history WITH (security_invoker='on') AS
 SELECT l.id,
    l.table_name,
    l.row_id,
    l.action,
    l.changed_at,
    COALESCE(u.display_name, 'unknown'::text) AS changed_by,
        CASE
            WHEN (l.action = 'delete'::text) THEN 'record deleted'::text
            ELSE ( SELECT string_agg(format('%s: %s → %s'::text, k.k, COALESCE((l.old_row ->> k.k), '(blank)'::text), COALESCE((l.new_row ->> k.k), '(blank)'::text)), '; '::text ORDER BY k.k) AS string_agg
               FROM jsonb_object_keys(l.new_row) k(k)
              WHERE (((l.old_row -> k.k) IS DISTINCT FROM (l.new_row -> k.k)) AND (k.k <> ALL (ARRAY['created_at'::text, 'recorded_by'::text]))))
        END AS summary,
    l.old_row
   FROM (public.record_change_log l
     LEFT JOIN public.farm_user u ON ((u.id = l.changed_by)));


--
-- Name: v_shearing; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_shearing AS
SELECT
    NULL::uuid AS id,
    NULL::date AS shorn_on,
    NULL::public.shearing_kind_t AS kind,
    NULL::text AS description,
    NULL::text AS contractor,
    NULL::numeric(6,2) AS bales,
    NULL::numeric(4,1) AS micron,
    NULL::text AS notes,
    NULL::bigint AS head,
    NULL::text AS tags,
    NULL::bigint AS edits;


--
-- Name: v_spray_report; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_spray_report WITH (security_invoker='on') AS
 SELECT se.id AS event_id,
    sp.id AS product_id,
    pk.paddock_id,
    se.applied_on,
    p.name AS paddock_name,
    p.colour AS paddock_colour,
    p.name AS place,
    pk.location_note,
    p.area_ha AS paddock_area_ha,
    pk.area_ha,
    se.crop_treated,
    se.water_rate_l_ha,
    se.method,
    se.wind_direction,
    se.wind_speed_kmh,
    se.applied_by,
    se.applied_by_contact,
    COALESCE(se.applied_by, u.display_name) AS applied_by_shown,
    COALESCE(se.applied_by_contact, u.phone) AS contact_shown,
    se.notes AS event_notes,
    ( SELECT count(*) AS count
           FROM public.spray_paddock x
          WHERE (x.spray_event_id = se.id)) AS paddocks_on_pass,
    sp.product_name,
    sp.active_ingredient,
    sp.chemical_rate,
    sp.batch_number,
    sp.graze_withhold_days,
    sp.harvest_withhold_days,
    sp.esi_days,
    sp.notes AS product_notes,
    (se.applied_on + sp.graze_withhold_days) AS safe_to_graze,
    (se.applied_on + sp.harvest_withhold_days) AS safe_to_harvest,
    ((se.applied_on + sp.graze_withhold_days) > public.farm_today()) AS graze_withheld,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'spray_event'::text) AND (l.row_id = se.id))) AS event_edits,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'spray_product'::text) AND (l.row_id = sp.id))) AS product_edits
   FROM ((((public.spray_event se
     LEFT JOIN public.spray_paddock pk ON ((pk.spray_event_id = se.id)))
     LEFT JOIN public.paddock p ON ((p.id = pk.paddock_id)))
     LEFT JOIN public.spray_product sp ON ((sp.spray_event_id = se.id)))
     LEFT JOIN public.farm_user u ON ((u.id = se.recorded_by)));


--
-- Name: v_stock_entry; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_stock_entry WITH (security_invoker='on') AS
 SELECT id AS animal_id,
    stock_code,
    origin,
    COALESCE(( SELECT min(s.effective_on) AS min
           FROM public.animal_status s
          WHERE (s.animal_id = a.id)), purchased_on, dob) AS entered_on
   FROM public.animal a
  WHERE (origin <> 'reference'::public.origin_t);


--
-- Name: v_stock_exit; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_stock_exit WITH (security_invoker='on') AS
 WITH gone AS (
         SELECT DISTINCT ON (s.animal_id) s.animal_id,
            s.effective_on,
            s.life_state
           FROM public.animal_status s
          WHERE (s.life_state <> 'alive'::public.life_state_t)
          ORDER BY s.animal_id, s.effective_on
        )
 SELECT g.animal_id,
    a.stock_code,
    g.effective_on,
    g.life_state,
    c.destination_kind,
    (c.id IS NOT NULL) AS consigned,
        CASE
            WHEN (g.life_state = 'sold'::public.life_state_t) THEN 'sale'::text
            WHEN (g.life_state = 'died'::public.life_state_t) THEN 'death'::text
            WHEN (c.destination_kind = ANY (ARRAY['abattoir'::public.destination_t, 'saleyard'::public.destination_t, 'agent'::public.destination_t, 'other'::public.destination_t])) THEN 'sale'::text
            ELSE 'ration'::text
        END AS exit_kind
   FROM ((gone g
     JOIN public.animal a ON (((a.id = g.animal_id) AND (a.origin <> 'reference'::public.origin_t))))
     LEFT JOIN LATERAL ( SELECT c_1.id,
            c_1.destination_kind
           FROM (public.consignment_animal ca
             JOIN public.consignment c_1 ON (((c_1.id = ca.consignment_id) AND (c_1.direction = 'out'::public.consign_dir_t))))
          WHERE ((ca.animal_id = g.animal_id) AND ((c_1.consigned_on >= (g.effective_on - 30)) AND (c_1.consigned_on <= (g.effective_on + 30))))
          ORDER BY c_1.consigned_on
         LIMIT 1) c ON (true));


--
-- Name: VIEW v_stock_exit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_stock_exit IS 'One row per animal that left the herd, with sale/death/ration inferred. Rations are a guess until life_state can say so.';


--
-- Name: v_stock_year_animal; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_stock_year_animal WITH (security_invoker='on') AS
 WITH span AS (
         SELECT LEAST(COALESCE(( SELECT min(animal_status.effective_on) AS min
                   FROM public.animal_status), CURRENT_DATE), COALESCE(( SELECT min(animal.dob) AS min
                   FROM public.animal
                  WHERE (animal.origin <> 'reference'::public.origin_t)), CURRENT_DATE)) AS d0,
            GREATEST(COALESCE(( SELECT max(animal_status.effective_on) AS max
                   FROM public.animal_status), CURRENT_DATE), CURRENT_DATE) AS d1
        ), years AS (
         SELECT fy.fy,
            make_date((fy.fy - 1), 7, 1) AS fy_start,
            make_date(fy.fy, 6, 30) AS fy_end
           FROM span,
            LATERAL generate_series(((EXTRACT(year FROM span.d0))::integer +
                CASE
                    WHEN (EXTRACT(month FROM span.d0) >= (7)::numeric) THEN 1
                    ELSE 0
                END), ((EXTRACT(year FROM span.d1))::integer +
                CASE
                    WHEN (EXTRACT(month FROM span.d1) >= (7)::numeric) THEN 1
                    ELSE 0
                END)) fy(fy)
        ), opening AS (
         SELECT y.fy,
            y.fy_start,
            y.fy_end,
            'opening'::text AS bucket,
            a.id AS animal_id,
            s.effective_on AS on_date,
            s.class,
            NULL::text AS detail
           FROM ((years y
             CROSS JOIN public.animal a)
             JOIN LATERAL ( SELECT animal_status.effective_on,
                    animal_status.life_state,
                    animal_status.class
                   FROM public.animal_status
                  WHERE ((animal_status.animal_id = a.id) AND (animal_status.effective_on < y.fy_start))
                  ORDER BY animal_status.effective_on DESC
                 LIMIT 1) s ON (true))
          WHERE ((a.origin <> 'reference'::public.origin_t) AND (s.life_state = 'alive'::public.life_state_t))
        ), closing AS (
         SELECT y.fy,
            y.fy_start,
            y.fy_end,
            'closing'::text AS text,
            a.id,
            s.effective_on,
            s.class,
            NULL::text AS text
           FROM ((years y
             CROSS JOIN public.animal a)
             JOIN LATERAL ( SELECT animal_status.effective_on,
                    animal_status.life_state,
                    animal_status.class
                   FROM public.animal_status
                  WHERE ((animal_status.animal_id = a.id) AND (animal_status.effective_on <= y.fy_end))
                  ORDER BY animal_status.effective_on DESC
                 LIMIT 1) s ON (true))
          WHERE ((a.origin <> 'reference'::public.origin_t) AND (s.life_state = 'alive'::public.life_state_t))
        ), entries AS (
         SELECT y.fy,
            y.fy_start,
            y.fy_end,
                CASE
                    WHEN (e.origin = 'purchased'::public.origin_t) THEN 'purchases'::text
                    ELSE 'natural_increase'::text
                END AS "case",
            e.animal_id,
            e.entered_on,
            NULL::public.animal_class_t AS animal_class_t,
            (e.origin)::text AS origin
           FROM (years y
             JOIN public.v_stock_entry e ON (((e.entered_on >= y.fy_start) AND (e.entered_on <= y.fy_end))))
        ), exits AS (
         SELECT y.fy,
            y.fy_start,
            y.fy_end,
                CASE x.exit_kind
                    WHEN 'sale'::text THEN 'sales'::text
                    WHEN 'death'::text THEN 'deaths'::text
                    ELSE 'rations'::text
                END AS "case",
            x.animal_id,
            x.effective_on,
            NULL::public.animal_class_t AS animal_class_t,
            COALESCE((x.destination_kind)::text, (x.life_state)::text) AS "coalesce"
           FROM (years y
             JOIN public.v_stock_exit x ON (((x.effective_on >= y.fy_start) AND (x.effective_on <= y.fy_end))))
        )
 SELECT u.fy,
    (((u.fy - 1) || '-'::text) || "right"((u.fy)::text, 2)) AS fy_label,
    u.fy_start,
    u.fy_end,
    u.bucket,
    u.animal_id,
    an.stock_code,
    an.name,
    an.sex,
    an.breed,
    an.dob,
    u.on_date,
    COALESCE((u.class)::text, 'unclassed'::text) AS class,
    u.detail,
    an.property_id,
    pr.pic,
    an.species
   FROM ((( SELECT opening.fy,
            opening.fy_start,
            opening.fy_end,
            opening.bucket,
            opening.animal_id,
            opening.on_date,
            opening.class,
            opening.detail
           FROM opening
        UNION ALL
         SELECT closing.fy,
            closing.fy_start,
            closing.fy_end,
            closing.text,
            closing.id,
            closing.effective_on,
            closing.class,
            closing.text_1 AS text
           FROM closing closing(fy, fy_start, fy_end, text, id, effective_on, class, text_1)
        UNION ALL
         SELECT entries.fy,
            entries.fy_start,
            entries.fy_end,
            entries."case",
            entries.animal_id,
            entries.entered_on,
            entries.animal_class_t,
            entries.origin
           FROM entries
        UNION ALL
         SELECT exits.fy,
            exits.fy_start,
            exits.fy_end,
            exits."case",
            exits.animal_id,
            exits.effective_on,
            exits.animal_class_t,
            exits."coalesce"
           FROM exits) u
     JOIN public.animal an ON ((an.id = u.animal_id)))
     LEFT JOIN public.property pr ON ((pr.id = an.property_id)));


--
-- Name: v_stock_year; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_stock_year WITH (security_invoker='on') AS
 SELECT fy,
    fy_label,
    fy_start,
    fy_end,
    species,
    (count(*) FILTER (WHERE (bucket = 'opening'::text)))::integer AS opening,
    (count(*) FILTER (WHERE (bucket = 'purchases'::text)))::integer AS purchases,
    (count(*) FILTER (WHERE (bucket = 'natural_increase'::text)))::integer AS natural_increase,
    (count(*) FILTER (WHERE (bucket = 'sales'::text)))::integer AS sales,
    (count(*) FILTER (WHERE (bucket = 'deaths'::text)))::integer AS deaths,
    (count(*) FILTER (WHERE (bucket = 'rations'::text)))::integer AS rations,
    (count(*) FILTER (WHERE (bucket = 'closing'::text)))::integer AS closing
   FROM public.v_stock_year_animal
  GROUP BY fy, fy_label, fy_start, fy_end, species
  ORDER BY species, fy;


--
-- Name: VIEW v_stock_year; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_stock_year IS 'Livestock trading account, head only, one row per species per financial year. Opening + in - out should equal closing.';


--
-- Name: v_stock_year_class; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_stock_year_class WITH (security_invoker='on') AS
 SELECT fy,
    fy_label,
    species,
    class,
    (count(*))::integer AS head
   FROM public.v_stock_year_animal
  WHERE (bucket = 'closing'::text)
  GROUP BY fy, fy_label, species, class
  ORDER BY species, fy, class;


--
-- Name: v_treatment_lpa; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_treatment_lpa AS
SELECT
    NULL::date AS treated_on,
    NULL::text AS description,
    NULL::text AS product_name,
    NULL::text AS batch_number,
    NULL::date AS product_expiry,
    NULL::text AS dose_rate,
    NULL::integer AS withholding_days,
    NULL::integer AS esi_days,
    NULL::date AS safe_for_slaughter,
    NULL::text AS treated_by,
    NULL::text AS treated_by_contact,
    NULL::text AS adverse_reaction,
    NULL::boolean AS broken_needle,
    NULL::bigint AS head_count;


--
-- Name: v_treatment_report; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_treatment_report AS
SELECT
    NULL::uuid AS id,
    NULL::date AS treated_on,
    NULL::text AS description,
    NULL::text AS product_name,
    NULL::text AS batch_number,
    NULL::date AS product_expiry,
    NULL::text AS dose_rate,
    NULL::text AS route,
    NULL::integer AS withholding_days,
    NULL::integer AS esi_days,
    NULL::date AS safe_for_slaughter,
    NULL::text AS treated_by,
    NULL::text AS treated_by_contact,
    NULL::text AS treated_by_shown,
    NULL::text AS contact_shown,
    NULL::text AS adverse_reaction,
    NULL::boolean AS broken_needle,
    NULL::text AS notes,
    NULL::bigint AS head,
    NULL::text AS tags,
    NULL::bigint AS edits,
    NULL::text AS pics,
    NULL::text AS species;


--
-- Name: record_change_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_change_log ALTER COLUMN id SET DEFAULT nextval('public.record_change_log_id_seq'::regclass);


--
-- Name: ai_semen ai_semen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_semen
    ADD CONSTRAINT ai_semen_pkey PRIMARY KEY (id);


--
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id);


--
-- Name: animal_status animal_status_animal_id_effective_on_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal_status
    ADD CONSTRAINT animal_status_animal_id_effective_on_key UNIQUE (animal_id, effective_on);


--
-- Name: animal_status animal_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal_status
    ADD CONSTRAINT animal_status_pkey PRIMARY KEY (id);


--
-- Name: calving calving_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calving
    ADD CONSTRAINT calving_pkey PRIMARY KEY (id);


--
-- Name: consignment_animal consignment_animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consignment_animal
    ADD CONSTRAINT consignment_animal_pkey PRIMARY KEY (consignment_id, animal_id);


--
-- Name: consignment consignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consignment
    ADD CONSTRAINT consignment_pkey PRIMARY KEY (id);


--
-- Name: cryo_txn cryo_txn_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_pkey PRIMARY KEY (id);


--
-- Name: embryo embryo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embryo
    ADD CONSTRAINT embryo_pkey PRIMARY KEY (id);


--
-- Name: expected_calving expected_calving_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_pkey PRIMARY KEY (id);


--
-- Name: farm_user farm_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farm_user
    ADD CONSTRAINT farm_user_pkey PRIMARY KEY (id);


--
-- Name: feed_adjustment feed_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_adjustment
    ADD CONSTRAINT feed_adjustment_pkey PRIMARY KEY (id);


--
-- Name: feed_event_animal feed_event_animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event_animal
    ADD CONSTRAINT feed_event_animal_pkey PRIMARY KEY (feed_event_id, animal_id);


--
-- Name: feed_event feed_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event
    ADD CONSTRAINT feed_event_pkey PRIMARY KEY (id);


--
-- Name: feed_event_ref feed_event_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event_ref
    ADD CONSTRAINT feed_event_ref_pkey PRIMARY KEY (feed_event_id, stock_code);


--
-- Name: feed_source feed_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_source
    ADD CONSTRAINT feed_source_pkey PRIMARY KEY (id);


--
-- Name: heartbeat heartbeat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT heartbeat_pkey PRIMARY KEY (ok);


--
-- Name: heritage heritage_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heritage
    ADD CONSTRAINT heritage_name_key UNIQUE (name);


--
-- Name: heritage heritage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heritage
    ADD CONSTRAINT heritage_pkey PRIMARY KEY (id);


--
-- Name: joining joining_dam_id_season_attempt_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_dam_id_season_attempt_key UNIQUE (dam_id, season, attempt);


--
-- Name: joining joining_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_pkey PRIMARY KEY (id);


--
-- Name: paddock_geometry_log paddock_geometry_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_geometry_log
    ADD CONSTRAINT paddock_geometry_log_pkey PRIMARY KEY (id);


--
-- Name: paddock_lineage paddock_lineage_parent_id_child_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_lineage
    ADD CONSTRAINT paddock_lineage_parent_id_child_id_key UNIQUE (parent_id, child_id);


--
-- Name: paddock_lineage paddock_lineage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_lineage
    ADD CONSTRAINT paddock_lineage_pkey PRIMARY KEY (id);


--
-- Name: paddock paddock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock
    ADD CONSTRAINT paddock_pkey PRIMARY KEY (id);


--
-- Name: paddock_stay paddock_stay_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_stay
    ADD CONSTRAINT paddock_stay_pkey PRIMARY KEY (id);


--
-- Name: planned_joining planned_joining_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_pkey PRIMARY KEY (id);


--
-- Name: property property_pic_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property
    ADD CONSTRAINT property_pic_key UNIQUE (pic);


--
-- Name: property property_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (id);


--
-- Name: record_change_log record_change_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_change_log
    ADD CONSTRAINT record_change_log_pkey PRIMARY KEY (id);


--
-- Name: shearing_animal shearing_animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shearing_animal
    ADD CONSTRAINT shearing_animal_pkey PRIMARY KEY (shearing_id, animal_id);


--
-- Name: shearing shearing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shearing
    ADD CONSTRAINT shearing_pkey PRIMARY KEY (id);


--
-- Name: spray_event spray_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_event
    ADD CONSTRAINT spray_event_pkey PRIMARY KEY (id);


--
-- Name: spray_paddock spray_paddock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_paddock
    ADD CONSTRAINT spray_paddock_pkey PRIMARY KEY (spray_event_id, paddock_id);


--
-- Name: spray_product spray_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_product
    ADD CONSTRAINT spray_product_pkey PRIMARY KEY (id);


--
-- Name: treatment_animal treatment_animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_animal
    ADD CONSTRAINT treatment_animal_pkey PRIMARY KEY (treatment_id, animal_id);


--
-- Name: treatment treatment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment
    ADD CONSTRAINT treatment_pkey PRIMARY KEY (id);


--
-- Name: user_pref user_pref_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pref
    ADD CONSTRAINT user_pref_pkey PRIMARY KEY (user_id);


--
-- Name: weight_event weight_event_animal_id_weighed_on_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_event
    ADD CONSTRAINT weight_event_animal_id_weighed_on_key UNIQUE (animal_id, weighed_on);


--
-- Name: weight_event weight_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_event
    ADD CONSTRAINT weight_event_pkey PRIMARY KEY (id);


--
-- Name: ai_semen_mark_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_semen_mark_idx ON public.ai_semen USING btree (tank, location, mark_colour);


--
-- Name: ai_semen_sire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_semen_sire_idx ON public.ai_semen USING btree (sire_id);


--
-- Name: ai_semen_where_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_semen_where_idx ON public.ai_semen USING btree (tank, location);


--
-- Name: animal_dam_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX animal_dam_idx ON public.animal USING btree (dam_id);


--
-- Name: animal_nlis_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX animal_nlis_uq ON public.animal USING btree (nlis_tag) WHERE (nlis_tag IS NOT NULL);


--
-- Name: animal_sire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX animal_sire_idx ON public.animal USING btree (sire_id);


--
-- Name: animal_species_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX animal_species_idx ON public.animal USING btree (species);


--
-- Name: animal_status_animal_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX animal_status_animal_idx ON public.animal_status USING btree (animal_id, effective_on DESC);


--
-- Name: animal_stock_code_resident_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX animal_stock_code_resident_uq ON public.animal USING btree (species, stock_code) WHERE ((origin <> 'reference'::public.origin_t) AND (stock_code IS NOT NULL));


--
-- Name: INDEX animal_stock_code_resident_uq; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.animal_stock_code_resident_uq IS 'Stock codes recycle on a 26-year letter cycle and run separately per species. Unique per species among non-reference animals.';


--
-- Name: consignment_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consignment_date_idx ON public.consignment USING btree (consigned_on DESC);


--
-- Name: consignment_nvd_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX consignment_nvd_uq ON public.consignment USING btree (nvd_serial) WHERE (nvd_serial IS NOT NULL);


--
-- Name: cryo_txn_embryo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cryo_txn_embryo_idx ON public.cryo_txn USING btree (embryo_id, on_date);


--
-- Name: cryo_txn_semen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cryo_txn_semen_idx ON public.cryo_txn USING btree (ai_semen_id, on_date);


--
-- Name: cryo_txn_unmapped_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cryo_txn_unmapped_idx ON public.cryo_txn USING btree (female_ref) WHERE ((female_id IS NULL) AND (female_ref IS NOT NULL));


--
-- Name: embryo_donor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX embryo_donor_idx ON public.embryo USING btree (donor_id);


--
-- Name: embryo_where_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX embryo_where_idx ON public.embryo USING btree (tank, location);


--
-- Name: expected_calving_joining_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX expected_calving_joining_uq ON public.expected_calving USING btree (joining_id);


--
-- Name: expected_calving_open_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX expected_calving_open_uq ON public.expected_calving USING btree (dam_id, season) WHERE (resolved_calving_id IS NULL);


--
-- Name: feed_adjustment_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX feed_adjustment_source_idx ON public.feed_adjustment USING btree (feed_source_id, adjusted_on DESC);


--
-- Name: feed_event_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX feed_event_date_idx ON public.feed_event USING btree (fed_on DESC);


--
-- Name: feed_event_paddock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX feed_event_paddock_idx ON public.feed_event USING btree (paddock_id, fed_on DESC);


--
-- Name: feed_source_open_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX feed_source_open_idx ON public.feed_source USING btree (feedstuff) WHERE (exhausted_on IS NULL);


--
-- Name: joining_dam_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX joining_dam_idx ON public.joining USING btree (dam_id);


--
-- Name: joining_paddock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX joining_paddock_idx ON public.joining USING btree (paddock_id);


--
-- Name: joining_semen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX joining_semen_idx ON public.joining USING btree (ai_semen_id);


--
-- Name: paddock_geometry_log_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paddock_geometry_log_idx ON public.paddock_geometry_log USING btree (paddock_id, valid_to DESC);


--
-- Name: paddock_lineage_child_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paddock_lineage_child_idx ON public.paddock_lineage USING btree (child_id);


--
-- Name: paddock_lineage_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paddock_lineage_parent_idx ON public.paddock_lineage USING btree (parent_id);


--
-- Name: paddock_name_live_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX paddock_name_live_uq ON public.paddock USING btree (property_id, name) WHERE (retired_on IS NULL);


--
-- Name: paddock_stay_animal_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paddock_stay_animal_idx ON public.paddock_stay USING btree (animal_id, moved_in DESC);


--
-- Name: paddock_stay_one_current; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX paddock_stay_one_current ON public.paddock_stay USING btree (animal_id) WHERE (moved_out IS NULL);


--
-- Name: paddock_stay_paddock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paddock_stay_paddock_idx ON public.paddock_stay USING btree (paddock_id) WHERE (moved_out IS NULL);


--
-- Name: planned_joining_dam_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planned_joining_dam_idx ON public.planned_joining USING btree (dam_id);


--
-- Name: planned_joining_open_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planned_joining_open_idx ON public.planned_joining USING btree (dam_id, season) WHERE ((joining_id IS NULL) AND (cancelled_on IS NULL));


--
-- Name: property_one_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX property_one_primary ON public.property USING btree ((true)) WHERE is_primary;


--
-- Name: record_change_log_row_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX record_change_log_row_idx ON public.record_change_log USING btree (table_name, row_id, changed_at DESC);


--
-- Name: record_change_log_when_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX record_change_log_when_idx ON public.record_change_log USING btree (changed_at DESC);


--
-- Name: shearing_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shearing_date_idx ON public.shearing USING btree (shorn_on DESC);


--
-- Name: spray_event_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX spray_event_date_idx ON public.spray_event USING btree (applied_on DESC);


--
-- Name: spray_paddock_paddock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX spray_paddock_paddock_idx ON public.spray_paddock USING btree (paddock_id);


--
-- Name: spray_product_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX spray_product_event_idx ON public.spray_product USING btree (spray_event_id);


--
-- Name: v_consignment _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_consignment WITH (security_invoker='on') AS
 SELECT c.id,
    c.direction,
    c.consigned_on,
    c.nvd_kind,
    c.nvd_serial,
    c.waybill_no,
    c.nlis_upload_id,
    c.nlis_sent_on,
    c.destination_kind,
    c.destination,
    c.destination_pic,
    c.counterparty,
    c.carrier,
    c.vehicle_rego,
    c.head_declared,
    c.notes,
    c.q_owned_since_birth,
    c.q_ram_fed,
    c.q_byproduct_fed,
    c.q_within_whp,
    c.q_hgp_treated,
    c.q_chemical_risk,
    c.q_movement_restriction,
    c.declared_by,
    c.declared_on,
    c.recorded_by,
    c.created_at,
    u.display_name AS recorded_by_name,
    count(ca.animal_id) AS head,
    string_agg(a.stock_code, ', '::text ORDER BY a.stock_code) AS tags,
    sum(ca.sale_weight_kg) AS total_kg,
    sum(ca.amount_ex_gst) AS total_ex_gst,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'consignment'::text) AND (l.row_id = c.id))) AS edits,
    string_agg(DISTINCT (a.species)::text, ', '::text) AS species
   FROM (((public.consignment c
     LEFT JOIN public.farm_user u ON ((u.id = c.recorded_by)))
     LEFT JOIN public.consignment_animal ca ON ((ca.consignment_id = c.id)))
     LEFT JOIN public.animal a ON ((a.id = ca.animal_id)))
  GROUP BY c.id, u.display_name;


--
-- Name: v_paddock_current _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_paddock_current WITH (security_invoker='on') AS
 SELECT p.id,
    p.name,
    p.code,
    p.colour,
    p.geometry,
    p.area_ha,
    p.notes,
    p.sort_order,
    p.retired_on,
    count(s.animal_id) AS head,
        CASE
            WHEN (p.area_ha > (0)::numeric) THEN round(((count(s.animal_id))::numeric / p.area_ha), 2)
            ELSE NULL::numeric
        END AS head_per_ha,
    min(s.moved_in) AS grazing_since,
    ((EXISTS ( SELECT 1
           FROM public.paddock_stay h
          WHERE (h.paddock_id = p.id))) OR (EXISTS ( SELECT 1
           FROM public.paddock_lineage l
          WHERE ((l.parent_id = p.id) OR (l.child_id = p.id))))) AS has_history
   FROM (public.paddock p
     LEFT JOIN public.paddock_stay s ON (((s.paddock_id = p.id) AND (s.moved_out IS NULL))))
  WHERE (p.retired_on IS NULL)
  GROUP BY p.id;


--
-- Name: v_shearing _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_shearing WITH (security_invoker='on') AS
 SELECT s.id,
    s.shorn_on,
    s.kind,
    s.description,
    s.contractor,
    s.bales,
    s.micron,
    s.notes,
    count(sa.animal_id) AS head,
    string_agg(a.stock_code, ', '::text ORDER BY a.stock_code) AS tags,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'shearing'::text) AND (l.row_id = s.id))) AS edits
   FROM ((public.shearing s
     LEFT JOIN public.shearing_animal sa ON ((sa.shearing_id = s.id)))
     LEFT JOIN public.animal a ON ((a.id = sa.animal_id)))
  GROUP BY s.id;


--
-- Name: v_treatment_lpa _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_treatment_lpa WITH (security_invoker='on') AS
 SELECT t.treated_on,
    t.description,
    t.product_name,
    t.batch_number,
    t.product_expiry,
    t.dose_rate,
    t.withholding_days,
    t.esi_days,
    t.safe_for_slaughter,
    COALESCE(t.treated_by, u.display_name) AS treated_by,
    COALESCE(t.treated_by_contact, u.phone) AS treated_by_contact,
    t.adverse_reaction,
    t.broken_needle,
    count(ta.animal_id) AS head_count
   FROM ((public.treatment t
     LEFT JOIN public.farm_user u ON ((u.id = t.recorded_by)))
     LEFT JOIN public.treatment_animal ta ON ((ta.treatment_id = t.id)))
  GROUP BY t.id, u.display_name, u.phone;


--
-- Name: v_treatment_report _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_treatment_report WITH (security_invoker='on') AS
 SELECT t.id,
    t.treated_on,
    t.description,
    t.product_name,
    t.batch_number,
    t.product_expiry,
    t.dose_rate,
    t.route,
    t.withholding_days,
    t.esi_days,
    t.safe_for_slaughter,
    t.treated_by,
    t.treated_by_contact,
    COALESCE(t.treated_by, u.display_name) AS treated_by_shown,
    COALESCE(t.treated_by_contact, u.phone) AS contact_shown,
    t.adverse_reaction,
    t.broken_needle,
    t.notes,
    count(ta.animal_id) AS head,
    string_agg(a.stock_code, ', '::text ORDER BY a.stock_code) AS tags,
    ( SELECT count(*) AS count
           FROM public.record_change_log l
          WHERE ((l.table_name = 'treatment'::text) AND (l.row_id = t.id))) AS edits,
    string_agg(DISTINCT pr.pic, ', '::text) AS pics,
    string_agg(DISTINCT (a.species)::text, ', '::text) AS species
   FROM ((((public.treatment t
     LEFT JOIN public.farm_user u ON ((u.id = t.recorded_by)))
     LEFT JOIN public.treatment_animal ta ON ((ta.treatment_id = t.id)))
     LEFT JOIN public.animal a ON ((a.id = ta.animal_id)))
     LEFT JOIN public.property pr ON ((pr.id = a.property_id)))
  GROUP BY t.id, u.display_name, u.phone;


--
-- Name: ai_semen ai_semen_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_semen_changed AFTER DELETE OR UPDATE ON public.ai_semen FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: animal animal_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER animal_changed AFTER DELETE OR UPDATE ON public.animal FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: animal animal_code_parts; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER animal_code_parts BEFORE INSERT OR UPDATE OF stock_code ON public.animal FOR EACH ROW EXECUTE FUNCTION public.animal_code_parts();


--
-- Name: calving calving_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER calving_changed AFTER DELETE OR UPDATE ON public.calving FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: calving calving_resolves; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER calving_resolves AFTER INSERT ON public.calving FOR EACH ROW EXECUTE FUNCTION public.resolve_expected_calving();


--
-- Name: consignment consignment_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER consignment_changed AFTER DELETE OR UPDATE ON public.consignment FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: cryo_txn cryo_txn_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cryo_txn_changed AFTER DELETE OR UPDATE ON public.cryo_txn FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: embryo embryo_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER embryo_changed AFTER DELETE OR UPDATE ON public.embryo FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: feed_adjustment feed_adjustment_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_adjustment_changed AFTER DELETE OR UPDATE ON public.feed_adjustment FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: feed_adjustment feed_adjustment_empties_source; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_adjustment_empties_source AFTER INSERT OR DELETE OR UPDATE ON public.feed_adjustment FOR EACH ROW EXECUTE FUNCTION public.feed_line_changed();


--
-- Name: feed_event feed_event_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_event_changed AFTER DELETE OR UPDATE ON public.feed_event FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: feed_event feed_event_empties_source; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_event_empties_source AFTER INSERT OR DELETE OR UPDATE ON public.feed_event FOR EACH ROW EXECUTE FUNCTION public.feed_line_changed();


--
-- Name: feed_source feed_source_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_source_changed AFTER DELETE OR UPDATE ON public.feed_source FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: feed_source feed_source_exhausted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_source_exhausted AFTER UPDATE ON public.feed_source FOR EACH ROW EXECUTE FUNCTION public.close_feed_runs_on_exhaustion();


--
-- Name: feed_source feed_source_quantity_set; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_source_quantity_set AFTER UPDATE OF quantity ON public.feed_source FOR EACH ROW EXECUTE FUNCTION public.feed_source_quantity_changed();


--
-- Name: joining joining_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER joining_changed AFTER DELETE OR UPDATE ON public.joining FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: joining joining_expects; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER joining_expects AFTER INSERT OR UPDATE OF due_on, outcome, dam_id, sire_id, season, cycle, attempt, joined_on ON public.joining FOR EACH ROW EXECUTE FUNCTION public.sync_expected_calving();


--
-- Name: joining joining_expects_del; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER joining_expects_del AFTER DELETE ON public.joining FOR EACH ROW EXECUTE FUNCTION public.sync_expected_calving_del();


--
-- Name: joining joining_fulfils_plan; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER joining_fulfils_plan AFTER INSERT ON public.joining FOR EACH ROW EXECUTE FUNCTION public.plan_fulfilled();


--
-- Name: paddock paddock_geometry_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER paddock_geometry_changed BEFORE UPDATE ON public.paddock FOR EACH ROW EXECUTE FUNCTION public.log_paddock_geometry();


--
-- Name: planned_joining planned_joining_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER planned_joining_changed AFTER DELETE OR UPDATE ON public.planned_joining FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: shearing shearing_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER shearing_changed AFTER DELETE OR UPDATE ON public.shearing FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: spray_event spray_event_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER spray_event_changed AFTER DELETE OR UPDATE ON public.spray_event FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: spray_product spray_product_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER spray_product_changed AFTER DELETE OR UPDATE ON public.spray_product FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: treatment treatment_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER treatment_changed AFTER DELETE OR UPDATE ON public.treatment FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: weight_event weight_event_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER weight_event_changed AFTER DELETE OR UPDATE ON public.weight_event FOR EACH ROW EXECUTE FUNCTION public.log_record_change();


--
-- Name: ai_semen ai_semen_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_semen
    ADD CONSTRAINT ai_semen_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.farm_user(id);


--
-- Name: ai_semen ai_semen_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_semen
    ADD CONSTRAINT ai_semen_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: animal animal_dam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_dam_id_fkey FOREIGN KEY (dam_id) REFERENCES public.animal(id);


--
-- Name: animal animal_heritage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_heritage_id_fkey FOREIGN KEY (heritage_id) REFERENCES public.heritage(id);


--
-- Name: animal animal_origin_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_origin_property_id_fkey FOREIGN KEY (origin_property_id) REFERENCES public.property(id);


--
-- Name: animal animal_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.property(id);


--
-- Name: animal animal_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: animal animal_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: animal_status animal_status_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal_status
    ADD CONSTRAINT animal_status_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: animal_status animal_status_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal_status
    ADD CONSTRAINT animal_status_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: calving calving_calf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calving
    ADD CONSTRAINT calving_calf_id_fkey FOREIGN KEY (calf_id) REFERENCES public.animal(id);


--
-- Name: calving calving_dam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calving
    ADD CONSTRAINT calving_dam_id_fkey FOREIGN KEY (dam_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: calving calving_joining_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calving
    ADD CONSTRAINT calving_joining_id_fkey FOREIGN KEY (joining_id) REFERENCES public.joining(id) ON DELETE SET NULL;


--
-- Name: calving calving_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calving
    ADD CONSTRAINT calving_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: consignment_animal consignment_animal_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consignment_animal
    ADD CONSTRAINT consignment_animal_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE RESTRICT;


--
-- Name: consignment_animal consignment_animal_consignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consignment_animal
    ADD CONSTRAINT consignment_animal_consignment_id_fkey FOREIGN KEY (consignment_id) REFERENCES public.consignment(id) ON DELETE CASCADE;


--
-- Name: consignment consignment_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consignment
    ADD CONSTRAINT consignment_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: cryo_txn cryo_txn_ai_semen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_ai_semen_id_fkey FOREIGN KEY (ai_semen_id) REFERENCES public.ai_semen(id) ON DELETE CASCADE;


--
-- Name: cryo_txn cryo_txn_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.farm_user(id);


--
-- Name: cryo_txn cryo_txn_embryo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_embryo_id_fkey FOREIGN KEY (embryo_id) REFERENCES public.embryo(id) ON DELETE CASCADE;


--
-- Name: cryo_txn cryo_txn_female_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_female_id_fkey FOREIGN KEY (female_id) REFERENCES public.animal(id);


--
-- Name: cryo_txn cryo_txn_joining_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryo_txn
    ADD CONSTRAINT cryo_txn_joining_id_fkey FOREIGN KEY (joining_id) REFERENCES public.joining(id) ON DELETE SET NULL;


--
-- Name: embryo embryo_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embryo
    ADD CONSTRAINT embryo_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.farm_user(id);


--
-- Name: embryo embryo_donor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embryo
    ADD CONSTRAINT embryo_donor_id_fkey FOREIGN KEY (donor_id) REFERENCES public.animal(id);


--
-- Name: embryo embryo_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embryo
    ADD CONSTRAINT embryo_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: expected_calving expected_calving_dam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_dam_id_fkey FOREIGN KEY (dam_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: expected_calving expected_calving_joining_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_joining_id_fkey FOREIGN KEY (joining_id) REFERENCES public.joining(id) ON DELETE CASCADE;


--
-- Name: expected_calving expected_calving_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: expected_calving expected_calving_resolved_calving_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_resolved_calving_id_fkey FOREIGN KEY (resolved_calving_id) REFERENCES public.calving(id);


--
-- Name: expected_calving expected_calving_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expected_calving
    ADD CONSTRAINT expected_calving_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: farm_user farm_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farm_user
    ADD CONSTRAINT farm_user_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: feed_adjustment feed_adjustment_feed_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_adjustment
    ADD CONSTRAINT feed_adjustment_feed_source_id_fkey FOREIGN KEY (feed_source_id) REFERENCES public.feed_source(id) ON DELETE CASCADE;


--
-- Name: feed_adjustment feed_adjustment_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_adjustment
    ADD CONSTRAINT feed_adjustment_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: feed_event_animal feed_event_animal_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event_animal
    ADD CONSTRAINT feed_event_animal_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: feed_event_animal feed_event_animal_feed_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event_animal
    ADD CONSTRAINT feed_event_animal_feed_event_id_fkey FOREIGN KEY (feed_event_id) REFERENCES public.feed_event(id) ON DELETE CASCADE;


--
-- Name: feed_event feed_event_feed_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event
    ADD CONSTRAINT feed_event_feed_source_id_fkey FOREIGN KEY (feed_source_id) REFERENCES public.feed_source(id) ON DELETE RESTRICT;


--
-- Name: feed_event feed_event_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event
    ADD CONSTRAINT feed_event_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id) ON DELETE RESTRICT;


--
-- Name: feed_event feed_event_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event
    ADD CONSTRAINT feed_event_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: feed_event_ref feed_event_ref_feed_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_event_ref
    ADD CONSTRAINT feed_event_ref_feed_event_id_fkey FOREIGN KEY (feed_event_id) REFERENCES public.feed_event(id) ON DELETE CASCADE;


--
-- Name: feed_source feed_source_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_source
    ADD CONSTRAINT feed_source_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: joining joining_ai_semen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_ai_semen_id_fkey FOREIGN KEY (ai_semen_id) REFERENCES public.ai_semen(id);


--
-- Name: joining joining_dam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_dam_id_fkey FOREIGN KEY (dam_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: joining joining_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id);


--
-- Name: joining joining_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: joining joining_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joining
    ADD CONSTRAINT joining_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: paddock_geometry_log paddock_geometry_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_geometry_log
    ADD CONSTRAINT paddock_geometry_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.farm_user(id);


--
-- Name: paddock_geometry_log paddock_geometry_log_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_geometry_log
    ADD CONSTRAINT paddock_geometry_log_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id) ON DELETE CASCADE;


--
-- Name: paddock_lineage paddock_lineage_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_lineage
    ADD CONSTRAINT paddock_lineage_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.paddock(id) ON DELETE RESTRICT;


--
-- Name: paddock_lineage paddock_lineage_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_lineage
    ADD CONSTRAINT paddock_lineage_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.paddock(id) ON DELETE RESTRICT;


--
-- Name: paddock_lineage paddock_lineage_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_lineage
    ADD CONSTRAINT paddock_lineage_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: paddock paddock_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock
    ADD CONSTRAINT paddock_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.property(id);


--
-- Name: paddock paddock_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock
    ADD CONSTRAINT paddock_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: paddock_stay paddock_stay_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_stay
    ADD CONSTRAINT paddock_stay_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: paddock_stay paddock_stay_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_stay
    ADD CONSTRAINT paddock_stay_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id) ON DELETE RESTRICT;


--
-- Name: paddock_stay paddock_stay_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddock_stay
    ADD CONSTRAINT paddock_stay_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: planned_joining planned_joining_ai_semen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_ai_semen_id_fkey FOREIGN KEY (ai_semen_id) REFERENCES public.ai_semen(id);


--
-- Name: planned_joining planned_joining_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.farm_user(id);


--
-- Name: planned_joining planned_joining_dam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_dam_id_fkey FOREIGN KEY (dam_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: planned_joining planned_joining_joining_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_joining_id_fkey FOREIGN KEY (joining_id) REFERENCES public.joining(id) ON DELETE SET NULL;


--
-- Name: planned_joining planned_joining_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id);


--
-- Name: planned_joining planned_joining_sire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_joining
    ADD CONSTRAINT planned_joining_sire_id_fkey FOREIGN KEY (sire_id) REFERENCES public.animal(id);


--
-- Name: record_change_log record_change_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_change_log
    ADD CONSTRAINT record_change_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.farm_user(id);


--
-- Name: shearing_animal shearing_animal_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shearing_animal
    ADD CONSTRAINT shearing_animal_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: shearing_animal shearing_animal_shearing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shearing_animal
    ADD CONSTRAINT shearing_animal_shearing_id_fkey FOREIGN KEY (shearing_id) REFERENCES public.shearing(id) ON DELETE CASCADE;


--
-- Name: shearing shearing_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shearing
    ADD CONSTRAINT shearing_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: spray_event spray_event_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_event
    ADD CONSTRAINT spray_event_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: spray_paddock spray_paddock_paddock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_paddock
    ADD CONSTRAINT spray_paddock_paddock_id_fkey FOREIGN KEY (paddock_id) REFERENCES public.paddock(id) ON DELETE RESTRICT;


--
-- Name: spray_paddock spray_paddock_spray_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_paddock
    ADD CONSTRAINT spray_paddock_spray_event_id_fkey FOREIGN KEY (spray_event_id) REFERENCES public.spray_event(id) ON DELETE CASCADE;


--
-- Name: spray_product spray_product_spray_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spray_product
    ADD CONSTRAINT spray_product_spray_event_id_fkey FOREIGN KEY (spray_event_id) REFERENCES public.spray_event(id) ON DELETE CASCADE;


--
-- Name: treatment_animal treatment_animal_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_animal
    ADD CONSTRAINT treatment_animal_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: treatment_animal treatment_animal_treatment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_animal
    ADD CONSTRAINT treatment_animal_treatment_id_fkey FOREIGN KEY (treatment_id) REFERENCES public.treatment(id) ON DELETE CASCADE;


--
-- Name: treatment treatment_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment
    ADD CONSTRAINT treatment_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: user_pref user_pref_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pref
    ADD CONSTRAINT user_pref_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.farm_user(id) ON DELETE CASCADE;


--
-- Name: weight_event weight_event_animal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_event
    ADD CONSTRAINT weight_event_animal_id_fkey FOREIGN KEY (animal_id) REFERENCES public.animal(id) ON DELETE CASCADE;


--
-- Name: weight_event weight_event_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_event
    ADD CONSTRAINT weight_event_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.farm_user(id);


--
-- Name: ai_semen; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_semen ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_semen ai_semen_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_semen_delete ON public.ai_semen FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: ai_semen ai_semen_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_semen_insert ON public.ai_semen FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: ai_semen ai_semen_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_semen_read ON public.ai_semen FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: ai_semen ai_semen_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_semen_update ON public.ai_semen FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: ai_semen ai_semen_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_semen_write ON public.ai_semen USING ((EXISTS ( SELECT 1
   FROM public.farm_user u
  WHERE ((u.id = auth.uid()) AND u.active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.farm_user u
  WHERE ((u.id = auth.uid()) AND u.active))));


--
-- Name: animal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.animal ENABLE ROW LEVEL SECURITY;

--
-- Name: animal animal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_delete ON public.animal FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: animal animal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_insert ON public.animal FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: animal animal_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_read ON public.animal FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: animal_status; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.animal_status ENABLE ROW LEVEL SECURITY;

--
-- Name: animal_status animal_status_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_status_delete ON public.animal_status FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: animal_status animal_status_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_status_insert ON public.animal_status FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: animal_status animal_status_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_status_read ON public.animal_status FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: animal_status animal_status_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_status_update ON public.animal_status FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: animal animal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY animal_update ON public.animal FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: calving; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.calving ENABLE ROW LEVEL SECURITY;

--
-- Name: calving calving_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calving_delete ON public.calving FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: calving calving_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calving_insert ON public.calving FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: calving calving_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calving_read ON public.calving FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: calving calving_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calving_update ON public.calving FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: consignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.consignment ENABLE ROW LEVEL SECURITY;

--
-- Name: consignment_animal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.consignment_animal ENABLE ROW LEVEL SECURITY;

--
-- Name: consignment_animal consignment_animal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_animal_delete ON public.consignment_animal FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: consignment_animal consignment_animal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_animal_insert ON public.consignment_animal FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: consignment_animal consignment_animal_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_animal_read ON public.consignment_animal FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: consignment_animal consignment_animal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_animal_update ON public.consignment_animal FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: consignment consignment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_delete ON public.consignment FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: consignment consignment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_insert ON public.consignment FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: consignment consignment_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_read ON public.consignment FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: consignment consignment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY consignment_update ON public.consignment FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: cryo_txn; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cryo_txn ENABLE ROW LEVEL SECURITY;

--
-- Name: cryo_txn cryo_txn_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cryo_txn_delete ON public.cryo_txn FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: cryo_txn cryo_txn_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cryo_txn_insert ON public.cryo_txn FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: cryo_txn cryo_txn_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cryo_txn_read ON public.cryo_txn FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: cryo_txn cryo_txn_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cryo_txn_update ON public.cryo_txn FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: embryo; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.embryo ENABLE ROW LEVEL SECURITY;

--
-- Name: embryo embryo_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY embryo_delete ON public.embryo FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: embryo embryo_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY embryo_insert ON public.embryo FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: embryo embryo_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY embryo_read ON public.embryo FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: embryo embryo_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY embryo_update ON public.embryo FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: expected_calving; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.expected_calving ENABLE ROW LEVEL SECURITY;

--
-- Name: expected_calving expected_calving_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY expected_calving_delete ON public.expected_calving FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: expected_calving expected_calving_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY expected_calving_insert ON public.expected_calving FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: expected_calving expected_calving_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY expected_calving_read ON public.expected_calving FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: expected_calving expected_calving_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY expected_calving_update ON public.expected_calving FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: farm_user; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.farm_user ENABLE ROW LEVEL SECURITY;

--
-- Name: farm_user farm_user_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY farm_user_manage ON public.farm_user TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t)) WITH CHECK ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: farm_user farm_user_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY farm_user_read ON public.farm_user FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_adjustment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feed_adjustment ENABLE ROW LEVEL SECURITY;

--
-- Name: feed_adjustment feed_adjustment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_adjustment_delete ON public.feed_adjustment FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: feed_adjustment feed_adjustment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_adjustment_insert ON public.feed_adjustment FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: feed_adjustment feed_adjustment_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_adjustment_read ON public.feed_adjustment FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_adjustment feed_adjustment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_adjustment_update ON public.feed_adjustment FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: feed_event; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feed_event ENABLE ROW LEVEL SECURITY;

--
-- Name: feed_event_animal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feed_event_animal ENABLE ROW LEVEL SECURITY;

--
-- Name: feed_event_animal feed_event_animal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_animal_delete ON public.feed_event_animal FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: feed_event_animal feed_event_animal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_animal_insert ON public.feed_event_animal FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: feed_event_animal feed_event_animal_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_animal_read ON public.feed_event_animal FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_event_animal feed_event_animal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_animal_update ON public.feed_event_animal FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: feed_event feed_event_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_delete ON public.feed_event FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: feed_event feed_event_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_insert ON public.feed_event FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: feed_event feed_event_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_read ON public.feed_event FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_event_ref; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feed_event_ref ENABLE ROW LEVEL SECURITY;

--
-- Name: feed_event_ref feed_event_ref_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_ref_delete ON public.feed_event_ref FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: feed_event_ref feed_event_ref_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_ref_insert ON public.feed_event_ref FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: feed_event_ref feed_event_ref_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_ref_read ON public.feed_event_ref FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_event_ref feed_event_ref_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_ref_update ON public.feed_event_ref FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: feed_event feed_event_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_event_update ON public.feed_event FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: feed_source; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feed_source ENABLE ROW LEVEL SECURITY;

--
-- Name: feed_source feed_source_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_source_delete ON public.feed_source FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: feed_source feed_source_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_source_insert ON public.feed_source FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: feed_source feed_source_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_source_read ON public.feed_source FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: feed_source feed_source_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feed_source_update ON public.feed_source FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: heartbeat; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.heartbeat ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat heartbeat_anon; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY heartbeat_anon ON public.heartbeat FOR SELECT TO authenticated, anon USING (true);


--
-- Name: heritage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.heritage ENABLE ROW LEVEL SECURITY;

--
-- Name: heritage heritage_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY heritage_delete ON public.heritage FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: heritage heritage_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY heritage_insert ON public.heritage FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: heritage heritage_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY heritage_read ON public.heritage FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: heritage heritage_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY heritage_update ON public.heritage FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: joining; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.joining ENABLE ROW LEVEL SECURITY;

--
-- Name: joining joining_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY joining_delete ON public.joining FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: joining joining_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY joining_insert ON public.joining FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: joining joining_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY joining_read ON public.joining FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: joining joining_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY joining_update ON public.joining FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: paddock; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.paddock ENABLE ROW LEVEL SECURITY;

--
-- Name: paddock paddock_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_delete ON public.paddock FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: paddock_geometry_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.paddock_geometry_log ENABLE ROW LEVEL SECURITY;

--
-- Name: paddock_geometry_log paddock_geometry_log_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_geometry_log_delete ON public.paddock_geometry_log FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: paddock_geometry_log paddock_geometry_log_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_geometry_log_insert ON public.paddock_geometry_log FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: paddock_geometry_log paddock_geometry_log_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_geometry_log_read ON public.paddock_geometry_log FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: paddock paddock_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_insert ON public.paddock FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: paddock_lineage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.paddock_lineage ENABLE ROW LEVEL SECURITY;

--
-- Name: paddock_lineage paddock_lineage_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_lineage_delete ON public.paddock_lineage FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: paddock_lineage paddock_lineage_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_lineage_insert ON public.paddock_lineage FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: paddock_lineage paddock_lineage_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_lineage_read ON public.paddock_lineage FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: paddock paddock_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_read ON public.paddock FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: paddock_stay; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.paddock_stay ENABLE ROW LEVEL SECURITY;

--
-- Name: paddock_stay paddock_stay_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_stay_delete ON public.paddock_stay FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: paddock_stay paddock_stay_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_stay_insert ON public.paddock_stay FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: paddock_stay paddock_stay_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_stay_read ON public.paddock_stay FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: paddock_stay paddock_stay_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_stay_update ON public.paddock_stay FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: paddock paddock_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paddock_update ON public.paddock FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: planned_joining; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.planned_joining ENABLE ROW LEVEL SECURITY;

--
-- Name: planned_joining planned_joining_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY planned_joining_delete ON public.planned_joining FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: planned_joining planned_joining_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY planned_joining_insert ON public.planned_joining FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: planned_joining planned_joining_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY planned_joining_read ON public.planned_joining FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: planned_joining planned_joining_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY planned_joining_update ON public.planned_joining FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: property; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.property ENABLE ROW LEVEL SECURITY;

--
-- Name: property property_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY property_delete ON public.property FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: property property_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY property_insert ON public.property FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: property property_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY property_read ON public.property FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: property property_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY property_update ON public.property FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: record_change_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.record_change_log ENABLE ROW LEVEL SECURITY;

--
-- Name: record_change_log record_change_log_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY record_change_log_read ON public.record_change_log FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: shearing; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shearing ENABLE ROW LEVEL SECURITY;

--
-- Name: shearing_animal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shearing_animal ENABLE ROW LEVEL SECURITY;

--
-- Name: shearing_animal shearing_animal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_animal_delete ON public.shearing_animal FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: shearing_animal shearing_animal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_animal_insert ON public.shearing_animal FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: shearing_animal shearing_animal_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_animal_read ON public.shearing_animal FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: shearing_animal shearing_animal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_animal_update ON public.shearing_animal FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: shearing shearing_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_delete ON public.shearing FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: shearing shearing_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_insert ON public.shearing FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: shearing shearing_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_read ON public.shearing FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: shearing shearing_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY shearing_update ON public.shearing FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: spray_event; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.spray_event ENABLE ROW LEVEL SECURITY;

--
-- Name: spray_event spray_event_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_event_delete ON public.spray_event FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: spray_event spray_event_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_event_insert ON public.spray_event FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: spray_event spray_event_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_event_read ON public.spray_event FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: spray_event spray_event_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_event_update ON public.spray_event FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: spray_paddock; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.spray_paddock ENABLE ROW LEVEL SECURITY;

--
-- Name: spray_paddock spray_paddock_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_paddock_delete ON public.spray_paddock FOR DELETE TO authenticated USING (public.can_write());


--
-- Name: spray_paddock spray_paddock_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_paddock_insert ON public.spray_paddock FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: spray_paddock spray_paddock_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_paddock_read ON public.spray_paddock FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: spray_paddock spray_paddock_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_paddock_update ON public.spray_paddock FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: spray_product; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.spray_product ENABLE ROW LEVEL SECURITY;

--
-- Name: spray_product spray_product_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_product_delete ON public.spray_product FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: spray_product spray_product_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_product_insert ON public.spray_product FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: spray_product spray_product_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_product_read ON public.spray_product FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: spray_product spray_product_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY spray_product_update ON public.spray_product FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: treatment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.treatment ENABLE ROW LEVEL SECURITY;

--
-- Name: treatment_animal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.treatment_animal ENABLE ROW LEVEL SECURITY;

--
-- Name: treatment_animal treatment_animal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_animal_delete ON public.treatment_animal FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: treatment_animal treatment_animal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_animal_insert ON public.treatment_animal FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: treatment_animal treatment_animal_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_animal_read ON public.treatment_animal FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: treatment_animal treatment_animal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_animal_update ON public.treatment_animal FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: treatment treatment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_delete ON public.treatment FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: treatment treatment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_insert ON public.treatment FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: treatment treatment_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_read ON public.treatment FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: treatment treatment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY treatment_update ON public.treatment FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- Name: user_pref; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_pref ENABLE ROW LEVEL SECURITY;

--
-- Name: user_pref user_pref_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_pref_own ON public.user_pref TO authenticated USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: weight_event; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.weight_event ENABLE ROW LEVEL SECURITY;

--
-- Name: weight_event weight_event_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY weight_event_delete ON public.weight_event FOR DELETE TO authenticated USING ((public.my_role() = 'owner'::public.farm_role_t));


--
-- Name: weight_event weight_event_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY weight_event_insert ON public.weight_event FOR INSERT TO authenticated WITH CHECK (public.can_write());


--
-- Name: weight_event weight_event_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY weight_event_read ON public.weight_event FOR SELECT TO authenticated USING (public.can_read());


--
-- Name: weight_event weight_event_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY weight_event_update ON public.weight_event FOR UPDATE TO authenticated USING (public.can_write()) WITH CHECK (public.can_write());


--
-- PostgreSQL database dump complete
--

\unrestrict Qqwfq3B7RJ6PK1qJCGEsxUETcBhqRyguLYT3kzTe8PKFVmuVnivTpSwfSxihMKf

