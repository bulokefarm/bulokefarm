# Cryo store import — things to check

50 bulls, 64 deliveries, 130 movements out.
20 embryo lots, 151 implants.

Every bull's balance reconciles: delivered less movements equals the register count.

## Anything that did not tie

- W Winds Atlas is also in tank 2 location 6 with 20 units (Pink Mk · White straws). Its own lot, opening balance only — the usage history sits on the main lot.
- W Winds Atlas is also in tank 2 location 6 with 15 units (White straws). Its own lot, opening balance only — the usage history sits on the main lot.
- Embryos Gershwin x Welcome: movements give 1, register says 0
- Embryos Rainier x Welcome: movements give 2, register says 0
- Embryos A.P.Extra(Pp) x EstherLee(Pp): movements give -1, register says 0
- Embryos ATG & APE x FaretheeWel(PP): movements give -1, register says 0
- Embryos ATG & Wkman x HallieAnn (PP): movements give 1, register says 0
- Embryos Wkmn / Atlas x Welcome: movements give -4, register says 0
- Embryos Workman x WW Wendy 341W: movements give 2, register says 0

## Decisions

- Tank and location come from the contents page; the register body records only the location.
- Column B is read as four fields — cane marker, straw, size, goblet — by content rather than position, since some bulls have no marker line. The verbatim column is kept in `marking`.
- A units-used row with no cow named is still a movement — 'Previously used' is stock gone before the record begins, 'chucked' a discard, straws to Nu-Genes or Agri-gene sent out.
- Undated movements and deliveries are dated 2008-07-01, where the register begins. It never post-dates a use.
- Females recorded as written; `female_id` filled only where the reference resolves to a cow on file. The rest wait in `v_cryo_unmapped`.
- No `joining` rows created — a joining needs a dam that exists.
- Embryo pairings split on ' x ', sire first, as the sheet writes them.
