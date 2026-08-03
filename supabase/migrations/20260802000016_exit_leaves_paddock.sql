-- ============================================================
-- Buloke Farm — leaving the herd also means leaving the paddock
-- Apply after 20260802000015_exit_date.sql.
--
-- consign_animals() has always closed the paddock stay: stock that
-- goes on a truck is out of the paddock by definition. set_animal_status()
-- never did. So an animal marked sold or died from the editor kept an
-- open paddock_stay row, and v_paddock counts those rows without
-- looking at life_state — a dead cow went on being grazed.
--
-- Fixed in the function rather than in the app, so the editor, the
-- bulk update and anything written later all inherit it instead of
-- each remembering to do it.
--
-- Deliberately one-way. Marking an animal alive again does not put
-- her back in a paddock, because there's no way to know which one she
-- should be in — that's a stock movement, and it should be recorded
-- as one.
-- ============================================================

create or replace function set_animal_status(
    p_animal_ids uuid[],
    p_life_state life_state_t default null,
    p_class      animal_class_t default null,
    p_on         date default current_date,
    p_reason     text default null)
returns int language plpgsql security invoker set search_path = public as $$
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

-- ------------------------------------------------------------
-- Anything already wrong stays wrong until it's cleaned up, so
-- clean it up: close stays for stock that has already left.
-- ------------------------------------------------------------

update paddock_stay ps
   set moved_out = x.effective_on
  from (
    select distinct on (s.animal_id) s.animal_id, s.effective_on
      from animal_status s
     where s.life_state <> 'alive'
     order by s.animal_id, s.effective_on
  ) x
 where ps.animal_id = x.animal_id
   and ps.moved_out is null
   and x.effective_on >= ps.moved_in;

notify pgrst, 'reload schema';
