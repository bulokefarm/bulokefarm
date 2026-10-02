-- ============================================================
-- 67. AI confidence on a joining, written down.
--
-- joining.confidence_pct is the operator's judgement of an
-- insemination, 0-100, put down before the scan says whether it
-- took. The joining form on the animal's card reads and writes it
-- for an AI joining (public/index.html). Production has it, with
-- its two checks and a column comment, and the
-- 2026-09-29 schema snapshot shows it, but it was added in the SQL
-- editor and no migration ever made it. So `supabase db reset`
-- built a joining table without it; found 2026-10-02 seeding Dad's
-- cattle locally.
--
-- This writes down what production already has. On production every
-- statement below finds its column, check or comment in place and
-- changes nothing.
--
-- Safe to run more than once.
-- ============================================================

alter table joining add column if not exists confidence_pct smallint;

do $$
begin
  alter table joining add constraint joining_confidence_pct_check
    check (confidence_pct between 0 and 100);
exception when duplicate_object then null;
end $$;

do $$
begin
  alter table joining add constraint joining_confidence_ai_ck
    check (confidence_pct is null or method = 'ai');
exception when duplicate_object then null;
end $$;

comment on column joining.confidence_pct is
  'AI only. Operator''s judgement of the insemination, 0-100, recorded before the result is known.';

notify pgrst, 'reload schema';
