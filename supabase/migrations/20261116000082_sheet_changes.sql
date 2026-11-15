-- ============================================================
-- 82. A cut sheet, as changed for one order.
--
-- A pack's cut sheet is the product's: every 1/2 lamb is cut the same
-- way. But one customer does not want the bones, another wants the leg
-- butterflied, and the butcher has something to say about a box —
-- short on mince, a shank swapped for chops. Until now the only way to
-- say any of it was to give the order line a whole sheet of its own in
-- Sales, which the butcher could not do at all, and which goes wrong
-- for a pack that is the standard sheet twice over (a 24 kg pack with
-- its own sheet is that sheet split between two boxes, not two of it).
--
-- So the sheet stays the product's, and the order line carries only
-- what is different about it:
--
--   order_line.sheet_marks      what is changed on the sheet, by line:
--                               not required (and why), or an
--                               instruction reworded.
--   order_line.butcher_comment  what the butcher has to say about the
--                               pack, and when and by whom it was said.
--
-- A change is filed under the line's name on the sheet ("Lamb Bones",
-- and which one if two lines share a name), not its position: add a
-- line to the product's sheet next month and every order's changes are
-- still on the lines they were made on. A change whose line the sheet
-- no longer has is not dropped quietly — the sheet says there is one,
-- and what it was, until someone clears it.
--
-- Who may do what, on the Butcher sheets page:
--
--   reword an instruction    the farm (owner, manager) and the butcher
--   butcher's comments       the farm and the butcher
--   mark a line not required the farm only
--   the farm's note to the   the farm only (order_line.butcher_note,
--   butcher                  as it has always been in Sales)
--
-- A butcher only ever for a harvest released to them. The pack's name
-- on a line (its first column) is not changed by anyone here: it is
-- what the change is filed under.
--
-- It is per order line, like the weight and the tick: an order for two
-- packs on one line, or a pack that fills two boxes, is changed once
-- and every box of it shows the change.
--
-- butcher_sheet() is replaced whole, as 77, with each box's changes
-- and comment. Changes are logged like every other on order_line (70).
--
-- Safe to run more than once.
-- ============================================================

alter table order_line add column if not exists sheet_marks        jsonb;
alter table order_line add column if not exists butcher_comment    text;
alter table order_line add column if not exists butcher_comment_at timestamptz;
alter table order_line add column if not exists butcher_comment_by uuid references farm_user(id) on delete set null;

alter table order_line drop constraint if exists order_line_sheet_marks_ck;
alter table order_line add constraint order_line_sheet_marks_ck
  check (sheet_marks is null or jsonb_typeof(sheet_marks) = 'object');

comment on column order_line.sheet_marks is
  'What is different about the cut sheet for this order: {"<which>|<line name>": {"row": name as it read, "off": true, "why": text, "set": {column heading: text}, "by": farm|butcher, "at": when}}. Read it through sheet_marks_on().';
comment on column order_line.butcher_comment is
  'What the butcher has to say about this pack. Not the farm''s note to the butcher: that is butcher_note.';

-- ------------------------------------------------------------
-- A sheet's lines, each with the key its changes are filed under:
-- which of the lines of that name it is, then the name in lower case
-- with its spaces evened out. "1|lamb bones".
-- ------------------------------------------------------------

create or replace function sheet_row_keys(p_sheet jsonb) returns table (i int, name text, key text)
language sql immutable set search_path = public as $$
  select (r.ord - 1)::int,
         r.v ->> 0,
         row_number() over (partition by k.t order by r.ord) || '|' || k.t
    from jsonb_array_elements(case when jsonb_typeof(p_sheet -> 'rows') = 'array'
                                   then p_sheet -> 'rows' else '[]'::jsonb end) with ordinality as r(v, ord)
   cross join lateral (
     select lower(regexp_replace(btrim(coalesce(case when jsonb_typeof(r.v) = 'array' then r.v ->> 0 end, '')),
                                 '\s+', ' ', 'g')) as t) k
$$;

-- ------------------------------------------------------------
-- An order line's changes, laid over a sheet.
--
--   rows   {"<line number, from 0>": {off, why, set, by, at}} for
--          every change whose line the sheet has
--   lost   [{row, off, why, set}] for every change it has not: the
--          line was renamed or taken off the sheet, or a column was
-- ------------------------------------------------------------

create or replace function sheet_marks_on(p_sheet jsonb, p_marks jsonb) returns jsonb
language sql immutable set search_path = public as $$
  with cols as (
         select array(select jsonb_array_elements_text(
                  case when jsonb_typeof(p_sheet -> 'columns') = 'array'
                       then p_sheet -> 'columns' else '[]'::jsonb end)) as c),
       j as (
         select e.value as v, rk.i,
                (select coalesce(jsonb_object_agg(s.key, s.value) filter (where s.key = any (cols.c)), '{}'::jsonb)
                   from jsonb_each(case when jsonb_typeof(e.value -> 'set') = 'object'
                                        then e.value -> 'set' else '{}'::jsonb end) s) as kept,
                (select coalesce(jsonb_object_agg(s.key, s.value) filter (where s.key <> all (cols.c)), '{}'::jsonb)
                   from jsonb_each(case when jsonb_typeof(e.value -> 'set') = 'object'
                                        then e.value -> 'set' else '{}'::jsonb end) s) as gone
           from jsonb_each(case when jsonb_typeof(p_marks) = 'object' then p_marks else '{}'::jsonb end) e
           left join sheet_row_keys(p_sheet) rk on rk.key = e.key
          cross join cols)
  select jsonb_build_object(
    'rows', coalesce((select jsonb_object_agg(j.i::text, (j.v - 'set' - 'row') || jsonb_build_object('set', j.kept))
                        from j
                       where j.i is not null and (j.v ? 'off' or j.kept <> '{}'::jsonb)), '{}'::jsonb),
    'lost', coalesce((select jsonb_agg(x.v)
                        from (select j.v - 'by' - 'at' as v from j where j.i is null
                              union all
                              select jsonb_build_object('row', j.v ->> 'row', 'set', j.gone)
                                from j where j.i is not null and j.gone <> '{}'::jsonb) x), '[]'::jsonb));
$$;

revoke execute on function sheet_row_keys(jsonb)        from public, anon;
revoke execute on function sheet_marks_on(jsonb, jsonb) from public, anon;
grant  execute on function sheet_row_keys(jsonb)        to authenticated;
grant  execute on function sheet_marks_on(jsonb, jsonb) to authenticated;

-- ------------------------------------------------------------
-- Changing one pack's sheet.
--
-- p_change says only what is to change; anything it leaves out is left
-- as it is, so the farm marking a line and the butcher rewording
-- another at the same moment do not undo each other.
--
--   cells      [{i, row, column, text}]  reword one instruction. i is
--              the line's number on the sheet (from 0) and row its
--              name as the page showed it: if they no longer agree the
--              sheet has changed under the page, and nothing is saved.
--              Text the same as the sheet's own puts it back to
--              standard.
--   strikes    [{i, row, off, why}]      not required, or required
--              again. The farm only.
--   comment    text                      the butcher's comments. Blank
--              clears them.
--   note       text                      the farm's note to the
--              butcher for this pack. The farm only.
--   drop_lost  true                      clear the changes whose line
--              or column the sheet no longer has. The farm only.
--
-- Returns the pack as it now stands: {marks, butcher_comment,
-- comment_at, comment_by, butcher_note}.
-- ------------------------------------------------------------

create or replace function butcher_sheet_change(p_line uuid, p_change jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  fid       uuid := current_farm();
  role      text := my_role()::text;
  farm_side boolean;
  l         order_line;
  sheet     jsonb;
  cols      text[];
  marks     jsonb;
  stamp     jsonb;
  part      text;
  c         jsonb;
  ri        int;
  k         text;      -- the key the line's changes are filed under
  nm        text;      -- the line's name, as the sheet has it
  m         jsonb;
  col       text;
  ci        int;
  txt       text;
  was       text;
begin
  if fid is null or role is null or role not in ('butcher', 'owner', 'manager') then
    raise exception 'Not allowed';
  end if;
  farm_side := role <> 'butcher';
  if jsonb_typeof(p_change) is distinct from 'object' then
    raise exception 'Nothing to change';
  end if;

  -- The pack: on this farm, on a harvest, on an order that still stands;
  -- and for a butcher, on a harvest released to them.
  select ol.* into l
    from order_line ol
    join customer_order o on o.id = ol.order_id
    join harvest h        on h.id = o.harvest_id
   where ol.id = p_line and ol.farm_id = fid and ol.for_butcher and o.status <> 'cancelled'
     and (farm_side or h.butcher_released_at is not null)
     for update of ol;
  if not found then
    raise exception 'No such pack';
  end if;

  select coalesce(l.cut_sheet, po.cut_sheet, pr.cut_sheet) into sheet
    from (select 1) one
    left join product_option po on po.id = l.product_option_id
    left join product pr        on pr.id = po.product_id;
  cols  := array(select jsonb_array_elements_text(
             case when jsonb_typeof(sheet -> 'columns') = 'array' then sheet -> 'columns' else '[]'::jsonb end));
  marks := case when jsonb_typeof(l.sheet_marks) = 'object' then l.sheet_marks else '{}'::jsonb end;
  stamp := jsonb_build_object('by', case when farm_side then 'farm' else 'butcher' end, 'at', now());

  if (p_change ? 'strikes' or p_change ? 'note' or coalesce(p_change -> 'drop_lost', 'false'::jsonb) = 'true'::jsonb)
     and not farm_side then
    raise exception 'Only the farm can mark a line as not required or change its note';
  end if;

  -- Clearing what the sheet no longer has comes first, so that a change
  -- made in the same save is not mistaken for one of them.
  if coalesce(p_change -> 'drop_lost', 'false'::jsonb) = 'true'::jsonb then
    select coalesce(jsonb_object_agg(e.key, x.v) filter (where x.v ? 'off' or x.v -> 'set' <> '{}'::jsonb), '{}'::jsonb)
      into marks
      from jsonb_each(marks) e
      join sheet_row_keys(sheet) rk on rk.key = e.key
     cross join lateral (
       select e.value || jsonb_build_object('set', coalesce((
                select jsonb_object_agg(s.key, s.value)
                  from jsonb_each(case when jsonb_typeof(e.value -> 'set') = 'object'
                                       then e.value -> 'set' else '{}'::jsonb end) s
                 where s.key = any (cols)), '{}'::jsonb)) as v) x;
  end if;

  foreach part in array array['strikes', 'cells'] loop
    continue when not p_change ? part;
    if jsonb_typeof(p_change -> part) <> 'array' or jsonb_array_length(p_change -> part) > 200 then
      raise exception 'Nothing to change';
    end if;
    for c in select * from jsonb_array_elements(p_change -> part) loop
      if jsonb_typeof(c -> 'i') is distinct from 'number' or (c ->> 'i') !~ '^[0-9]{1,4}$' then
        raise exception 'Nothing to change';
      end if;
      ri := (c ->> 'i')::int;
      k := null;
      select rk.key, rk.name into k, nm from sheet_row_keys(sheet) rk where rk.i = ri;
      if k is null or coalesce(nm, '') <> coalesce(c ->> 'row', '') then
        raise exception 'This sheet has been changed since the page was opened. Reload the page and make the change again.';
      end if;
      m := coalesce(marks -> k, '{}'::jsonb);

      if part = 'strikes' then
        if coalesce(c -> 'off', 'false'::jsonb) = 'true'::jsonb then
          txt := nullif(btrim(regexp_replace(coalesce(c ->> 'why', ''), '\s+', ' ', 'g')), '');
          if length(txt) > 200 then
            raise exception 'That reason is too long: 200 characters at most';
          end if;
          m := (m - 'why') || jsonb_build_object('row', nm, 'off', true)
               || case when txt is null then '{}'::jsonb else jsonb_build_object('why', txt) end || stamp;
        else
          m := (m - 'off' - 'why') || stamp;
        end if;
      else
        col := c ->> 'column';
        ci  := array_position(cols, col);
        if ci is null or ci = 1 then
          raise exception 'That part of the sheet cannot be changed here';
        end if;
        txt := btrim(regexp_replace(coalesce(c ->> 'text', ''), '\s+', ' ', 'g'));
        if length(txt) > 300 then
          raise exception 'That instruction is too long: 300 characters at most';
        end if;
        was := btrim(regexp_replace(coalesce(sheet -> 'rows' -> ri ->> (ci - 1), ''), '\s+', ' ', 'g'));
        if txt = was then
          m := m #- array['set', col];                    -- back to standard
        else
          m := m || jsonb_build_object('row', nm,
                      'set', coalesce(m -> 'set', '{}'::jsonb) || jsonb_build_object(col, txt)) || stamp;
        end if;
      end if;

      -- Nothing left that differs from the sheet: the line is forgotten.
      if m ? 'off' or coalesce(m -> 'set', '{}'::jsonb) <> '{}'::jsonb then
        marks := marks || jsonb_build_object(k, m);
      else
        marks := marks - k;
      end if;
    end loop;
  end loop;

  if p_change ? 'comment' then
    txt := nullif(btrim(coalesce(p_change ->> 'comment', '')), '');
    if length(txt) > 2000 then
      raise exception 'That comment is too long: 2,000 characters at most';
    end if;
    if txt is distinct from l.butcher_comment then
      l.butcher_comment    := txt;
      l.butcher_comment_at := case when txt is not null then now() end;
      l.butcher_comment_by := case when txt is not null then auth.uid() end;
    end if;
  end if;

  if p_change ? 'note' then
    txt := nullif(btrim(coalesce(p_change ->> 'note', '')), '');
    if length(txt) > 2000 then
      raise exception 'That note is too long: 2,000 characters at most';
    end if;
    l.butcher_note := txt;
  end if;

  update order_line
     set sheet_marks        = nullif(marks, '{}'::jsonb),
         butcher_comment    = l.butcher_comment,
         butcher_comment_at = l.butcher_comment_at,
         butcher_comment_by = l.butcher_comment_by,
         butcher_note       = l.butcher_note
   where id = l.id;

  return jsonb_build_object(
    'marks', sheet_marks_on(sheet, marks),
    'butcher_comment', l.butcher_comment,
    'comment_at', l.butcher_comment_at,
    'comment_by', (select case when fm.role::text = 'butcher' then 'butcher' else 'farm' end
                     from farm_member fm where fm.user_id = l.butcher_comment_by and fm.farm_id = fid),
    'butcher_note', l.butcher_note);
end $$;

revoke execute on function butcher_sheet_change(uuid, jsonb) from public, anon;
grant  execute on function butcher_sheet_change(uuid, jsonb) to authenticated;

-- ------------------------------------------------------------
-- butcher_sheet(): as 77; each box carries what is changed on its
-- sheet for this order ("marks"), and the butcher's comments
-- ------------------------------------------------------------

create or replace function butcher_sheet(p_harvest uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  fid  uuid := current_farm();
  role text := my_role()::text;
  h    harvest;
begin
  if fid is null or role is null then
    raise exception 'Sign in first';
  end if;
  select * into h from harvest where id = p_harvest and farm_id = fid;
  if not found or (role = 'butcher' and h.butcher_released_at is null) then
    raise exception 'That harvest is not available';
  end if;

  return jsonb_build_object(
    'role', role,
    'farm', (select jsonb_build_object('name', f.name, 'logo_url', f.logo_url,
                                       'phone', b.phone, 'email', b.email)
               from farm f left join farm_business b on b.farm_id = f.id
              where f.id = fid),
    'harvest', jsonb_build_object(
      'id', h.id, 'code', h.code, 'kind', h.kind, 'title', h.title,
      'harvest_on', h.harvest_on, 'butcher_on', h.butcher_on, 'pickup_on', h.pickup_on,
      'delivery_on', h.delivery_on, 'interstate_on', h.interstate_on,
      'interstate_note', h.interstate_note, 'butcher_name', h.butcher_name,
      'pickup_place', h.pickup_place, 'head', h.head, 'carcass_kg', h.carcass_kg,
      'butcher_note', h.butcher_note, 'released', h.butcher_released_at is not null),
    'boxes', coalesce((
      select jsonb_agg(to_jsonb(b) order by b.box_no)
        from (
          select row_number() over (order by o.order_no, l.sort, l.created_at, g.n, k.c) as box_no,
                 row_number() over (partition by o.id order by l.sort, l.created_at, g.n, k.c) as idx,
                 count(*)     over (partition by o.id)                              as of,
                 l.id                                    as line_id,
                 order_ref(fb.order_prefix, o.order_no)  as order_ref,
                 c.name                                  as customer,
                 o.fulfilment,
                 l.description                           as pack,
                 g.n                                     as pack_no,     -- which of the line's packs
                 k.c                                     as carton,      -- which of that pack's boxes
                 x.cartons,                                              -- how many boxes that pack fills
                 round(l.size_kg / x.cartons, 2)         as size_kg,     -- in this box
                 l.qty                                   as line_qty,
                 l.packed,
                 l.actual_kg,
                 l.butcher_note,
                 l.answers,
                 x.sheet                                 as cut_sheet,
                 sheet_marks_on(x.sheet, l.sheet_marks)  as marks,       -- what is changed on it for this order (82)
                 l.butcher_comment,
                 l.butcher_comment_at                    as comment_at,
                 (select case when fm.role::text = 'butcher' then 'butcher' else 'farm' end
                    from farm_member fm
                   where fm.user_id = l.butcher_comment_by and fm.farm_id = l.farm_id) as comment_by,
                 case when x.own_sheet then 1
                      else round(coalesce(po.sheet_multiple, 1) / x.cartons, 2) end as sheet_multiple,
                 (x.own_sheet and x.cartons > 1)         as split_boxes,
                 coalesce(nullif(o.ship_name, ''), c.name)         as to_name,
                 coalesce(nullif(o.ship_phone, ''), c.phone)       as to_phone,
                 case when o.fulfilment = 'delivery' then
                   jsonb_build_object(
                     'street',   case when coalesce(o.ship_street, '') <> '' then o.ship_street   else c.street   end,
                     'suburb',   case when coalesce(o.ship_street, '') <> '' then o.ship_suburb   else c.suburb   end,
                     'state',    case when coalesce(o.ship_street, '') <> '' then o.ship_state    else c.state    end,
                     'postcode', case when coalesce(o.ship_street, '') <> '' then o.ship_postcode else c.postcode end,
                     'instructions', o.ship_instructions,
                     'deliver_on', o.deliver_on,
                     'carrier_ref', o.carrier_ref)
                 end                                     as ship
            from customer_order o
            join customer c    on c.id = o.customer_id
            join order_line l  on l.order_id = o.id and l.for_butcher
            left join product_option po on po.id = l.product_option_id
            left join product pr        on pr.id = po.product_id
            left join farm_business fb  on fb.farm_id = o.farm_id
            cross join lateral (select greatest(l.cartons, 1) as cartons,
                                       (l.cut_sheet is not null or po.cut_sheet is not null) as own_sheet,
                                       coalesce(l.cut_sheet, po.cut_sheet, pr.cut_sheet) as sheet) x
            cross join lateral generate_series(1, l.qty)     as g(n)
            cross join lateral generate_series(1, x.cartons) as k(c)
           where o.harvest_id = h.id and o.status <> 'cancelled') b), '[]'::jsonb),
    -- What there is to sell, what is on these sheets, and the difference (77).
    'balance', (select jsonb_build_object('boxes', b.boxes, 'sold', b.boxes_sold, 'left', b.boxes_left,
                                          'head', b.head, 'per_head', b.per_head, 'box_kg', b.box_kg)
                  from v_harvest_balance b where b.id = h.id),
    'remaining_sheet', h.remaining_sheet);
end $$;

revoke execute on function butcher_sheet(uuid) from public, anon;
grant  execute on function butcher_sheet(uuid) to authenticated;

notify pgrst, 'reload schema';
