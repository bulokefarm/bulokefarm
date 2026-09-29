-- ============================================================
-- 52. The event trigger that was never written down.
--
-- The live database has an event trigger, ensure_rls, that turns row
-- level security on for every table created in public. Migration 48
-- revoked execute on its function, rls_auto_enable(), because the
-- advisor flagged it — but no migration ever created either. It was
-- made in the SQL editor, or arrived with the project; either way a
-- rebuild from the migrations would not have it, and the repo was not
-- true. Both are owned by postgres, so they can be owned here.
--
-- It has never done anything on this database: every migration
-- enables RLS on its own tables by hand, so the trigger only ever
-- found it already on. It stays because it is a net under the
-- hand-written line, and because dropping a guard to make the repo
-- honest is the wrong way round.
--
-- Guarded, not replaced. A newer Supabase project may ship the same
-- trigger under another owner, and create-or-replace on someone
-- else's function fails. If either half exists it is left as found.
-- ============================================================

do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is null then
    create function public.rls_auto_enable() returns event_trigger
    language plpgsql security definer set search_path = pg_catalog as $f$
    declare cmd record;
    begin
      for cmd in
        select * from pg_event_trigger_ddl_commands()
         where command_tag in ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
           and object_type in ('table', 'partitioned table')
      loop
        if cmd.schema_name = 'public' then
          begin
            execute format('alter table if exists %s enable row level security', cmd.object_identity);
            raise log 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
          exception when others then
            raise log 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
          end;
        else
          raise log 'rls_auto_enable: skip % (schema %)', cmd.object_identity, cmd.schema_name;
        end if;
      end loop;
    end $f$;
  end if;

  if not exists (select 1 from pg_event_trigger where evtname = 'ensure_rls') then
    create event trigger ensure_rls on ddl_command_end
      when tag in ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      execute function public.rls_auto_enable();
  end if;
end $$;

-- As 48 left it: not for the API.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
