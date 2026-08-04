# Sheep import — things to check

90 head · 61 alive · 22 sold · 7 dead. Matches the spreadsheet totals.

- row 16 (G 336): EID expanded from '18' to '3BWWY089ASR0018'
- row 17 (G 342): EID expanded from '20' to '3BWWY089ASR0020'
- row 18 (G 343): EID expanded from '21' to '3BWWY089ASR0021'
- row 19 (G 346): EID expanded from '22' to '3BWWY089ASR0022'
- row 20 (G 347): EID expanded from '23' to '3BWWY089ASR0023'
- row 21 (G 349): EID expanded from '24' to '3BWWY089ASR0024'
- row 22 (G 352): EID expanded from '26' to '3BWWY089ASR0026'
- row 23 (G 353): EID expanded from '27' to '3BWWY089ASR0027'
- row 24 (G 355): EID expanded from '29' to '3BWWY089ASR0029'
- row 25 (TOL 20-P1065): EID expanded from '1065' to '3SBES046ASR06xxx'
- row 74 (None): no date of birth
- row 93 (WH 238): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 94 (WH 239): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 95 (WH 213): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 96 (WH 215): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 97 (WH 217): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 98 (WH 219): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 99 (WH 221): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 100 (WH 225): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 101 (WH 227): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 102 (WH 229): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 103 (WH 231): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 104 (WH 233): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- row 105 (WH 237): Type 'Lamb' with Status 'Harvest' — recorded as class 'harvest', matching the cattle convention
- `TOL 20-P1065` EID recorded as `3SBES046ASR06xxx` — the last digits are unknown and `xxx` is a placeholder, not a tag. Fix before any NLIS transfer.
- 11 animals carry a retag note (`-> NT`, `-> BK 188` and so on). Kept as notes; the current tag is the one in TagID.
- Drench 2026-01-10 and 2026-03-15: no product, batch, WHP or operator. Required for LPA Section 2.
- Both sales have no NVD serial. None invented.
- Six Cherry Tree sales have no price; left null rather than guessed.
- Joining paddocks matched by name against `%top%` and `%bottom%`. Check they hit the right ones.
- Dam column was empty throughout, so sheep pedigree is sire-only.
- 'Drop' is not stored as a field — it is inferred from date of birth, and kept in notes for reference.
