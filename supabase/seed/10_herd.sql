-- Generated from Cattle Data.xlsx — do not hand-edit.
begin;

-- Properties (PICs)
insert into property (pic, is_own) values ('3BWTW595', false) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3BWWR044', false) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3BWWY089', true) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3MISK126', false) on conflict (pic) do nothing;

-- Heritage lines
insert into heritage (name) values ('Buloke') on conflict (name) do nothing;
insert into heritage (name) values ('Garratt') on conflict (name) do nothing;

-- Reference animals: sires/dams never resident on the property.
insert into animal (name, origin, sex) values ('6MGdSlam', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('B. Gordoys Mable M11', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Bre. ? (ex U8)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Bre. Daisy Prudence P19', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Bre. Lupin N37', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Bre. Poppy', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Bre. Quicksilver (P)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Dav. Black Ace K2 (P)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Davelle Cool Beau', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Davelle Cool Beau N51', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('J 64 (SD)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Kildare Pharoh P99', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('M. Umberto U3', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('MJB United 333U?PP', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Nova N37 (Bretts)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Peppermil G Wgyu', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Pi 134 (SDx)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Popcorn', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Quicksilver', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('T.B. Harley (P)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('T.B. Marli M19', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Winterwood BonnieN23(P)', 'reference', 'unknown') on conflict do nothing;
insert into animal (name, origin, sex) values ('Yulong Trifecta T30', 'reference', 'unknown') on conflict do nothing;

-- Resident animals
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'N 84', 'N', 84,
  'Nina', '3BWWY089XBH0035', 'bred', 'female', '2017-09-21',
  'Red Angus X Sth Devon', '1/2', 'brown/red', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISK126'),
  null, '3MISK126 -> 3BWWY089',
  40, null, 'great xbd cow'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'N 82', 'N', 82,
  'Nessa', null, 'bred', 'female', '2017-02-16',
  'Red Angus', 'P', 'brown/red', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISK126'),
  null, '3MISK126 -> 3BWWY089',
  null, null, 'red angus'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'L 74', 'L', 74,
  'Lou Lou', '3MISL022XBK00461', 'bred', 'female', '2015-09-19',
  'Red Angus X Sth Devon', '1/2', 'brown/red', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWTW595'),
  null, null,
  null, null, 'great xbd cow'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'R 08', 'R', 8,
  'Raven', '3BWWY089XBL0059', 'bred', 'female', '2020-04-10',
  'Angus Blonde X', '1/2', 'black', true, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWY089'),
  null, 'Autumn Calf - Raven',
  35, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'S 05', 'S', 5,
  'Bre. Saintly S5', '3BWWR044LBR00549', 'purchased', 'female', '2021-04-15',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2022-01-15', 'Purchased 15.01.22 ~$1,800 - FY21-22',
  null, null, 'Exc udder & teats'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'S 15', 'S', 15,
  'Bre. Senorita S15', '3BWWR044LBR00559', 'purchased', 'female', '2021-11-15',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2022-01-15', 'Purchased 15.01.22 ~$1,800 - FY21-22',
  null, null, 'fat front teats'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'S 16', 'S', 16,
  'Bre. Sandy S16', '3BWWR044LBR00558', 'purchased', 'female', '2021-11-15',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2022-11-06', 'Purchased 06.11.22 ~$2,600 - FY22-23',
  null, null, 'avg to lge teats'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'Q 32', 'S', 32,
  'Bre. Quirky Q32', '3BWWR044LBQ00495', 'purchased', 'female', '2021-08-31',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2022-11-06', 'Purchased 06.11.22 ~$3,000 - FY22-23',
  null, null, 'Good uddrf & teats'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'T 02', 'T', 2,
  'Bre. Tulip T2', '3BWWR044LBS00571', 'purchased', 'female', '2022-01-04',
  'South Devon', 'P', null, true, 'Br',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2023-11-24', 'Purchased 24.11.23 ~ $1,300 +GST - FY23-24',
  null, null, 'Exc udder & teats'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'T 14', 'T', 14,
  'Bre. Tonnie T14', '3BWWR044LBS00583', 'purchased', 'female', '2022-02-10',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2023-11-24', 'Purchased 24.11.23 ~ $1,300 +GST - FY23-24   ****Died-FY24-25',
  null, null, '↑ Fast Calve, ↓ Gestn.'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'T 43', 'T', 43,
  'Bre. Teenova T43', '3BWWR044LBS00613', 'purchased', 'female', '2022-03-15',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  '2024-04-14', 'Sth Devon (Nova N37 & Quicksilver).  Purchased by Dad on 14/04/24.  Sold to me on ???',
  null, null, 'Nice'''
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'U 18', 'U', 8,
  'Bre. Ursula U18', '3BWWR044', 'bred', 'female', '2022-11-15',
  'South Devon', 'P', null, true, 'R',
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  null, 'Sth Devon Heifer -> Was U8',
  null, null, 'Bre. Heifer, bit toey'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 12', 'V', 12,
  'Vivvianne', null, 'bred', 'female', '2025-09-07',
  'South Devon', 'P', 'orange-tan', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 14', 'V', 14,
  'Veronna', null, 'bred', 'female', '2024-09-09',
  'South Devon', 'P', 'orange-tan', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 21', 'V', 21,
  'V-Market-21', null, 'bred', 'male', '2024-09-09',
  'South Devon', 'P', 'orange-tan', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 27', 'V', 27,
  'V-Market-27', null, 'bred', 'male', '2024-10-07',
  'South Devon', 'P', 'orange-tan', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 16', 'V', 16,
  'V-Market-16', null, 'bred', 'female', '2024-10-13',
  'South Devon X Wagyu', 'F1-W', 'brown/red', true, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'V 20', 'V', 20,
  'V-Market-20', null, 'bred', 'female', '2024-10-26',
  'South Devon X Wagyu', 'F1-W', 'black', true, 'Br',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, null
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 01', 'W', 1,
  'V-Market-01', null, 'bred', 'male', '2025-02-20',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, 'SALES'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 03', 'W', 3,
  'V-Market-03', null, 'bred', 'male', '2025-04-08',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, 'SALES'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 15', 'W', 15,
  'V-Market-15', null, 'bred', 'male', '2025-09-30',
  'South Devon X Wagyu', 'F1-W', 'black', true, 'Br',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Meat Sale'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 12', 'W', 12,
  'B. Willow', null, 'bred', 'female', '2025-09-08',
  'Red Angus X Sth Devon', null, 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Keeper'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 14', 'W', 14,
  'B. Winnie', null, 'bred', 'female', '2025-09-14',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Keeper'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 16', 'W', 16,
  'B. Waffles', null, 'bred', 'female', '2025-09-19',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Keeper'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 18', 'W', 18,
  'B. Whitney', null, 'bred', 'female', '2025-09-29',
  'Red Angus X Sth Devon', null, 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Keeper'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 20', 'W', 20,
  'B. Winona', null, 'bred', 'female', '2025-10-09',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Keeper'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 22', 'W', 22,
  'V-Market-22', null, 'bred', 'female', '2025-09-25',
  'South Devon X Wagyu', 'F1-W', 'black', true, 'Br',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Meat Sale'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'W 24', 'W', 24,
  'V-Market-24', null, 'bred', 'female', '2025-10-30',
  'South Devon X Wagyu', 'F1-W', 'black', true, 'Br',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, '2026-06-10', 'Meat Sale'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'X 02', 'X', 2,
  'X - Two', null, 'bred', 'female', '2026-03-11',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, 'Meat Sale'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'X 05', 'X', 5,
  'X - Five', null, 'bred', 'male', '2026-03-20',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, 'Meat Sale'
);
insert into animal (
  stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, polled, marking_code,
  heritage_id, property_id, origin_property_id, purchased_on, purchase_note,
  birth_weight_kg, weaned_on, notes
) values (
  'X 06', 'X', 6,
  'X - Six', null, 'bred', 'male', '2026-03-30',
  'South Devon', 'P', 'brown', true, 'R',
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null, null,
  null, null, 'Meat Sale'
);

-- Pedigree
update animal set sire_id = (select id from animal where name = '6MGdSlam' and origin='reference' limit 1) where stock_code = 'N 84';
update animal set dam_id = (select id from animal where name = 'J 64 (SD)' and origin='reference' limit 1) where stock_code = 'N 84';
update animal set sire_id = (select id from animal where name = '6MGdSlam' and origin='reference' limit 1) where stock_code = 'N 82';
update animal set dam_id = (select id from animal where name = 'Popcorn' and origin='reference' limit 1) where stock_code = 'N 82';
update animal set sire_id = (select id from animal where name = '6MGdSlam' and origin='reference' limit 1) where stock_code = 'L 74';
update animal set dam_id = (select id from animal where name = 'Pi 134 (SDx)' and origin='reference' limit 1) where stock_code = 'L 74';
update animal set sire_id = (select id from animal where name = 'Dav. Black Ace K2 (P)' and origin='reference' limit 1) where stock_code = 'S 05';
update animal set dam_id = (select id from animal where name = 'Bre. Poppy' and origin='reference' limit 1) where stock_code = 'S 05';
update animal set sire_id = (select id from animal where name = 'T.B. Harley (P)' and origin='reference' limit 1) where stock_code = 'S 15';
update animal set dam_id = (select id from animal where name = 'Bre. Lupin N37' and origin='reference' limit 1) where stock_code = 'S 15';
update animal set sire_id = (select id from animal where name = 'T.B. Harley (P)' and origin='reference' limit 1) where stock_code = 'S 16';
update animal set dam_id = (select id from animal where name = 'T.B. Marli M19' and origin='reference' limit 1) where stock_code = 'S 16';
update animal set sire_id = (select id from animal where name = 'Dav. Black Ace K2 (P)' and origin='reference' limit 1) where stock_code = 'Q 32';
update animal set dam_id = (select id from animal where name = 'B. Gordoys Mable M11' and origin='reference' limit 1) where stock_code = 'Q 32';
update animal set sire_id = (select id from animal where name = 'Kildare Pharoh P99' and origin='reference' limit 1) where stock_code = 'T 02';
update animal set dam_id = (select id from animal where name = 'Bre. Daisy Prudence P19' and origin='reference' limit 1) where stock_code = 'T 02';
update animal set sire_id = (select id from animal where name = 'Bre. Quicksilver (P)' and origin='reference' limit 1) where stock_code = 'T 14';
update animal set dam_id = (select id from animal where name = 'Winterwood BonnieN23(P)' and origin='reference' limit 1) where stock_code = 'T 14';
update animal set sire_id = (select id from animal where name = 'Quicksilver' and origin='reference' limit 1) where stock_code = 'T 43';
update animal set dam_id = (select id from animal where name = 'Nova N37 (Bretts)' and origin='reference' limit 1) where stock_code = 'T 43';
update animal set sire_id = (select id from animal where name = 'Bre. Quicksilver (P)' and origin='reference' limit 1) where stock_code = 'U 18';
update animal set dam_id = (select id from animal where name = 'Bre. ? (ex U8)' and origin='reference' limit 1) where stock_code = 'U 18';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'V 12';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1) where stock_code = 'V 12';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'V 14';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1) where stock_code = 'V 14';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'V 21';
update animal set dam_id = (select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1) where stock_code = 'V 21';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'V 27';
update animal set dam_id = (select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1) where stock_code = 'V 27';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1) where stock_code = 'V 16';
update animal set dam_id = (select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1) where stock_code = 'V 16';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1) where stock_code = 'V 20';
update animal set dam_id = (select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1) where stock_code = 'V 20';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 01';
update animal set dam_id = (select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1) where stock_code = 'W 01';
update animal set sire_id = (select id from animal where name = 'M. Umberto U3' and origin='reference' limit 1) where stock_code = 'W 03';
update animal set dam_id = (select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1) where stock_code = 'W 03';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1) where stock_code = 'W 15';
update animal set dam_id = (select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1) where stock_code = 'W 15';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 12';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1) where stock_code = 'W 12';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 14';
update animal set dam_id = (select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1) where stock_code = 'W 14';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 16';
update animal set dam_id = (select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1) where stock_code = 'W 16';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 18';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1) where stock_code = 'W 18';
update animal set sire_id = (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1) where stock_code = 'W 20';
update animal set dam_id = (select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1) where stock_code = 'W 20';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1) where stock_code = 'W 22';
update animal set dam_id = (select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1) where stock_code = 'W 22';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1) where stock_code = 'W 24';
update animal set dam_id = (select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1) where stock_code = 'W 24';
update animal set sire_id = (select id from animal where name = 'M. Umberto U3' and origin='reference' limit 1) where stock_code = 'X 02';
update animal set dam_id = (select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1) where stock_code = 'X 02';
update animal set sire_id = (select id from animal where name = 'M. Umberto U3' and origin='reference' limit 1) where stock_code = 'X 05';
update animal set dam_id = (select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1) where stock_code = 'X 05';
update animal set sire_id = (select id from animal where name = 'M. Umberto U3' and origin='reference' limit 1) where stock_code = 'X 06';
update animal set dam_id = (select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1) where stock_code = 'X 06';

-- Status (seeded at DOB; refine later with real transition dates)
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1), '2017-09-21', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1), '2017-02-16', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1), '2015-09-19', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'R 08' and origin<>'reference' limit 1), '2020-04-10', 'alive', 'protector');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1), '2021-04-15', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1), '2021-11-15', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1), '2021-11-15', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1), '2021-08-31', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), '2022-01-04', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1), '2022-02-10', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1), '2022-03-15', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1), '2022-11-15', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 12' and origin<>'reference' limit 1), '2025-09-07', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 14' and origin<>'reference' limit 1), '2024-09-09', 'alive', 'breeder');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 21' and origin<>'reference' limit 1), '2024-09-09', 'alive', 'harvest');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 27' and origin<>'reference' limit 1), '2024-10-07', 'alive', 'harvest');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 16' and origin<>'reference' limit 1), '2024-10-13', 'alive', 'harvest');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'V 20' and origin<>'reference' limit 1), '2024-10-26', 'alive', 'harvest');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 01' and origin<>'reference' limit 1), '2025-02-20', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 03' and origin<>'reference' limit 1), '2025-04-08', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 15' and origin<>'reference' limit 1), '2025-09-30', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 12' and origin<>'reference' limit 1), '2025-09-08', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 14' and origin<>'reference' limit 1), '2025-09-14', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 16' and origin<>'reference' limit 1), '2025-09-19', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 18' and origin<>'reference' limit 1), '2025-09-29', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 20' and origin<>'reference' limit 1), '2025-10-09', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 22' and origin<>'reference' limit 1), '2025-09-25', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'W 24' and origin<>'reference' limit 1), '2025-10-30', 'alive', 'yearling');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'X 02' and origin<>'reference' limit 1), '2026-03-11', 'alive', 'calf');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'X 05' and origin<>'reference' limit 1), '2026-03-20', 'alive', 'calf');
insert into animal_status (animal_id, effective_on, life_state, class) values ((select id from animal where stock_code = 'X 06' and origin<>'reference' limit 1), '2026-03-30', 'alive', 'calf');

-- Weight events
insert into weight_event (animal_id, weighed_on, weight_kg) values ((select id from animal where stock_code = 'R 08' and origin<>'reference' limit 1), '2024-07-13', 684);
insert into weight_event (animal_id, weighed_on, weight_kg) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), '2024-07-13', 612);

-- Treatments (dates only in source; LPA fields need backfilling)
insert into treatment (treated_on, product_name, notes) values ('2021-05-22', 'Vaccination (product not recorded)', 'Imported from spreadsheet; LPA detail missing');
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2021-05-22' and product_name='Vaccination (product not recorded)' limit 1), (select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2021-05-22' and product_name='Vaccination (product not recorded)' limit 1), (select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2021-05-22' and product_name='Vaccination (product not recorded)' limit 1), (select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2021-05-22' and product_name='Vaccination (product not recorded)' limit 1), (select id from animal where stock_code = 'R 08' and origin<>'reference' limit 1);
insert into treatment (treated_on, product_name, notes) values ('2022-07-16', 'Drench (product not recorded)', 'Imported from spreadsheet; LPA detail missing');
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2022-07-16' and product_name='Drench (product not recorded)' limit 1), (select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2022-07-16' and product_name='Drench (product not recorded)' limit 1), (select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2022-07-16' and product_name='Drench (product not recorded)' limit 1), (select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1);
insert into treatment_animal (treatment_id, animal_id) select (select id from treatment where treated_on='2022-07-16' and product_name='Drench (product not recorded)' limit 1), (select id from animal where stock_code = 'R 08' and origin<>'reference' limit 1);

-- Joinings
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau' and origin='reference' limit 1), 'autumn', '2026-2027', 1, '2026-05-17', 285, '2027-02-26', 0.05) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1), (select id from animal where name = 'Yulong Trifecta T30' and origin='reference' limit 1), 'autumn', '2026-2027', 2, '2026-06-22', 285, '2027-04-03', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1), (select id from animal where name = 'Yulong Trifecta T30' and origin='reference' limit 1), 'autumn', '2026-2027', 1, '2026-05-04', 285, '2027-02-13', 1) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'autumn', '2026-2027', 2, '2026-05-24', 285, '2027-03-05', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau' and origin='reference' limit 1), 'autumn', '2026-2027', 1, '2026-05-11', 285, '2027-02-20', 1) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau N51' and origin='reference' limit 1), 'autumn', '2026-2027', 2, '2026-05-31', 285, '2027-03-12', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'V 12' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-10', 285, '2027-08-22', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'V 12' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'V 14' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-10', 285, '2027-08-22', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'V 14' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau N51' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-20', 287, '2027-09-03', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 287, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1), (select id from animal where name = 'Yulong Trifecta T30' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-20', 285, '2027-09-01', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 1, '2026-11-20', 285, '2027-09-01', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 1, '2026-11-20', 287, '2027-09-03', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 2, null, 287, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1), (select id from animal where name = 'Yulong Trifecta T30' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-20', 285, '2027-09-01', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-11-20', 287, '2027-09-03', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 287, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 1, '2026-12-18', 285, '2027-09-29', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1), null, 'spring', '2027-2028', 2, null, 285, '1900-10-11', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau N51' and origin='reference' limit 1), 'spring', '2027-2028', 1, '2026-12-18', 287, '2027-10-01', null) on conflict do nothing;
insert into joining (dam_id, sire_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), 'spring', '2027-2028', 2, null, 287, '1900-10-11', null) on conflict do nothing;

-- Expected calvings (projected drops — not animals)
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'spring', '2026-09-08');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), '2026-2027', 'spring', '2026-09-10');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), '2026-2027', 'spring', '2026-09-10');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'spring', '2026-09-21');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'spring', '2026-10-01');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'spring', '2026-10-06');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'spring', '2026-10-16');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), (select id from animal where name = 'M. Umberto U3' and origin='reference' limit 1), '2026-2027', 'spring', '2026-11-21');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1), (select id from animal where name = 'Yulong Trifecta T30' and origin='reference' limit 1), '2026-2027', 'autumn', '2027-02-26');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2026-2027', 'autumn', '2027-02-13');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1), (select id from animal where name = 'Davelle Cool Beau N51' and origin='reference' limit 1), '2026-2027', 'autumn', '2027-02-20');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'V 12' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2027-2028', 'spring', '2027-08-22');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'V 14' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2027-2028', 'spring', '2027-08-22');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 05' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), '2027-2028', 'spring', '2027-09-03');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 16' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2027-2028', 'spring', '2027-09-01');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'N 82' and origin<>'reference' limit 1), null, '2027-2028', 'spring', '2027-09-01');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'L 74' and origin<>'reference' limit 1), null, '2027-2028', 'spring', '2027-09-03');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'S 15' and origin<>'reference' limit 1), (select id from animal where name = 'Peppermil G Wgyu' and origin='reference' limit 1), '2027-2028', 'spring', '2027-09-01');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'Q 32' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), '2027-2028', 'spring', '2027-09-03');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'N 84' and origin<>'reference' limit 1), null, '2027-2028', 'spring', '2027-09-29');
insert into expected_calving (dam_id, sire_id, season, cycle, due_on) values ((select id from animal where stock_code = 'T 02' and origin<>'reference' limit 1), (select id from animal where name = 'MJB United 333U?PP' and origin='reference' limit 1), '2027-2028', 'spring', '2027-10-01');

-- Calvings inferred from calves with calving comments
insert into calving (dam_id, calved_on, calf_id, assisted, outcome, notes) values ((select id from animal where stock_code = 'T 43' and origin<>'reference' limit 1), '2026-03-11', (select id from animal where stock_code = 'X 02' and origin<>'reference' limit 1), false, 'live', 'unassisted');
insert into calving (dam_id, calved_on, calf_id, assisted, outcome, notes) values ((select id from animal where stock_code = 'U 18' and origin<>'reference' limit 1), '2026-03-20', (select id from animal where stock_code = 'X 05' and origin<>'reference' limit 1), true, 'live', 'leg caught vet assist');
insert into calving (dam_id, calved_on, calf_id, assisted, outcome, notes) values ((select id from animal where stock_code = 'T 14' and origin<>'reference' limit 1), '2026-03-30', (select id from animal where stock_code = 'X 06' and origin<>'reference' limit 1), false, 'live', 'unassisted, quick');

-- Feeding periods
insert into feeding_period (animal_id, started_on, ended_on) values ((select id from animal where stock_code = 'V 21' and origin<>'reference' limit 1), '2026-05-12', '2026-06-04');
insert into feeding_period (animal_id, started_on, ended_on) values ((select id from animal where stock_code = 'V 27' and origin<>'reference' limit 1), '2026-05-12', '2026-06-04');
insert into feeding_period (animal_id, started_on, ended_on) values ((select id from animal where stock_code = 'V 16' and origin<>'reference' limit 1), '2026-06-08', '2026-09-08');
insert into feeding_period (animal_id, started_on, ended_on) values ((select id from animal where stock_code = 'V 20' and origin<>'reference' limit 1), '2026-06-08', '2026-09-08');
insert into feeding_period (animal_id, started_on, ended_on) values ((select id from animal where stock_code = 'W 01' and origin<>'reference' limit 1), '2026-05-12', '2026-09-08');

commit;
