-- ============================================================
-- Buloke Farm — historical animals, 2011 to 2026
-- Apply after 13_animal_edit.sql. Safe to run more than once.
--
-- 50 head that have left the property: sold, died or culled. They are
-- inserted as real animals rather than pedigree stubs, so the family
-- tree shows actual descent instead of dead-ending at a grey box.
--
-- No tag collides with the current register. J 64 already existed as
-- the reference stub 'J 64 (SD)'; it is merged, not duplicated.
-- ============================================================

begin;

-- Heritage lines and PICs
insert into heritage (name) values ('Buloke') on conflict (name) do nothing;
insert into heritage (name) values ('Garratt') on conflict (name) do nothing;
insert into heritage (name) values ('Rupari') on conflict (name) do nothing;
insert into property (pic, is_own) values ('3BWWR044', false) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3BWWY089', true) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3MISK126', false) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3MISL022', false) on conflict (pic) do nothing;
insert into property (pic, is_own) values ('3SGLE223', false) on conflict (pic) do nothing;

-- External sires and dams not already on file
insert into animal (name, origin, sex) select '6MGdSlam', 'reference', 'unknown' where not exists (select 1 from animal where name = '6MGdSlam');
insert into animal (name, origin, sex) select 'Aneto', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Aneto');
insert into animal (name, origin, sex) select 'Atlas', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Atlas');
insert into animal (name, origin, sex) select 'B. Clover', 'reference', 'unknown' where not exists (select 1 from animal where name = 'B. Clover');
insert into animal (name, origin, sex) select 'B. Phoenix', 'reference', 'unknown' where not exists (select 1 from animal where name = 'B. Phoenix');
insert into animal (name, origin, sex) select 'BRdg Henshin', 'reference', 'unknown' where not exists (select 1 from animal where name = 'BRdg Henshin');
insert into animal (name, origin, sex) select 'Bell', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Bell');
insert into animal (name, origin, sex) select 'D 05 (SD)', 'reference', 'unknown' where not exists (select 1 from animal where name = 'D 05 (SD)');
insert into animal (name, origin, sex) select 'G/bat K456 Wgyu', 'reference', 'unknown' where not exists (select 1 from animal where name = 'G/bat K456 Wgyu');
insert into animal (name, origin, sex) select 'G/bat Kath', 'reference', 'unknown' where not exists (select 1 from animal where name = 'G/bat Kath');
insert into animal (name, origin, sex) select 'Joeline', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Joeline');
insert into animal (name, origin, sex) select 'K. Unique', 'reference', 'unknown' where not exists (select 1 from animal where name = 'K. Unique');
insert into animal (name, origin, sex) select 'Peppermil G Wgyu', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Peppermil G Wgyu');
insert into animal (name, origin, sex) select 'Popcorn', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Popcorn');
insert into animal (name, origin, sex) select 'Russel', 'reference', 'unknown' where not exists (select 1 from animal where name = 'Russel');

-- Historical animals
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'G 02', 'G', 2, 'Gerbera',
  '3MISL022XBF00312',
  'purchased', 'female', '2011-03-23', 'Blonde', 'P',
  'blonde', true, 'n', null,
  (select id from heritage where name = 'Rupari'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISL022'),
  '3MISL022'
where not exists (select 1 from animal where stock_code = 'G 02' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'J 48', 'J', 48, null,
  '3SGLE223XBG00414',
  'purchased', 'female', '2013-10-01', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3SGLE223'),
  '3SGLE223'
where not exists (select 1 from animal where stock_code = 'J 48' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'J 66', 'J', 66, null,
  '3SGLE223XBG00410',
  'purchased', 'female', '2013-10-30', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3SGLE223'),
  '3SGLE223'
where not exists (select 1 from animal where stock_code = 'J 66' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'J 64', 'J', 64, 'TheBend',
  '3SGLE223XBG00424',
  'purchased', 'female', '2013-10-23', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISK126'),
  '3MISK126 -> 3BWWY089'
where not exists (select 1 from animal where stock_code = 'J 64' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'M 61', 'M', 61, 'TB Memi  YeM1',
  null,
  'purchased', 'female', '2016-03-05', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISK126'),
  '3MISK126 -> 3BWWY089'
where not exists (select 1 from animal where stock_code = 'M 61' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'N 80', 'N', 80, null,
  null,
  'purchased', 'female', '2017-02-16', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3MISK126'),
  '3MISK126 -> 3BWWY089'
where not exists (select 1 from animal where stock_code = 'N 80' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'K 122', 'K', 122, null,
  '3SGLE223XBL00531',
  'bred', 'female', '2014-09-21', 'South Devon Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sell'
where not exists (select 1 from animal where stock_code = 'K 122' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'B 200', 'B', 200, null,
  '3BWWY089XBL0039',
  'bred', 'female', '2018-10-15', 'South Devon Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Piper'
where not exists (select 1 from animal where stock_code = 'B 200' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'B 201', 'B', 201, null,
  '3BWWY089XBL0049',
  'bred', 'unknown', '2019-10-01', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'At Dads - on Grain Feed from 6th March 21  (Q6)'
where not exists (select 1 from animal where stock_code = 'B 201' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 02', 'R', 2, null,
  '3BWWY089XBL0053',
  'bred', 'female', '2020-03-07', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Autumn Calf - Angus Blonde X'
where not exists (select 1 from animal where stock_code = 'R 02' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 04', 'R', 4, null,
  '3BWWY089XBL0054',
  'bred', 'female', '2020-03-15', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Autumn Calf - Angus Blonde X'
where not exists (select 1 from animal where stock_code = 'R 04' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 01', 'R', 1, null,
  '3BWWY089XBL0055',
  'bred', 'male', '2020-09-03', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Sth Devon X'
where not exists (select 1 from animal where stock_code = 'R 01' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 06', 'R', 6, null,
  '3BWWY089XBL0058',
  'bred', 'female', '2020-09-27', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 06' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 03', 'R', 3, null,
  '3BWWY089XBL0056',
  'bred', 'male', '2020-10-28', 'South Devon Blonde X', null,
  null, null, null, 60,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Sth Devon X'
where not exists (select 1 from animal where stock_code = 'R 03' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 05', 'R', 5, null,
  '3BWWY089XBL0057',
  'bred', 'male', '2020-10-30', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 05' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 10', 'R', 10, null,
  '3BWWY089XBL0062',
  'bred', 'female', '2020-11-02', 'South Devon Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 10' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 07', 'R', 7, null,
  '3BWWY089XBL0061',
  'bred', 'male', '2020-11-02', 'South Devon Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 07' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 12', 'R', 12, null,
  '3BWWY089XBL0060',
  'bred', 'female', '2020-11-05', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 12' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 09', 'R', 9, null,
  '3BWWY089XBL0064',
  'bred', 'male', '2020-11-30', 'Angus Blonde X', null,
  null, null, null, 35,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'R 09' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 97', 'R', 97, 'Rambo',
  '3BWTW595XBRT0043',
  'purchased', 'male', '2020-03-27', 'Blonde', null,
  null, null, null, null,
  (select id from heritage where name = 'Rupari'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Wagu Steer - Full Blood. Purchased on 13.2.24, Transferred on 3.3.24'
where not exists (select 1 from animal where stock_code = 'R 97' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'P 27', 'P', 27, 'Pablo Blk d''Poll',
  null,
  'bred', 'male', '2018-09-21', 'Blonde', '1/2, Gr1,',
  null, true, 'Br', null,
  (select id from heritage where name = 'Rupari'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Bull'
where not exists (select 1 from animal where stock_code = 'P 27' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 50', 'S', 50, null,
  null,
  'bred', 'female', '2021-09-24', 'South Devon Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Sth Devon X'
where not exists (select 1 from animal where stock_code = 'S 50' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 52', 'S', 52, null,
  null,
  'bred', 'female', '2021-10-03', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  '3/4 Blonde Angus X'
where not exists (select 1 from animal where stock_code = 'S 52' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 51', 'S', 51, null,
  '3BWWY089XBL0066',
  'bred', 'male', '2021-10-04', 'South Devon Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Sth Devon X'
where not exists (select 1 from animal where stock_code = 'S 51' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 53', 'S', 53, null,
  '3BWWY089XBL0065',
  'bred', 'male', '2021-10-16', 'South Devon Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Blonde Sth Devon X'
where not exists (select 1 from animal where stock_code = 'S 53' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 54', 'S', 54, null,
  null,
  'bred', 'female', '2021-10-16', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'S 54' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 57', 'S', 57, null,
  '3BWWY089XBL0068',
  'bred', 'male', '2021-10-13', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'S 57' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 55', 'S', 55, null,
  '3BWWY089XBL0067',
  'bred', 'male', '2021-10-13', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'S 55' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 56', 'S', 56, null,
  null,
  'bred', 'female', '2021-12-01', 'Angus Blonde X', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'S 56' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'R 39', 'R', 39, null,
  '3BWWR044LBR00514',
  'purchased', 'female', '2021-11-15', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  'Purchased 15.01.22 ~$1,800 - FY21-22'
where not exists (select 1 from animal where stock_code = 'R 39' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'Q 31', 'Q', 31, null,
  '3BWWR044LBQ00503',
  'purchased', 'female', '2021-08-31', 'South Devon', null,
  null, null, null, null,
  (select id from heritage where name = 'Garratt'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = '3BWWR044'),
  'Purchased 06.11.22 ~$2,800 - FY22-23'
where not exists (select 1 from animal where stock_code = 'Q 31' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'S 26', 'S', 26, null,
  '3BWWY089…...',
  'bred', 'unknown', '2021-10-09', 'Angus Blonde X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Dad''s F1, Purchased on 13.2.24, Transferred on 3.3.24'
where not exists (select 1 from animal where stock_code = 'S 26' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 20', 'T', 20, null,
  null,
  'bred', 'unknown', '2022-10-22', 'Angus Blonde X Wagyu', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sold to Dad.  Has Dad''s NLIS number.
Sold again on 29.09.24 for Buloke Beef, through Dads'' PIC'
where not exists (select 1 from animal where stock_code = 'T 20' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 22', 'T', 22, null,
  null,
  'bred', 'unknown', '2022-10-22', 'Angus Blonde X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'T 22' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 25', 'T', 25, null,
  null,
  'bred', 'unknown', '2022-10-27', 'Angus Blonde X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sold to Traf Abs. Central Agri Group'
where not exists (select 1 from animal where stock_code = 'T 25' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 28', 'T', 28, null,
  null,
  'bred', 'female', null, 'South Devon Blonde X Wagyu', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'T 28' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 24', 'T', 24, null,
  null,
  'bred', 'female', '2022-11-16', 'Angus Blonde X Wagyu', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'T 24' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'T 26', 'T', 26, null,
  null,
  'bred', 'female', '2022-11-20', 'Red Angus X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  null
where not exists (select 1 from animal where stock_code = 'T 26' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 25', 'U', 25, null,
  '3BWWY089XBL0087',
  'bred', 'male', '2023-11-21', 'South Devon X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x Wagu'
where not exists (select 1 from animal where stock_code = 'U 25' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 20', 'U', 20, null,
  '3BWWY089XBL0080',
  'bred', 'female', '2023-09-15', 'South Devon X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x Wagu'
where not exists (select 1 from animal where stock_code = 'U 20' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 30', 'U', 30, null,
  '3BWWY089XBL0089',
  'bred', 'female', '2023-11-21', 'South Devon X Wagyu', null,
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x Blonde'
where not exists (select 1 from animal where stock_code = 'U 30' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 26', 'U', 26, null,
  '3BWWY089XBL0083',
  'bred', 'female', '2023-10-03', 'South Devon X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x Wagu'
where not exists (select 1 from animal where stock_code = 'U 26' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 22', 'U', 22, null,
  '3BWWY089XBL0081',
  'bred', 'female', '2023-09-19', 'South Devon X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x Wagu'
where not exists (select 1 from animal where stock_code = 'U 22' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 28', 'U', 28, null,
  '3BWWY089XBL0086',
  'bred', 'female', '2023-10-08', 'Red Angus X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Red Angus x Wagu'
where not exists (select 1 from animal where stock_code = 'U 28' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 27', 'U', 27, null,
  '3BWWY089XBL0088',
  'bred', 'male', '2023-10-23', 'Red Angus X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Red Angus x Wagu'
where not exists (select 1 from animal where stock_code = 'U 27' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 24', 'U', 24, null,
  '3BWWY089XBL0082',
  'bred', 'female', '2023-09-24', 'Red Angus X Blonde', '3/4',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  '(Red Angus / Sth Devon) x RA'
where not exists (select 1 from animal where stock_code = 'U 24' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 21', 'U', 21, null,
  '3BWWY089XBL0084',
  'bred', 'male', '2023-10-03', 'Red Angus X Blonde', '3/4',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  '(Red Angus / Sth Devon) x RA'
where not exists (select 1 from animal where stock_code = 'U 21' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'U 23', 'U', 23, null,
  '3BWWY089XBL0085',
  'bred', 'male', '2023-10-03', 'Red Angus X Blonde', '3/4',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon x RA'
where not exists (select 1 from animal where stock_code = 'U 23' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'V 23', 'V', 23, null,
  null,
  'bred', 'male', '2024-09-17', 'South Devon X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Sth Devon / Wagu'
where not exists (select 1 from animal where stock_code = 'V 23' and origin <> 'reference');
insert into animal (stock_code, year_letter, herd_number, name, nlis_tag, origin,
  sex, dob, breed, grade, coat_colour, polled, marking_code, birth_weight_kg,
  heritage_id, property_id, origin_property_id, notes)
select 'V 25', 'V', 25, null,
  null,
  'bred', 'male', '2024-09-24', 'Red Angus X Wagyu', 'F1-W',
  null, null, null, null,
  (select id from heritage where name = 'Buloke'),
  (select id from property where pic = '3BWWY089'),
  (select id from property where pic = null),
  'Red Angus / Wagu'
where not exists (select 1 from animal where stock_code = 'V 25' and origin <> 'reference');

-- 'J 64 (SD)' was a pedigree stub. It is a real animal in this file, so
-- repoint everything that referenced the stub, then remove it.
update animal set dam_id  = (select id from animal where stock_code = 'J 64' and origin <> 'reference')
 where dam_id  = (select id from animal where name = 'J 64 (SD)' and origin = 'reference');
update animal set sire_id = (select id from animal where stock_code = 'J 64' and origin <> 'reference')
 where sire_id = (select id from animal where name = 'J 64 (SD)' and origin = 'reference');
delete from animal where name = 'J 64 (SD)' and origin = 'reference';

-- Pedigree
update animal set sire_id = (select id from animal where name = 'B. Phoenix' and origin = 'reference' limit 1) where stock_code = 'G 02' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'B. Clover' and origin = 'reference' limit 1) where stock_code = 'G 02' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'D 05 (SD)' and origin = 'reference' limit 1) where stock_code = 'M 61' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = '6MGdSlam' and origin = 'reference' limit 1) where stock_code = 'N 80' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'Popcorn' and origin = 'reference' limit 1) where stock_code = 'N 80' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) where stock_code = 'B 200' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'Bell' and origin = 'reference' limit 1) where stock_code = 'B 201' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'R 02' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'P 51' and origin = 'reference' limit 1) where stock_code = 'R 01' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1) where stock_code = 'R 01' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'P 51' and origin = 'reference' limit 1) where stock_code = 'R 06' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 82' and origin <> 'reference' limit 1) where stock_code = 'R 06' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'P 51' and origin = 'reference' limit 1) where stock_code = 'R 03' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) where stock_code = 'R 03' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin <> 'reference' limit 1) where stock_code = 'R 05' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'M 61' and origin <> 'reference' limit 1) where stock_code = 'R 10' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) where stock_code = 'R 07' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) where stock_code = 'R 12' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'R 09' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'BRdg Henshin' and origin = 'reference' limit 1) where stock_code = 'R 97' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'G/bat Kath' and origin = 'reference' limit 1) where stock_code = 'R 97' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'K. Unique' and origin = 'reference' limit 1) where stock_code = 'P 27' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'Joeline' and origin = 'reference' limit 1) where stock_code = 'P 27' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 50' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1) where stock_code = 'S 50' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 52' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1) where stock_code = 'S 52' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 51' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) where stock_code = 'S 51' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 53' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) where stock_code = 'S 53' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 54' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) where stock_code = 'S 54' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 57' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 82' and origin <> 'reference' limit 1) where stock_code = 'S 57' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 55' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin <> 'reference' limit 1) where stock_code = 'S 55' and origin <> 'reference';
update animal set sire_id = (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) where stock_code = 'S 56' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'S 56' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1) where stock_code = 'S 26' and origin <> 'reference';
update animal set dam_id = (select id from animal where name = 'B202' and origin = 'reference' limit 1) where stock_code = 'S 26' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1) where stock_code = 'T 20' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) where stock_code = 'T 20' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'T 22' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin <> 'reference' limit 1) where stock_code = 'T 22' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'T 25' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'T 25' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Aneto' and origin = 'reference' limit 1) where stock_code = 'T 28' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) where stock_code = 'T 28' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Aneto' and origin = 'reference' limit 1) where stock_code = 'T 24' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1) where stock_code = 'T 24' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1) where stock_code = 'T 26' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1) where stock_code = 'T 26' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 25' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1) where stock_code = 'U 25' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 20' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'S 05' and origin <> 'reference' limit 1) where stock_code = 'U 20' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Russel' and origin = 'reference' limit 1) where stock_code = 'U 30' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'S 15' and origin <> 'reference' limit 1) where stock_code = 'U 30' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'G/bat K456 Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 26' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'S 16' and origin <> 'reference' limit 1) where stock_code = 'U 26' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 22' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'Q 32' and origin <> 'reference' limit 1) where stock_code = 'U 22' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 28' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 82' and origin <> 'reference' limit 1) where stock_code = 'U 28' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'U 27' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) where stock_code = 'U 27' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Atlas' and origin = 'reference' limit 1) where stock_code = 'U 24' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 84' and origin <> 'reference' limit 1) where stock_code = 'U 24' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Atlas' and origin = 'reference' limit 1) where stock_code = 'U 21' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'U 21' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Atlas' and origin = 'reference' limit 1) where stock_code = 'U 23' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'L 74' and origin <> 'reference' limit 1) where stock_code = 'U 23' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'V 23' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'S 16' and origin <> 'reference' limit 1) where stock_code = 'V 23' and origin <> 'reference';
update animal set sire_id = (select id from animal where name = 'Peppermil G Wgyu' and origin = 'reference' limit 1) where stock_code = 'V 25' and origin <> 'reference';
update animal set dam_id = (select id from animal where stock_code = 'N 82' and origin <> 'reference' limit 1) where stock_code = 'V 25' and origin <> 'reference';

-- Status: alive from birth, then sold or died
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1), '2011-03-23', 'alive', null where (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1), '2021-07-11', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1), '2013-10-01', 'alive', null where (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1), '2022-08-15', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1), '2013-10-30', 'alive', null where (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1), '2022-08-15', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1), '2013-10-23', 'alive', null where (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1), '2023-05-21', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'M 61' and origin <> 'reference' limit 1), '2016-03-05', 'alive', null where (select id from animal where stock_code = 'M 61' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'M 61' and origin <> 'reference' limit 1), '2024-06-30', 'died', null, 'Died-FY23-24' where (select id from animal where stock_code = 'M 61' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1), '2017-02-16', 'alive', null where (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1), '2023-10-23', 'died', null, 'Died-FY23-24' where (select id from animal where stock_code = 'N 80' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1), '2014-09-21', 'alive', null where (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1), '2021-03-10', 'sold', null, 'Sold-FY20-21' where (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1), '2018-10-15', 'alive', 'yearling' where (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1), '2023-05-21', 'sold', 'yearling', 'Sold-FY22-23' where (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1), '2019-10-01', 'alive', 'yearling' where (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1), '2021-07-11', 'sold', 'yearling', 'Sold-FY21-22' where (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1), '2020-03-07', 'alive', 'yearling' where (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1), '2022-04-03', 'sold', 'yearling', 'Sold-FY21-22' where (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1), '2020-03-15', 'alive', null where (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1), '2021-03-09', 'sold', null, 'Sold-FY20-21' where (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1), '2020-09-03', 'alive', null where (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1), '2022-01-16', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1), '2020-09-27', 'alive', null where (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1), '2022-04-03', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1), '2020-10-28', 'alive', null where (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1), '2022-01-18', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1), '2020-10-30', 'alive', null where (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1), '2022-05-01', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1), '2020-11-02', 'alive', null where (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1), '2025-06-30', 'died', null, 'Died-FY24-25' where (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1), '2020-11-02', 'alive', null where (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1), '2021-10-03', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1), '2020-11-05', 'alive', 'breeder' where (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1), '2023-05-21', 'sold', 'breeder', 'Sold-FY22-23' where (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1), '2020-11-30', 'alive', null where (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1), '2022-05-01', 'sold', null, 'Sold-FY21-22' where (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1), '2020-03-27', 'alive', null where (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1), '2024-04-21', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1), '2018-09-21', 'alive', 'bull' where (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1), '2023-06-30', 'sold', 'bull', 'Sold-FY22-23' where (select id from animal where stock_code = 'P 27' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1), '2021-09-24', 'alive', null where (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1), '2022-09-25', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1), '2021-10-03', 'alive', null where (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1), '2023-07-04', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1), '2021-10-04', 'alive', null where (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1), '2023-01-16', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1), '2021-10-16', 'alive', null where (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1), '2023-01-16', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1), '2021-10-16', 'alive', null where (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1), '2023-03-13', 'sold', null, 'Sold-FY22-23' where (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1), '2021-10-13', 'alive', null where (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1), '2023-07-04', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1), '2021-10-13', 'alive', null where (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1), '2023-07-04', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1), '2021-12-01', 'alive', null where (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1), '2023-10-29', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1), '2021-11-15', 'alive', 'harvest' where (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1), '2024-07-16', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1), '2021-08-31', 'alive', null where (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1), '2023-10-22', 'died', null, 'Died-FY23-24' where (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1), '2021-10-09', 'alive', 'breeder' where (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1), '2024-07-16', 'sold', 'breeder', 'Sold-FY24-25' where (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1), '2022-10-22', 'alive', null where (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1), '2024-09-29', 'sold', null, 'Sold-FY24-25' where (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1), '2022-10-22', 'alive', 'harvest' where (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1), '2024-07-16', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1), '2022-10-27', 'alive', 'harvest' where (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1), '2024-08-04', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 28' and origin <> 'reference' limit 1), '2024-02-06', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'T 28' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1), '2022-11-16', 'alive', null where (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1), '2024-02-06', 'sold', null, 'Sold-FY23-24' where (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1), '2022-11-20', 'alive', 'harvest' where (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1), '2024-12-17', 'sold', 'harvest', 'Sold-FY24-25 (dad)' where (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1), '2023-11-21', 'alive', 'harvest' where (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1), '2025-06-01', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1), '2023-09-15', 'alive', 'harvest' where (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1), '2025-05-26', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1), '2023-11-21', 'alive', 'harvest' where (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1), '2025-06-01', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1), '2023-10-03', 'alive', 'harvest' where (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1), '2025-06-01', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1), '2023-09-19', 'alive', 'harvest' where (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1), '2025-03-24', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1), '2023-10-08', 'alive', 'harvest' where (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1), '2025-10-20', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1), '2023-10-23', 'alive', 'harvest' where (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1), '2025-10-20', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1), '2023-09-24', 'alive', 'harvest' where (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1), '2025-06-01', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1), '2023-10-03', 'alive', 'harvest' where (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1), '2025-03-24', 'sold', 'harvest', 'Sold-FY24-25' where (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1), '2023-10-03', 'alive', 'harvest' where (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1), '2025-06-01', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1), '2024-09-17', 'alive', 'harvest' where (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1), '2026-05-25', 'sold', 'harvest', 'Sold-FY25-26' where (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;
insert into animal_status (animal_id, effective_on, life_state, class) select (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1), '2024-09-24', 'alive', 'harvest' where (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1), '2026-06-23', 'sold', 'harvest', 'Sold-FY26-27' where (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1) is not null on conflict (animal_id, effective_on) do update set life_state = excluded.life_state;

-- Weights
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1), '2022-01-05', 522.0, 'scale' where (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1), '2022-01-05', 518.0, 'scale' where (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1), '2022-01-05', 460.0, 'scale' where (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1), '2022-01-05', 568.0, 'scale' where (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1), '2022-01-05', 512.0, 'scale' where (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1), '2022-01-05', 464.0, 'scale' where (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1), '2022-01-05', 446.0, 'scale' where (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1), '2022-01-05', 496.0, 'scale' where (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1), '2024-07-13', 544.0, 'scale' where (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1), '2024-07-13', 586.0, 'scale' where (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1), '2024-07-13', 452.0, 'scale' where (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1), '2024-07-13', 260.0, 'scale' where (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1), '2024-07-13', 320.0, 'scale' where (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1), '2024-07-13', 304.0, 'scale' where (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1), '2024-07-13', 264.0, 'scale' where (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1), '2024-07-13', 330.0, 'scale' where (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1), '2024-07-13', 216.0, 'scale' where (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1), '2024-07-13', 328.0, 'scale' where (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1), '2024-07-13', 314.0, 'scale' where (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into weight_event (animal_id, weighed_on, weight_kg, method) select (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1), '2024-07-13', 274.0, 'scale' where (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1) is not null on conflict do nothing;

-- Consignments, grouped by NVD and sale date

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2021-03-09', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2021-03-09' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1), 429.8, 245, null, null, null, null
  from consignment c where c.consigned_on = '2021-03-09' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'R 04' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2021-03-10', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2021-03-10' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1), 710, null, 2.946, 2091.66, 209.17, 194.849999999999
  from consignment c where c.consigned_on = '2021-03-10' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'K 122' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2021-07-11', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2021-07-11' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2021-07-11' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'G 02' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2021-07-11' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'B 201' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2021-10-03', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2021-10-03' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1), 206.8, null, null, null, null, null
  from consignment c where c.consigned_on = '2021-10-03' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'R 07' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-01-16', 'book', 'C-100506469',
  'other', 'C-100506469', 'C-100506469', null
where not exists (select 1 from consignment where consigned_on = '2022-01-16' and coalesce(destination,'') = 'C-100506469');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2022-01-16' and coalesce(destination,'') = 'C-100506469' and (select id from animal where stock_code = 'R 01' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-01-18', 'book', 'C-100507473',
  'other', 'C-100507473', 'C-100507473', null
where not exists (select 1 from consignment where consigned_on = '2022-01-18' and coalesce(destination,'') = 'C-100507473');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2022-01-18' and coalesce(destination,'') = 'C-100507473' and (select id from animal where stock_code = 'R 03' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-04-03', 'book', 'C-100568065',
  'other', 'C-100568065', 'C-100568065', null
where not exists (select 1 from consignment where consigned_on = '2022-04-03' and coalesce(destination,'') = 'C-100568065');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2022-04-03' and coalesce(destination,'') = 'C-100568065' and (select id from animal where stock_code = 'R 02' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1), 480, null, 4.156, 1994.88, 199.48800000000003, null
  from consignment c where c.consigned_on = '2022-04-03' and coalesce(destination,'') = 'C-100568065' and (select id from animal where stock_code = 'R 06' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-05-01', 'book', 'C-100586823',
  'other', 'C-100586823', 'C-100586823', null
where not exists (select 1 from consignment where consigned_on = '2022-05-01' and coalesce(destination,'') = 'C-100586823');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1), 557.5, null, 5.596, 3119.77, 311.97700000000003, null
  from consignment c where c.consigned_on = '2022-05-01' and coalesce(destination,'') = 'C-100586823' and (select id from animal where stock_code = 'R 05' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1), 557.5, null, 5.596, 3119.77, 311.97700000000003, null
  from consignment c where c.consigned_on = '2022-05-01' and coalesce(destination,'') = 'C-100586823' and (select id from animal where stock_code = 'R 09' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-08-15', 'book', 'C-100663985',
  'other', 'C-100663985', 'C-100663985', null
where not exists (select 1 from consignment where consigned_on = '2022-08-15' and coalesce(destination,'') = 'C-100663985');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1), 585, null, 3.7, 2164.5, 216.45000000000002, null
  from consignment c where c.consigned_on = '2022-08-15' and coalesce(destination,'') = 'C-100663985' and (select id from animal where stock_code = 'J 48' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1), 585, null, 3.7, 2164.5, 216.45000000000002, null
  from consignment c where c.consigned_on = '2022-08-15' and coalesce(destination,'') = 'C-100663985' and (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2022-09-25', 'book', 'C-100693382',
  'property', 'Buloke Farm', 'C-100693382', null
where not exists (select 1 from consignment where consigned_on = '2022-09-25' and coalesce(destination,'') = 'Buloke Farm');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1), null, null, null, 0, 0, null
  from consignment c where c.consigned_on = '2022-09-25' and coalesce(destination,'') = 'Buloke Farm' and (select id from animal where stock_code = 'S 50' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2023-01-16', 'book', 'C-0720-28192369',
  'agent', 'Elders', 'C-0720-28192369', null
where not exists (select 1 from consignment where consigned_on = '2023-01-16' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1), 490, null, 4.4, 2156, 215.60000000000002, null
  from consignment c where c.consigned_on = '2023-01-16' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 51' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1), 415, null, 4.4, 1826, 182.60000000000002, null
  from consignment c where c.consigned_on = '2023-01-16' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 53' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2023-03-13', 'book', 'C-0720-28192370',
  'property', 'Buloke Farm', 'C-0720-28192370', null
where not exists (select 1 from consignment where consigned_on = '2023-03-13' and coalesce(destination,'') = 'Buloke Farm');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1), null, null, null, 0, 0, null
  from consignment c where c.consigned_on = '2023-03-13' and coalesce(destination,'') = 'Buloke Farm' and (select id from animal where stock_code = 'S 54' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2023-05-21', 'book', 'C-100897979',
  'agent', 'Elders', 'C-100897979', null
where not exists (select 1 from consignment where consigned_on = '2023-05-21' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1), 685, null, 2.62, 1794.7, 179.47000000000003, null
  from consignment c where c.consigned_on = '2023-05-21' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'J 64' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1), 665, null, 2.45, 1629.25, 162.925, null
  from consignment c where c.consigned_on = '2023-05-21' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'B 200' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1), 520, null, 2.88, 1497.6, 149.76, null
  from consignment c where c.consigned_on = '2023-05-21' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'R 12' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2023-07-04', 'book', 'C-0720-28192371',
  'agent', 'Elders', 'C-0720-28192371', null
where not exists (select 1 from consignment where consigned_on = '2023-07-04' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1), null, null, null, 0, 0, null
  from consignment c where c.consigned_on = '2023-07-04' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 52' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1), null, null, null, 0, 0, null
  from consignment c where c.consigned_on = '2023-07-04' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 57' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1), null, null, null, 0, 0, null
  from consignment c where c.consigned_on = '2023-07-04' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 55' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2023-10-29', 'book', 'C-101038600',
  'property', 'Buloke Farm', 'C-101038600', null
where not exists (select 1 from consignment where consigned_on = '2023-10-29' and coalesce(destination,'') = 'Buloke Farm');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1), null, 338, null, null, null, null
  from consignment c where c.consigned_on = '2023-10-29' and coalesce(destination,'') = 'Buloke Farm' and (select id from animal where stock_code = 'S 56' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-02-06', 'book', 'C-101119578',
  'agent', 'Elders', 'C-101119578', null
where not exists (select 1 from consignment where consigned_on = '2024-02-06' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 28' and origin <> 'reference' limit 1), 440, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-02-06' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'T 28' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1), 460, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-02-06' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'T 24' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-04-21', null, null,
  'property', 'Cherry Tree', null, null
where not exists (select 1 from consignment where consigned_on = '2024-04-21' and coalesce(destination,'') = 'Cherry Tree');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-04-21' and coalesce(destination,'') = 'Cherry Tree' and (select id from animal where stock_code = 'R 97' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-07-16', null, null,
  'agent', 'Elders', 'Sold 16.07.24', 'Sold 16.07.24'
where not exists (select 1 from consignment where consigned_on = '2024-07-16' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-07-16' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'R 39' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-07-16' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'S 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-07-16', null, null,
  'property', 'Cherry Tree', 'Sold 16.07.24', 'Sold 16.07.24'
where not exists (select 1 from consignment where consigned_on = '2024-07-16' and coalesce(destination,'') = 'Cherry Tree');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-07-16' and coalesce(destination,'') = 'Cherry Tree' and (select id from animal where stock_code = 'T 22' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-08-04', null, null,
  'abattoir', 'Central Agri Group', 'Sold 04.08.24', 'Sold 04.08.24'
where not exists (select 1 from consignment where consigned_on = '2024-08-04' and coalesce(destination,'') = 'Central Agri Group');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1), 302.4, null, 6.8, 2056.3199999999997, 205.63199999999998, 6.3
  from consignment c where c.consigned_on = '2024-08-04' and coalesce(destination,'') = 'Central Agri Group' and (select id from animal where stock_code = 'T 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-09-29', null, null,
  'property', 'Cherry Tree', 'Sold 29.09.24', 'Sold 29.09.24'
where not exists (select 1 from consignment where consigned_on = '2024-09-29' and coalesce(destination,'') = 'Cherry Tree');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-09-29' and coalesce(destination,'') = 'Cherry Tree' and (select id from animal where stock_code = 'T 20' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2024-12-17', null, null,
  'agent', 'Elders', null, null
where not exists (select 1 from consignment where consigned_on = '2024-12-17' and coalesce(destination,'') = 'Elders');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2024-12-17' and coalesce(destination,'') = 'Elders' and (select id from animal where stock_code = 'T 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2025-03-24', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2025-03-24' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1), 400, null, 3.22, 1288, 128.8, 130.555
  from consignment c where c.consigned_on = '2025-03-24' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 22' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1), 450, null, 3.456, 1555.2, 155.52, 130.555
  from consignment c where c.consigned_on = '2025-03-24' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 21' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2025-05-26', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2025-05-26' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-05-26' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 20' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2025-06-01', null, null,
  'other', 'Not recorded', null, null
where not exists (select 1 from consignment where consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 30' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 26' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 24' and origin <> 'reference' limit 1) is not null on conflict do nothing;
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-06-01' and coalesce(destination,'') = 'Not recorded' and (select id from animal where stock_code = 'U 23' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2025-10-20', null, null,
  'property', 'Cherry Tree', null, null
where not exists (select 1 from consignment where consigned_on = '2025-10-20' and coalesce(destination,'') = 'Cherry Tree');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-10-20' and coalesce(destination,'') = 'Cherry Tree' and (select id from animal where stock_code = 'U 28' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2025-10-20', null, null,
  'saleyard', 'Saleyard', null, null
where not exists (select 1 from consignment where consigned_on = '2025-10-20' and coalesce(destination,'') = 'Saleyard');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2025-10-20' and coalesce(destination,'') = 'Saleyard' and (select id from animal where stock_code = 'U 27' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2026-05-25', null, null,
  'property', 'Cherry Tree', null, null
where not exists (select 1 from consignment where consigned_on = '2026-05-25' and coalesce(destination,'') = 'Cherry Tree');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2026-05-25' and coalesce(destination,'') = 'Cherry Tree' and (select id from animal where stock_code = 'V 23' and origin <> 'reference' limit 1) is not null on conflict do nothing;

insert into consignment (direction, consigned_on, nvd_kind, nvd_serial,
  destination_kind, destination, counterparty, notes)
select 'out', '2026-06-23', null, null,
  'saleyard', 'Saleyard', null, null
where not exists (select 1 from consignment where consigned_on = '2026-06-23' and coalesce(destination,'') = 'Saleyard');
insert into consignment_animal (consignment_id, animal_id, sale_weight_kg,
  carcass_weight_kg, price_per_kg, amount_ex_gst, gst, fees)
select c.id, (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1), null, null, null, null, null, null
  from consignment c where c.consigned_on = '2026-06-23' and coalesce(destination,'') = 'Saleyard' and (select id from animal where stock_code = 'V 25' and origin <> 'reference' limit 1) is not null on conflict do nothing;

-- Losses recorded without a tag: calvings, not animals
insert into calving (dam_id, calved_on, outcome, notes) select (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1), '2020-08-22', 'died', '1st Winter Calf' where (select id from animal where stock_code = 'J 66' and origin <> 'reference' limit 1) is not null;
insert into calving (dam_id, calved_on, outcome, notes) select (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1), '2024-06-30', 'died', 'Q31 - Q31 & Calf Died' where (select id from animal where stock_code = 'Q 31' and origin <> 'reference' limit 1) is not null;
insert into calving (dam_id, calved_on, outcome, notes) select (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1), '2025-06-30', 'died', 'Calf Overdue, Cow also Died' where (select id from animal where stock_code = 'R 10' and origin <> 'reference' limit 1) is not null;

commit;
