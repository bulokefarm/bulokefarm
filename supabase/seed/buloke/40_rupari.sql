-- The seeds run as postgres, where current_farm() has no membership to consult,
-- so the farm is named here and every insert takes it by default.
select set_config('app.farm', (select id::text from farm where slug = 'buloke'), false);

-- Generated from Cattle Data per Buloke App V1 260800.csv by migrate_rupari_csv.py — do not hand-edit.
-- Dad's herd, Rupari heritage, PIC 3BWTW595. Runs after 10_herd.sql: it links to
-- Buloke's Gerbera (G 02) and reuses Buloke's reference bulls by name.
begin;

-- Dad's PIC becomes one of Buloke's own. It was on file as an outside PIC,
-- the one Buloke's Rupari-bred stock came from.
insert into property (pic, is_own) values ('3BWTW595', true) on conflict (farm_id, pic) do nothing;
update property set is_own = true where farm_id = current_farm() and pic = '3BWTW595' and not is_own;
insert into property (pic, is_own) values ('3BWWR044', false) on conflict (farm_id, pic) do nothing;
insert into property (pic, is_own) values ('3BWWY089', false) on conflict (farm_id, pic) do nothing;
insert into property (pic, is_own) values ('SA565618', false) on conflict (farm_id, pic) do nothing;
insert into heritage (name) values ('Rupari') on conflict (farm_id, name) do nothing;

-- Reference animals: outside sires and dams. Names already on Buloke's file
-- (Atlas, Russel, M. Umberto U3 ...) are found, not made again.
insert into animal (species, name, origin, sex) select 'cattle', 'A. Black Boy', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'A. Black Boy');
insert into animal (species, name, origin, sex) select 'cattle', 'Atlas', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Atlas');
insert into animal (species, name, origin, sex) select 'cattle', 'B. Goolagong', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'B. Goolagong');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. M 19', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. M 19');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. M 29 (P)', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. M 29 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. Poppy', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Poppy');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. Quicksilver (P)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Quicksilver (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. Ryder R14 (P)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Ryder R14 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Bre. Stryker (pp?)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Stryker (pp?)');
insert into animal (species, name, origin, sex) select 'cattle', 'Burtergill Harry 815(P)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Burtergill Harry 815(P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Chiltn Pk MOE M6', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Chiltn Pk MOE M6');
insert into animal (species, name, origin, sex) select 'cattle', 'D. Lucia G26 (P)', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. Lucia G26 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'D. Toryson Lucia L17 (P)', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. Toryson Lucia L17 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'D. UB Richton H26 (P)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. UB Richton H26 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Davelle Rose M39 (P)', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Davelle Rose M39 (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'Esther Lee', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Esther Lee');
insert into animal (species, name, origin, sex) select 'cattle', 'G/bat K456 Wgyu', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'G/bat K456 Wgyu');
insert into animal (species, name, origin, sex) select 'cattle', 'Hammer', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer');
insert into animal (species, name, origin, sex) select 'cattle', 'Henri d''Poll', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Henri d''Poll');
insert into animal (species, name, origin, sex) select 'cattle', 'Jaimee Lee', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Jaimee Lee');
insert into animal (species, name, origin, sex) select 'cattle', 'James J1', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'James J1');
insert into animal (species, name, origin, sex) select 'cattle', 'Joiner', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Joiner');
insert into animal (species, name, origin, sex) select 'cattle', 'Kasper d''Poll', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll');
insert into animal (species, name, origin, sex) select 'cattle', 'Kildare Pharoh P99', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kildare Pharoh P99');
insert into animal (species, name, origin, sex) select 'cattle', 'Kotsukari', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari');
insert into animal (species, name, origin, sex) select 'cattle', 'M. Umberto U3', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3');
insert into animal (species, name, origin, sex) select 'cattle', 'MJB Cool 548C (P)', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB Cool 548C (P)');
insert into animal (species, name, origin, sex) select 'cattle', 'MJB United 333U?PP', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB United 333U?PP');
insert into animal (species, name, origin, sex) select 'cattle', 'Melviandale ?', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Melviandale ?');
insert into animal (species, name, origin, sex) select 'cattle', 'Nicola Blk (B)', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Nicola Blk (B)');
insert into animal (species, name, origin, sex) select 'cattle', 'Nikita', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Nikita');
insert into animal (species, name, origin, sex) select 'cattle', 'Norrie', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie');
insert into animal (species, name, origin, sex) select 'cattle', 'P STATESMAN S115', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115');
insert into animal (species, name, origin, sex) select 'cattle', 'Penny Lee', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Penny Lee');
insert into animal (species, name, origin, sex) select 'cattle', 'Poldark Blk d''Poll', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Poldark Blk d''Poll');
insert into animal (species, name, origin, sex) select 'cattle', 'Russel', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Russel');
insert into animal (species, name, origin, sex) select 'cattle', 'Sitz STELLAR', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR');
insert into animal (species, name, origin, sex) select 'cattle', 'T Patriarch Conv', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'T Patriarch Conv');
insert into animal (species, name, origin, sex) select 'cattle', 'WW Workman', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'WW Workman');

-- Dad's cattle
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'P 14', 'P', 14, 'D. Cool Lucia', 'SA565618XBS01195',
  'purchased', 'female', '2018-03-07',
  'South Devon (Davelle)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = 'SA565618'),
  '2024-03-05', null, null, 'Red Angus style SD'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'P 14');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'P 22', 'P', 22, 'D. Lucia', 'SA565618XBS01197',
  'purchased', 'female', '2018-04-06',
  'South Devon (Davelle)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = 'SA565618'),
  '2024-03-05', null, null, 'Exc. SD'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'P 22');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'Q 39', 'Q', 39, 'D. Black Rose', 'SA565618XBS01157',
  'purchased', 'female', '2019-07-22',
  'South Devon (Davelle)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = 'SA565618'),
  '2024-03-05', null, null, 'Blk SD'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'Q 39');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'R 44', 'R', 44, 'Raina BU PR0044', '3BWTW595XBRT0036',
  'bred', 'female', '2020-10-17',
  'Blonde', 'P', 'sandy', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 38, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'R 44');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'S 06', 'S', 6, 'Stella Noir', '3BWTW595XBRT0046',
  'bred', 'female', '2021-03-24',
  'Blonde', '3', 'black', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 30, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'S 06');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'S 16R', 'S', 16, 'Sasher Lee', '3BWTW595XBRT0056',
  'bred', 'female', '2021-10-07',
  'Blonde', 'P', 'white', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 37, null, 'Carried 291 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'S 16R');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'S 18', 'S', 18, 'Sarong', '3BWTW595XBRT0058',
  'bred', 'female', '2021-10-08',
  'Blonde', 'P', 'sandy', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 35, null, 'Carried 297 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'S 18');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'S 20', 'S', 20, 'Sally Lee', '3BWTW595XBRT0060',
  'bred', 'female', '2021-10-08',
  'Blonde', 'P', 'fawn', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 35, null, 'Carried 288 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'S 20');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 02', 'U', 2, 'Unita', '3BWTW595XBUW0016',
  'bred', 'female', '2023-04-19',
  'Blonde', 'P', 'fawn', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 36, null, 'Carried 290 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 02');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 04', 'U', 4, 'Ulainee Lee', '3BWTW595XBUW0004',
  'bred', 'female', '2023-04-20',
  'Blonde', 'P', 'white', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 35, null, 'Carried 289 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 04');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 12', 'U', 12, 'Utopenne Lee', '3BWTW595XBUW0012',
  'bred', 'female', '2023-10-26',
  'Blonde', 'P', 'fawn', 'P', 2,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 28, null, 'Carried 282 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 12');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 14', 'U', 14, 'Uropenne Lee', '3BWTW595XBUW0008',
  'bred', 'female', '2023-10-26',
  'Blonde', 'P', 'fawn', 'P', 2,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 27, null, 'Carried 282 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 14');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 08', 'U', 8, 'Bre Underdone U05', '3BWWR044XBT00660',
  'purchased', 'female', '2023-02-10',
  'South Devon (Brejanne)', 'F2', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWWY089'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2024-04-13', null, null, 'Transferred to Buloke PIC 13/4/24'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 08');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'U 20R', 'U', 20, 'Bre. Ultima (ex U2)', '3BWWR044XBT00638',
  'purchased', 'female', '2023-02-20',
  'South Devon (Brejanne)', 'F2', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2025-01-19', null, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'U 20R');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 08', 'V', 8, 'Bre. Valda V08', null,
  'purchased', 'female', '2024-02-15',
  null, 'P', 'red-orange', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2025-05-18', null, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 08');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 18', 'V', 18, 'Bre. Vova-done V18', null,
  'purchased', 'female', '2024-02-15',
  null, 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2025-01-19', null, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 18');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 08R', 'V', 8, 'Verity Lee', null,
  'bred', 'female', '2024-11-12',
  'Blonde', 'P', 'white', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 27, null, 'Carried 288 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 08R');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 10', 'V', 10, 'V-Gogogong', '3BWTW595XBUW0026',
  'bred', 'female', '2024-10-09',
  'Blonde', 'P', 'orange-tan', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 36, null, 'Carried 289 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 10');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 06', 'V', 6, 'Valeri', '3BWTW595XBUW0024',
  'bred', 'female', '2024-09-11',
  'Wagyu x Blonde', 'F1', 'orange-tan', 'H', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 32, null, 'Carried 291 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 06');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 04', 'V', 4, 'Rup. Velucia', '3BWTW595XBUW0022',
  'bred', 'female', '2024-07-24',
  'South Devon (Davelle)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 33, null, 'Carried 289 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 04');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 22', 'V', 22, 'Bre. Voletta (exV11)', null,
  'purchased', 'female', '2024-02-20',
  'South Devon (Brejanne)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2025-05-18', null, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 22');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 19', 'V', 19, 'Bre. V-Poppy V19', null,
  'purchased', 'female', '2024-02-20',
  'South Devon (Brejanne)', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = '3BWWR044'),
  '2025-05-18', null, null, null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 19');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'V 07', 'V', 7, 'Veteran', '3BWTW595XBUW0017',
  'bred', 'male', '2024-03-21',
  'Blonde', 'P', 'white', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 37, null, 'Carried 296 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'V 07');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 04', 'W', 4, 'Wanda', null,
  'bred', 'female', '2025-04-13',
  'Sth Devon x Blonde', 'F1', 'orange-tan', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 35, null, 'Carried 288 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 04');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 05', 'W', 5, 'Wilmslow', null,
  'bred', 'male', '2025-04-22',
  'Blonde (13/16)', 'F4', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 34, null, 'Carried 295 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 05');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 06', 'W', 6, 'Winter Rose', null,
  'bred', 'female', '2025-08-15',
  'Angus x Sth Devon', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 29, null, 'Carried 282 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 06');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 08', 'W', 8, 'Wynncia', null,
  'bred', 'female', '2025-09-02',
  'Angus x Sth Devon', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 31, null, 'Carried 282 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 08');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 10', 'W', 10, 'Wishfor-Lee', null,
  'bred', 'female', '2025-09-17',
  'Blonde', 'P', 'sandy', 'PP', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 32, null, 'Carried 295 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 10');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 07', 'W', 7, 'Weely Cool', null,
  'bred', 'steer', '2025-09-17',
  'Angus x Sth Devon', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 30, null, 'Carried 281 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 07');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 09', 'W', 9, 'Whisper', null,
  'bred', 'steer', '2025-10-27',
  'Blonde', 'P', 'sandy', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 26, null, 'Carried 304 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 09');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'W 11', 'W', 11, 'Warlord', null,
  'bred', 'steer', '2025-10-11',
  'Blonde', 'P', 'sandy', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 37, null, 'Carried 295 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'W 11');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 04', 'X', 4, 'Xania', null,
  'bred', 'steer', '2026-03-24',
  'Sth Devon x Blonde', 'F1', 'fawn', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 33, null, 'Carried 290 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 04');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 08', 'X', 8, 'Xalla', null,
  'bred', 'female', '2026-04-02',
  'Sth Devon', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 36, null, 'Carried 291 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 08');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 01', 'X', 1, 'Xpatriot', null,
  'bred', 'steer', '2026-03-17',
  'Sth Devon', 'P', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 41, null, 'Carried 290 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 01');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 03', 'X', 3, 'Xcelerator', null,
  'bred', 'steer', '2026-03-20',
  'Sth Devon x Blonde', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 41, null, 'Carried 292 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 03');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 07', 'X', 7, 'Xbert', null,
  'bred', 'steer', '2026-04-28',
  'Sth Devon x Blonde', 'F1', 'fawn', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 37, null, 'Carried 292 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 07');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 09', 'X', 9, 'Xalain', null,
  'bred', 'steer', '2026-05-03',
  'Sth Devon x Blonde', 'F1', 'fawn', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 36, null, 'Carried 288 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 09');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 10', 'X', 10, 'Xeeba', null,
  'bred', 'female', '2026-08-28',
  'Angus x Sth Devon', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 31, null, 'Carried 275 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 10');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 12', 'X', 12, 'Xeela', null,
  'bred', 'female', '2026-09-07',
  'Angus x Sth Devon', 'F1', 'black', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 28, null, 'Carried 275 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 12');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 17', 'X', 17, 'X - Seventeen', null,
  'bred', 'steer', '2026-09-17',
  'Wagyu x Sth Devon', 'F1', 'red-orange', 'P', null,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 27, null, 'Carried 287 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 17');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 18', 'X', 18, 'X - Eighteen', null,
  'bred', 'female', '2026-09-18',
  'Wagyu x Sth Devon', 'F1', 'red-orange', 'P', 2,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 24, null, 'Carried 286 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 18');
insert into animal (species, stock_code, year_letter, herd_number, name, nlis_tag, origin, sex, dob,
  breed, grade, coat_colour, horn, born_as, heritage_id, property_id, origin_property_id, purchased_on,
  birth_weight_kg, weaned_on, notes)
select 'cattle', 'X 19', 'X', 19, 'X - Nineteen', null,
  'bred', 'steer', '2026-09-18',
  'Wagyu x Sth Devon', 'F1', 'red-orange', 'P', 2,
  (select id from heritage where farm_id = current_farm() and name = 'Rupari'),
  (select id from property where farm_id = current_farm() and pic = '3BWTW595'),
  (select id from property where farm_id = current_farm() and pic = null),
  null, 24, null, 'Carried 286 days'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'cattle'
  and origin <> 'reference' and stock_code = 'X 19');

-- Pedigree
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB Cool 548C (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. Lucia G26 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. UB Richton H26 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'D. Toryson Lucia L17 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB Cool 548C (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Davelle Rose M39 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Poldark Blk d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'G 02') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Poldark Blk d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Nicola Blk (B)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Esther Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Atlas' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'B. Goolagong' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Penny Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Russel' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Nikita' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Russel' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Jaimee Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Penny Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Penny Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Ryder R14 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. M 29 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Ryder R14 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. M 19' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kildare Pharoh P99' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Melviandale ?' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Stryker (pp?)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. M 29 (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Russel' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08R') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Penny Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08R') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Henri d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'B. Goolagong' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'G/bat K456 Wgyu' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Burtergill Harry 815(P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kildare Pharoh P99' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Melviandale ?' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Quicksilver (P)' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Bre. Poppy' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Joiner' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 07') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Esther Lee' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 07') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'A. Black Boy' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'WW Workman' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'M. Umberto U3' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18') and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19') and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') where id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19') and dam_id is null;

-- Status as at birth, the class being what the sheet's Purpose says today
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), '2018-03-07', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), '2018-04-06', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), '2019-07-22', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), '2020-10-17', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06'), '2021-03-24', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), '2021-10-07', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'), '2021-10-08', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), '2021-10-08', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02'), '2023-04-19', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04'), '2023-04-20', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'), '2023-10-26', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'), '2023-10-26', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08'), '2023-02-10', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R'), '2023-02-20', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'), '2024-02-15', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), '2024-02-15', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08R'), '2024-11-12', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08R'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10'), '2024-10-09', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'), '2024-09-11', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04'), '2024-07-24', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22'), '2024-02-20', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19'), '2024-02-20', 'alive', 'breeder', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 07'), '2024-03-21', 'alive', 'bull', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 07'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04'), '2025-04-13', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05'), '2025-04-22', 'alive', 'bull', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06'), '2025-08-15', 'alive', 'yearling', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08'), '2025-09-02', 'alive', 'yearling', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10'), '2025-09-17', 'alive', 'yearling', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07'), '2025-09-17', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09'), '2025-10-27', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11'), '2025-10-11', 'alive', 'harvest', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04'), '2026-03-24', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08'), '2026-04-02', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01'), '2026-03-17', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03'), '2026-03-20', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07'), '2026-04-28', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09'), '2026-05-03', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10'), '2026-08-28', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12'), '2026-09-07', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17'), '2026-09-17', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18'), '2026-09-18', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18'));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19'), '2026-09-18', 'alive', 'calf', 'Imported from Dad''s sheet' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19'));

-- Weaning weights

-- Joinings. AI where the bull is in the tank, natural to Veteran. Confidence is
-- confidence_pct on an AI joining and the 0-1 figure on a natural one.
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), 'spring', '2026-2027', 1, '2025-11-26', 287, '2026-09-09', null, 100, 'calved', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), null, '2026-2027', 1, '2025-12-25', 285, null, null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), 'spring', '2026-2027', 2, '2025-12-25', 307, '2026-10-28', null, 90, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and season = '2026-2027' and attempt = 2);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), 'spring', '2026-2027', 1, '2025-12-06', 287, '2026-09-19', null, 100, 'calved', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 07'), 'natural', null, 'autumn', '2026-2027', 1, '2026-08-04', 288, '2027-05-19', 0.05, null, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Chiltn Pk MOE M6' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Chiltern Pk Moe  M6' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-06-14', 285, '2027-03-26', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Hammer d''Poll  H29' having count(*) = 1), null, '2026-2027', 1, '2026-01-08', 285, null, null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Hammer d''Poll  H29' having count(*) = 1), 'spring', '2026-2027', 2, '2026-01-26', 287, '2026-11-09', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and season = '2026-2027' and attempt = 2);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Hammer d''Poll  H29' having count(*) = 1), 'spring', '2026-2027', 1, '2026-01-07', 287, '2026-10-21', null, 85, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Norrie d''Poll    N23' having count(*) = 1), 'spring', '2026-2027', 1, '2026-01-07', 287, '2026-10-21', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'James J1' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Rupari James   J01' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-06-16', 288, '2027-03-31', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'James J1' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Rupari James   J01' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-04-28', 288, '2027-02-10', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'T Patriarch Conv' order by created_at limit 1), 'ai', null, 'spring', '2026-2027', 1, '2025-12-23', 287, '2026-10-06', null, 80, 'calved', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'T Patriarch Conv' order by created_at limit 1), 'ai', null, null, '2026-2027', 1, '2025-11-26', 285, null, null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'T Patriarch Conv' order by created_at limit 1), 'ai', null, 'spring', '2026-2027', 2, '2026-01-02', 287, '2026-10-16', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and season = '2026-2027' and attempt = 2);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-05-24', 285, '2027-03-05', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'TWA Kotsukari' having count(*) = 1), 'spring', '2026-2027', 1, '2025-12-04', 285, '2026-09-15', null, 100, 'calved', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'TWA Kotsukari' having count(*) = 1), 'spring', '2026-2027', 1, '2025-12-06', 285, '2026-09-17', null, 100, 'calved', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-05-03', 285, '2027-02-12', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04') and season = '2026-2027' and attempt = 1);
insert into joining (dam_id, sire_id, method, ai_semen_id, cycle, season, attempt, joined_on, gestation_days, due_on, confidence, confidence_pct, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22'), (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), 'ai', (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), 'autumn', '2026-2027', 1, '2026-04-25', 285, '2027-02-04', null, 100, 'unknown', 'From Dad''s sheet' where not exists (select 1 from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 22') and season = '2026-2027' and attempt = 1);

-- Calvings: every calf here whose dam is resident, and a dam's actual calving date.
insert into calving (dam_id, joining_id, calved_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and joined_on = '2025-12-23' order by attempt desc limit 1), '2026-10-02', 'Calved by Dad''s sheet; calf not yet recorded' where not exists (select 1 from calving where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and calved_on = '2026-10-02');
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'G 02'), null, '2020-10-17', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), null, '2024-09-11', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), null, '2024-07-24', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 04'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), null, '2025-04-13', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 04'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06'), null, '2025-04-22', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 05'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), null, '2025-08-15', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 06'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), null, '2025-09-02', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 08'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), null, '2025-09-17', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 10'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), null, '2025-09-17', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 07'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), null, '2025-10-27', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 09'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'), null, '2025-10-11', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'W 11'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 04'), null, '2026-03-24', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 04'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 08'), null, '2026-04-02', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 08'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 20R'), null, '2026-03-17', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 01'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 06'), null, '2026-03-20', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 03'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), null, '2026-04-28', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 07'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 02'), null, '2026-05-03', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 09'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and joined_on = '2025-11-26' order by attempt desc limit 1), '2026-08-28', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 10'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and joined_on = '2025-12-06' order by attempt desc limit 1), '2026-09-07', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 12'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and joined_on = '2025-12-04' order by attempt desc limit 1), '2026-09-17', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17'), 'live', null where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 17'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and joined_on = '2025-12-06' order by attempt desc limit 1), '2026-09-18', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18'), 'live', 'Twin' where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 18'));
insert into calving (dam_id, joining_id, calved_on, calf_id, outcome, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), (select id from joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and joined_on = '2025-12-06' order by attempt desc limit 1), '2026-09-18', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19'), 'live', 'Twin' where not exists (select 1 from calving where calf_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'X 19'));

-- Planned joins: the first bull on the planned date, the second as the back-up.
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 1, '2026-11-20', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 14') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB United 333U?PP' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'MJB United 333U ?PP?' having count(*) = 1), '2027-2028', 1, '2026-11-10', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'MJB United 333U?PP' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'MJB United 333U ?PP?' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'P 22') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 1, '2026-11-20', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'Q 39') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Norrie d''Poll    N23' having count(*) = 1), '2027-2028', 1, '2026-11-10', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Norrie d''Poll    N23' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'R 44') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Henri d''Poll' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Henri d''Poll   H15' having count(*) = 1), '2027-2028', 1, '2026-12-18', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Henri d''Poll' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Henri d''Poll   H15' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 16R') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Hammer d''Poll  H29' having count(*) = 1), '2027-2028', 1, '2026-12-18', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Hammer' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Hammer d''Poll  H29' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 18') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Norrie d''Poll    N23' having count(*) = 1), '2027-2028', 1, '2026-12-18', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Norrie' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Norrie d''Poll    N23' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'S 20') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Kasper d''Poll' having count(*) = 1), '2027-2028', 1, '2026-12-18', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Atlas' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'W.W. Atlas' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 12') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kasper d''Poll' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'R. Kasper d''Poll' having count(*) = 1), '2027-2028', 1, '2026-12-18', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Atlas' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'W.W. Atlas' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'U 14') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 1, '2026-11-20', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 08') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 1, '2026-11-20', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Sitz STELLAR' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Sitz STELLAR ssf' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 18') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), '2027-2028', 1, '2026-11-10', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 10') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'TWA Kotsukari' having count(*) = 1), '2027-2028', 1, '2026-11-10', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'Kotsukari' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'TWA Kotsukari' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 06') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), '2027-2028', 1, '2026-11-10', 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19') and season = '2027-2028' and attempt = 1 and joining_id is null and cancelled_on is null);
insert into planned_joining (dam_id, method, sire_id, ai_semen_id, season, attempt, planned_on, notes) select (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19'), 'ai', (select id from animal where farm_id = current_farm() and species = 'cattle' and origin = 'reference' and name = 'P STATESMAN S115' order by created_at limit 1), (select min(id::text)::uuid from ai_semen where farm_id = current_farm() and sire_name = 'Paringa Statesman S115' having count(*) = 1), '2027-2028', 2, null, 'From Dad''s sheet' where not exists (select 1 from planned_joining where dam_id = (select id from animal where farm_id = current_farm() and species = 'cattle' and origin <> 'reference' and stock_code = 'V 19') and season = '2027-2028' and attempt = 2 and joining_id is null and cancelled_on is null);

commit;
