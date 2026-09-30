-- ============================================================
-- 62. A stud tag has six digits.
--
-- Buloke's tags are a letter and a number that has never needed
-- more than three digits — N 84, WH 214. Toland Merino numbers a
-- ewe by her drop year and a sequence, 230040, and the colour in
-- front of it makes the tag as the app writes one: BU 230040.
--
-- animal_code_parts (43, 46) read one or two letters and up to four
-- digits, so a six-digit tag typed on the phone would keep its text
-- and get no letter and no number — no colour on the pill, nothing
-- to sort by. It reads up to six now. Nothing on file changes:
-- every tag already parsed still parses the same way.
--
-- receive_stock (59) has its own normaliser with the same four-digit
-- limit. A longer tag falls through it unchanged, upper-cased, and
-- the trigger below then reads it, so a ewe brought on as BU 230040
-- lands right. Only a tag typed without the space, BU230040, would
-- keep that spelling; the pill splits on the space. Left as it is
-- until someone types one.
--
-- Safe to run more than once.
-- ============================================================

create or replace function animal_code_parts()
returns trigger language plpgsql as $$
declare m text[];
begin
  m := regexp_match(coalesce(new.stock_code, ''), '^\s*([A-Za-z]{1,2})\s*(\d{1,6})\s*$');
  if m is not null then
    new.year_letter := upper(m[1]);
    new.herd_number := m[2]::int;
  end if;
  return new;
end $$;

comment on function animal_code_parts is
  'Splits a typed stock code into year_letter (one or two letters) and herd_number (up to six digits). Anything else is kept as written.';

-- Check:
--   insert a sheep with stock_code 'BU 230040' and read back
--   year_letter, herd_number  -- BU, 230040
