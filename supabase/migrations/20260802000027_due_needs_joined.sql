-- ============================================================
-- Buloke Farm — a due date needs a service date
-- Apply after 20260802000026_one_expectation_per_dam.sql.
--
-- Ten joinings carry due_on = 1900-10-11 with joined_on null. The Due
-- list did not create those — 025 copied them faithfully out of
-- joining, where they have been sitting unseen since they were
-- recorded. The Due screen is the first thing that ever read them.
--
-- A due date is worked out from the day the bull went out. Without
-- one it is not a prediction, it is a number. The joinings are kept —
-- they still say these ten were joined — but the invented due date is
-- cleared, which also takes them off the Due list through the trigger.
--
-- Then the case is made impossible rather than left to be noticed
-- again in a year.
-- ============================================================

update joining
   set due_on = null
 where due_on is not null
   and joined_on is null;

do $$ begin
  alter table joining add constraint joining_due_needs_joined_ck
    check (due_on is null or joined_on is not null);
exception when duplicate_object then null; end $$;

-- A calf cannot be due before she was joined.
do $$ begin
  alter table joining add constraint joining_due_after_joined_ck
    check (due_on is null or joined_on is null or due_on > joined_on);
exception when duplicate_object then null; end $$;

comment on column joining.due_on is
  'Worked out from joined_on plus gestation. Meaningless without a service date, so the two are constrained together.';

-- The trigger already drops an expectation whose joining has no due
-- date, but it only fires on write. Sweep the ones already there.
delete from expected_calving e
 where e.resolved_calving_id is null
   and exists (select 1 from joining j
                where j.id = e.joining_id and j.due_on is null);

notify pgrst, 'reload schema';
