# Toland ewe import — things to check

243 ewes, all alive, all breeders, from studs.csv.

- **Date of birth is a convention, not a record.** The file has none. Every ewe is entered as born on 1 June of the year in the first two digits of her tag (Richard, 30 Sep 2026). Ages, the drop a ewe belongs to and the year her natural increase counts in all follow from it. Replace with real lambing dates if the stud program can export them.
- Drops: 2019 × 1, 2020 × 12, 2021 × 23, 2022 × 35, 2023 × 106, 2024 × 66.
- Tags are the colour then the six-digit Visual Id, `BU 230040`, so the colour pill works as it does for Buloke's sheep. Migration 62 lets the parser read six digits.
- Breed set to Merino for all 243; the file does not say. Confirm with Anna.
- 65 sires, none in this file (it is the ewes only): reference animals. 10 carry a stud prefix and are outside rams: A170390, A211716, CN200113, KAM210447, KIA210266, NAM064, TV210856, TV220509, WIL200400, WP200964.
- 207 dams not in this file: reference animals by number. 21 ewes have a dam in the file and link to her directly. 1 ewe(s) have no dam written.
- Sires and dams not on file are named exactly as written. When Toland's rams and older ewes are imported, those references should become the real animals.
- Horn is PP, PH or HH as tested; 3 blank.
- EID is the RFID form, 940 and twelve digits, kept with its space as written. Buloke's sheep carry the PIC form instead; NLIS accepts either.
- 6 retag notes kept as notes, the current tag being the one in Visual Id: Y 210998 (Was 210112), BU 230633 (Was 230140), BU 230634 (Was 230058), BU 230689 (Was 230137), BU 230697 (Was 230147), BK 240490 (Was 240489).
- Notes kept verbatim. Most common: 'A PLUS' × 49, 'LL 2026' × 12, 'LONG WHITE WOOL' × 5, 'HAIRY' × 4, 'GOOD WOOL' × 2. 'LL 2026' is read as lost lamb 2026 and 'A PLUS' as a classing mark; neither is parsed into a field.
- No paddocks: nothing in the file says where a ewe is. Move mobs on the phone once the map is traced.
- No joinings, weights, treatments or shearing in this file.
