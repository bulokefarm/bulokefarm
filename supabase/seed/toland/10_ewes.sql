-- The seeds run as postgres, where current_farm() has no membership to consult,
-- so the farm is named here and every insert takes it by default.
select set_config('app.farm', (select id::text from farm where slug = 'toland'), false);

-- Generated from studs.csv by migrate_toland_csv.py — do not hand-edit.
-- Needs the farm row to exist already (farm_scope_plan.md §9).
begin;

-- Toland's own PIC. Already there on production; here for a rebuild.
insert into property (pic, is_own, is_primary, name) values ('3SBES046', true, true, 'Toland Merino') on conflict (farm_id, pic) do nothing;

-- Reference animals: sires and dams not in this file. Toland's own rams and
-- older ewes by their number, outside rams as written (KIA210266 and so on).
-- Promote to a resident animal when their own file arrives.
insert into animal (species, name, origin, sex) select 'sheep', '150052', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '150052');
insert into animal (species, name, origin, sex) select 'sheep', '150062', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '150062');
insert into animal (species, name, origin, sex) select 'sheep', '150360', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '150360');
insert into animal (species, name, origin, sex) select 'sheep', '150689', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '150689');
insert into animal (species, name, origin, sex) select 'sheep', '151057', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '151057');
insert into animal (species, name, origin, sex) select 'sheep', '151058', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '151058');
insert into animal (species, name, origin, sex) select 'sheep', '151545', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '151545');
insert into animal (species, name, origin, sex) select 'sheep', '160007', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160007');
insert into animal (species, name, origin, sex) select 'sheep', '160015', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160015');
insert into animal (species, name, origin, sex) select 'sheep', '160124', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160124');
insert into animal (species, name, origin, sex) select 'sheep', '160246', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160246');
insert into animal (species, name, origin, sex) select 'sheep', '160300', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160300');
insert into animal (species, name, origin, sex) select 'sheep', '160451', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160451');
insert into animal (species, name, origin, sex) select 'sheep', '160560', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160560');
insert into animal (species, name, origin, sex) select 'sheep', '160681', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160681');
insert into animal (species, name, origin, sex) select 'sheep', '160743', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160743');
insert into animal (species, name, origin, sex) select 'sheep', '160878', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '160878');
insert into animal (species, name, origin, sex) select 'sheep', '170009', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170009');
insert into animal (species, name, origin, sex) select 'sheep', '170039', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170039');
insert into animal (species, name, origin, sex) select 'sheep', '170084', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170084');
insert into animal (species, name, origin, sex) select 'sheep', '170306', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170306');
insert into animal (species, name, origin, sex) select 'sheep', '170434', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170434');
insert into animal (species, name, origin, sex) select 'sheep', '170468', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170468');
insert into animal (species, name, origin, sex) select 'sheep', '170530', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170530');
insert into animal (species, name, origin, sex) select 'sheep', '170545', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170545');
insert into animal (species, name, origin, sex) select 'sheep', '170566', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170566');
insert into animal (species, name, origin, sex) select 'sheep', '170615', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170615');
insert into animal (species, name, origin, sex) select 'sheep', '170643', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170643');
insert into animal (species, name, origin, sex) select 'sheep', '170734', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170734');
insert into animal (species, name, origin, sex) select 'sheep', '170777', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170777');
insert into animal (species, name, origin, sex) select 'sheep', '170788', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170788');
insert into animal (species, name, origin, sex) select 'sheep', '170800', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170800');
insert into animal (species, name, origin, sex) select 'sheep', '170906', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170906');
insert into animal (species, name, origin, sex) select 'sheep', '170907', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170907');
insert into animal (species, name, origin, sex) select 'sheep', '170944', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '170944');
insert into animal (species, name, origin, sex) select 'sheep', '171007', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '171007');
insert into animal (species, name, origin, sex) select 'sheep', '171010', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '171010');
insert into animal (species, name, origin, sex) select 'sheep', '171081', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '171081');
insert into animal (species, name, origin, sex) select 'sheep', '171120', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '171120');
insert into animal (species, name, origin, sex) select 'sheep', '171504', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '171504');
insert into animal (species, name, origin, sex) select 'sheep', '180012', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180012');
insert into animal (species, name, origin, sex) select 'sheep', '180013', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180013');
insert into animal (species, name, origin, sex) select 'sheep', '180022', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180022');
insert into animal (species, name, origin, sex) select 'sheep', '180024', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180024');
insert into animal (species, name, origin, sex) select 'sheep', '180033', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180033');
insert into animal (species, name, origin, sex) select 'sheep', '180073', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180073');
insert into animal (species, name, origin, sex) select 'sheep', '180076', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180076');
insert into animal (species, name, origin, sex) select 'sheep', '180118', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180118');
insert into animal (species, name, origin, sex) select 'sheep', '180136', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180136');
insert into animal (species, name, origin, sex) select 'sheep', '180163', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180163');
insert into animal (species, name, origin, sex) select 'sheep', '180191', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180191');
insert into animal (species, name, origin, sex) select 'sheep', '180211', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180211');
insert into animal (species, name, origin, sex) select 'sheep', '180262', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180262');
insert into animal (species, name, origin, sex) select 'sheep', '180274', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180274');
insert into animal (species, name, origin, sex) select 'sheep', '180284', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180284');
insert into animal (species, name, origin, sex) select 'sheep', '180296', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180296');
insert into animal (species, name, origin, sex) select 'sheep', '180537', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180537');
insert into animal (species, name, origin, sex) select 'sheep', '180617', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180617');
insert into animal (species, name, origin, sex) select 'sheep', '180630', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180630');
insert into animal (species, name, origin, sex) select 'sheep', '180634', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180634');
insert into animal (species, name, origin, sex) select 'sheep', '180649', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180649');
insert into animal (species, name, origin, sex) select 'sheep', '180674', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180674');
insert into animal (species, name, origin, sex) select 'sheep', '180709', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180709');
insert into animal (species, name, origin, sex) select 'sheep', '180710', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180710');
insert into animal (species, name, origin, sex) select 'sheep', '180759', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180759');
insert into animal (species, name, origin, sex) select 'sheep', '180760', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180760');
insert into animal (species, name, origin, sex) select 'sheep', '180847', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180847');
insert into animal (species, name, origin, sex) select 'sheep', '180871', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180871');
insert into animal (species, name, origin, sex) select 'sheep', '180936', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180936');
insert into animal (species, name, origin, sex) select 'sheep', '180940', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180940');
insert into animal (species, name, origin, sex) select 'sheep', '180969', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180969');
insert into animal (species, name, origin, sex) select 'sheep', '180990', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '180990');
insert into animal (species, name, origin, sex) select 'sheep', '181030', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181030');
insert into animal (species, name, origin, sex) select 'sheep', '181046', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181046');
insert into animal (species, name, origin, sex) select 'sheep', '181070', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181070');
insert into animal (species, name, origin, sex) select 'sheep', '181148', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181148');
insert into animal (species, name, origin, sex) select 'sheep', '181258', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181258');
insert into animal (species, name, origin, sex) select 'sheep', '181955', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181955');
insert into animal (species, name, origin, sex) select 'sheep', '181962', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181962');
insert into animal (species, name, origin, sex) select 'sheep', '181982', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '181982');
insert into animal (species, name, origin, sex) select 'sheep', '182700', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '182700');
insert into animal (species, name, origin, sex) select 'sheep', '183237', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '183237');
insert into animal (species, name, origin, sex) select 'sheep', '190004', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190004');
insert into animal (species, name, origin, sex) select 'sheep', '190022', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190022');
insert into animal (species, name, origin, sex) select 'sheep', '190023', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190023');
insert into animal (species, name, origin, sex) select 'sheep', '190038', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190038');
insert into animal (species, name, origin, sex) select 'sheep', '190049', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190049');
insert into animal (species, name, origin, sex) select 'sheep', '190117', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190117');
insert into animal (species, name, origin, sex) select 'sheep', '190122', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190122');
insert into animal (species, name, origin, sex) select 'sheep', '190133', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190133');
insert into animal (species, name, origin, sex) select 'sheep', '190156', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190156');
insert into animal (species, name, origin, sex) select 'sheep', '190197', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190197');
insert into animal (species, name, origin, sex) select 'sheep', '190310', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190310');
insert into animal (species, name, origin, sex) select 'sheep', '190344', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190344');
insert into animal (species, name, origin, sex) select 'sheep', '190389', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190389');
insert into animal (species, name, origin, sex) select 'sheep', '190411', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190411');
insert into animal (species, name, origin, sex) select 'sheep', '190444', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190444');
insert into animal (species, name, origin, sex) select 'sheep', '190468', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190468');
insert into animal (species, name, origin, sex) select 'sheep', '190482', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190482');
insert into animal (species, name, origin, sex) select 'sheep', '190540', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190540');
insert into animal (species, name, origin, sex) select 'sheep', '190581', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190581');
insert into animal (species, name, origin, sex) select 'sheep', '190582', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190582');
insert into animal (species, name, origin, sex) select 'sheep', '190642', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190642');
insert into animal (species, name, origin, sex) select 'sheep', '190720', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190720');
insert into animal (species, name, origin, sex) select 'sheep', '190732', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190732');
insert into animal (species, name, origin, sex) select 'sheep', '190734', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190734');
insert into animal (species, name, origin, sex) select 'sheep', '190746', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190746');
insert into animal (species, name, origin, sex) select 'sheep', '190794', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190794');
insert into animal (species, name, origin, sex) select 'sheep', '190802', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190802');
insert into animal (species, name, origin, sex) select 'sheep', '190807', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190807');
insert into animal (species, name, origin, sex) select 'sheep', '190938', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '190938');
insert into animal (species, name, origin, sex) select 'sheep', '191001', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191001');
insert into animal (species, name, origin, sex) select 'sheep', '191004', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191004');
insert into animal (species, name, origin, sex) select 'sheep', '191026', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191026');
insert into animal (species, name, origin, sex) select 'sheep', '191072', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191072');
insert into animal (species, name, origin, sex) select 'sheep', '191073', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191073');
insert into animal (species, name, origin, sex) select 'sheep', '191097', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191097');
insert into animal (species, name, origin, sex) select 'sheep', '191134', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191134');
insert into animal (species, name, origin, sex) select 'sheep', '191851', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '191851');
insert into animal (species, name, origin, sex) select 'sheep', '200017', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200017');
insert into animal (species, name, origin, sex) select 'sheep', '200031', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200031');
insert into animal (species, name, origin, sex) select 'sheep', '200038', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200038');
insert into animal (species, name, origin, sex) select 'sheep', '200102', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200102');
insert into animal (species, name, origin, sex) select 'sheep', '200106', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200106');
insert into animal (species, name, origin, sex) select 'sheep', '200119', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200119');
insert into animal (species, name, origin, sex) select 'sheep', '200130', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200130');
insert into animal (species, name, origin, sex) select 'sheep', '200138', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200138');
insert into animal (species, name, origin, sex) select 'sheep', '200139', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200139');
insert into animal (species, name, origin, sex) select 'sheep', '200159', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200159');
insert into animal (species, name, origin, sex) select 'sheep', '200163', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200163');
insert into animal (species, name, origin, sex) select 'sheep', '200169', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200169');
insert into animal (species, name, origin, sex) select 'sheep', '200173', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200173');
insert into animal (species, name, origin, sex) select 'sheep', '200177', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200177');
insert into animal (species, name, origin, sex) select 'sheep', '200206', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200206');
insert into animal (species, name, origin, sex) select 'sheep', '200221', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200221');
insert into animal (species, name, origin, sex) select 'sheep', '200240', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200240');
insert into animal (species, name, origin, sex) select 'sheep', '200270', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200270');
insert into animal (species, name, origin, sex) select 'sheep', '200278', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200278');
insert into animal (species, name, origin, sex) select 'sheep', '200279', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200279');
insert into animal (species, name, origin, sex) select 'sheep', '200285', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200285');
insert into animal (species, name, origin, sex) select 'sheep', '200305', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200305');
insert into animal (species, name, origin, sex) select 'sheep', '200308', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200308');
insert into animal (species, name, origin, sex) select 'sheep', '200313', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200313');
insert into animal (species, name, origin, sex) select 'sheep', '200357', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200357');
insert into animal (species, name, origin, sex) select 'sheep', '200364', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200364');
insert into animal (species, name, origin, sex) select 'sheep', '200373', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200373');
insert into animal (species, name, origin, sex) select 'sheep', '200375', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200375');
insert into animal (species, name, origin, sex) select 'sheep', '200377', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200377');
insert into animal (species, name, origin, sex) select 'sheep', '200395', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200395');
insert into animal (species, name, origin, sex) select 'sheep', '200439', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200439');
insert into animal (species, name, origin, sex) select 'sheep', '200444', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200444');
insert into animal (species, name, origin, sex) select 'sheep', '200478', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200478');
insert into animal (species, name, origin, sex) select 'sheep', '200479', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200479');
insert into animal (species, name, origin, sex) select 'sheep', '200500', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200500');
insert into animal (species, name, origin, sex) select 'sheep', '200505', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200505');
insert into animal (species, name, origin, sex) select 'sheep', '200510', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200510');
insert into animal (species, name, origin, sex) select 'sheep', '200516', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200516');
insert into animal (species, name, origin, sex) select 'sheep', '200532', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200532');
insert into animal (species, name, origin, sex) select 'sheep', '200553', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200553');
insert into animal (species, name, origin, sex) select 'sheep', '200571', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200571');
insert into animal (species, name, origin, sex) select 'sheep', '200578', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200578');
insert into animal (species, name, origin, sex) select 'sheep', '200612', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200612');
insert into animal (species, name, origin, sex) select 'sheep', '200630', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200630');
insert into animal (species, name, origin, sex) select 'sheep', '200657', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200657');
insert into animal (species, name, origin, sex) select 'sheep', '200715', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200715');
insert into animal (species, name, origin, sex) select 'sheep', '200720', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200720');
insert into animal (species, name, origin, sex) select 'sheep', '200746', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200746');
insert into animal (species, name, origin, sex) select 'sheep', '200752', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200752');
insert into animal (species, name, origin, sex) select 'sheep', '200778', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200778');
insert into animal (species, name, origin, sex) select 'sheep', '200817', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200817');
insert into animal (species, name, origin, sex) select 'sheep', '200840', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200840');
insert into animal (species, name, origin, sex) select 'sheep', '200844', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200844');
insert into animal (species, name, origin, sex) select 'sheep', '200885', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200885');
insert into animal (species, name, origin, sex) select 'sheep', '200886', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200886');
insert into animal (species, name, origin, sex) select 'sheep', '200906', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200906');
insert into animal (species, name, origin, sex) select 'sheep', '200992', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '200992');
insert into animal (species, name, origin, sex) select 'sheep', '201034', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201034');
insert into animal (species, name, origin, sex) select 'sheep', '201144', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201144');
insert into animal (species, name, origin, sex) select 'sheep', '201185', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201185');
insert into animal (species, name, origin, sex) select 'sheep', '201223', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201223');
insert into animal (species, name, origin, sex) select 'sheep', '201242', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201242');
insert into animal (species, name, origin, sex) select 'sheep', '201264', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201264');
insert into animal (species, name, origin, sex) select 'sheep', '201543', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201543');
insert into animal (species, name, origin, sex) select 'sheep', '201978', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201978');
insert into animal (species, name, origin, sex) select 'sheep', '201983', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201983');
insert into animal (species, name, origin, sex) select 'sheep', '201990', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '201990');
insert into animal (species, name, origin, sex) select 'sheep', '210004', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210004');
insert into animal (species, name, origin, sex) select 'sheep', '210007', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210007');
insert into animal (species, name, origin, sex) select 'sheep', '210070', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210070');
insert into animal (species, name, origin, sex) select 'sheep', '210080', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210080');
insert into animal (species, name, origin, sex) select 'sheep', '210121', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210121');
insert into animal (species, name, origin, sex) select 'sheep', '210132', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210132');
insert into animal (species, name, origin, sex) select 'sheep', '210171', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210171');
insert into animal (species, name, origin, sex) select 'sheep', '210183', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210183');
insert into animal (species, name, origin, sex) select 'sheep', '210192', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210192');
insert into animal (species, name, origin, sex) select 'sheep', '210198', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210198');
insert into animal (species, name, origin, sex) select 'sheep', '210214', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210214');
insert into animal (species, name, origin, sex) select 'sheep', '210226', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210226');
insert into animal (species, name, origin, sex) select 'sheep', '210230', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210230');
insert into animal (species, name, origin, sex) select 'sheep', '210268', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210268');
insert into animal (species, name, origin, sex) select 'sheep', '210275', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210275');
insert into animal (species, name, origin, sex) select 'sheep', '210325', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210325');
insert into animal (species, name, origin, sex) select 'sheep', '210331', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210331');
insert into animal (species, name, origin, sex) select 'sheep', '210399', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210399');
insert into animal (species, name, origin, sex) select 'sheep', '210417', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210417');
insert into animal (species, name, origin, sex) select 'sheep', '210461', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210461');
insert into animal (species, name, origin, sex) select 'sheep', '210490', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210490');
insert into animal (species, name, origin, sex) select 'sheep', '210506', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210506');
insert into animal (species, name, origin, sex) select 'sheep', '210559', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210559');
insert into animal (species, name, origin, sex) select 'sheep', '210571', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210571');
insert into animal (species, name, origin, sex) select 'sheep', '210602', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210602');
insert into animal (species, name, origin, sex) select 'sheep', '210607', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210607');
insert into animal (species, name, origin, sex) select 'sheep', '210614', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210614');
insert into animal (species, name, origin, sex) select 'sheep', '210617', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210617');
insert into animal (species, name, origin, sex) select 'sheep', '210645', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210645');
insert into animal (species, name, origin, sex) select 'sheep', '210652', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210652');
insert into animal (species, name, origin, sex) select 'sheep', '210670', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210670');
insert into animal (species, name, origin, sex) select 'sheep', '210704', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210704');
insert into animal (species, name, origin, sex) select 'sheep', '210734', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210734');
insert into animal (species, name, origin, sex) select 'sheep', '210736', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210736');
insert into animal (species, name, origin, sex) select 'sheep', '210775', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210775');
insert into animal (species, name, origin, sex) select 'sheep', '210793', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210793');
insert into animal (species, name, origin, sex) select 'sheep', '210822', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210822');
insert into animal (species, name, origin, sex) select 'sheep', '210830', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210830');
insert into animal (species, name, origin, sex) select 'sheep', '210832', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210832');
insert into animal (species, name, origin, sex) select 'sheep', '210840', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210840');
insert into animal (species, name, origin, sex) select 'sheep', '210853', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210853');
insert into animal (species, name, origin, sex) select 'sheep', '210857', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210857');
insert into animal (species, name, origin, sex) select 'sheep', '210880', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210880');
insert into animal (species, name, origin, sex) select 'sheep', '210897', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '210897');
insert into animal (species, name, origin, sex) select 'sheep', '211103', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211103');
insert into animal (species, name, origin, sex) select 'sheep', '211217', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211217');
insert into animal (species, name, origin, sex) select 'sheep', '211270', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211270');
insert into animal (species, name, origin, sex) select 'sheep', '211543', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211543');
insert into animal (species, name, origin, sex) select 'sheep', '211733', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211733');
insert into animal (species, name, origin, sex) select 'sheep', '211789', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211789');
insert into animal (species, name, origin, sex) select 'sheep', '211868', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211868');
insert into animal (species, name, origin, sex) select 'sheep', '211874', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '211874');
insert into animal (species, name, origin, sex) select 'sheep', '220043', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220043');
insert into animal (species, name, origin, sex) select 'sheep', '220078', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220078');
insert into animal (species, name, origin, sex) select 'sheep', '220085', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220085');
insert into animal (species, name, origin, sex) select 'sheep', '220223', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220223');
insert into animal (species, name, origin, sex) select 'sheep', '220289', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220289');
insert into animal (species, name, origin, sex) select 'sheep', '220380', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220380');
insert into animal (species, name, origin, sex) select 'sheep', '220382', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220382');
insert into animal (species, name, origin, sex) select 'sheep', '220419', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220419');
insert into animal (species, name, origin, sex) select 'sheep', '220465', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220465');
insert into animal (species, name, origin, sex) select 'sheep', '220517', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220517');
insert into animal (species, name, origin, sex) select 'sheep', '220636', 'reference', 'female' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '220636');
insert into animal (species, name, origin, sex) select 'sheep', '221063', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221063');
insert into animal (species, name, origin, sex) select 'sheep', '221064', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221064');
insert into animal (species, name, origin, sex) select 'sheep', '221084', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221084');
insert into animal (species, name, origin, sex) select 'sheep', '221114', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221114');
insert into animal (species, name, origin, sex) select 'sheep', '221236', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221236');
insert into animal (species, name, origin, sex) select 'sheep', '221276', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221276');
insert into animal (species, name, origin, sex) select 'sheep', '221468', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221468');
insert into animal (species, name, origin, sex) select 'sheep', '221552', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '221552');
insert into animal (species, name, origin, sex) select 'sheep', '231033', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '231033');
insert into animal (species, name, origin, sex) select 'sheep', '231109', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '231109');
insert into animal (species, name, origin, sex) select 'sheep', '231429', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '231429');
insert into animal (species, name, origin, sex) select 'sheep', '231474', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '231474');
insert into animal (species, name, origin, sex) select 'sheep', '231594', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = '231594');
insert into animal (species, name, origin, sex) select 'sheep', 'A170390', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'A170390');
insert into animal (species, name, origin, sex) select 'sheep', 'A211716', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'A211716');
insert into animal (species, name, origin, sex) select 'sheep', 'CN200113', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113');
insert into animal (species, name, origin, sex) select 'sheep', 'KAM210447', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447');
insert into animal (species, name, origin, sex) select 'sheep', 'KIA210266', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266');
insert into animal (species, name, origin, sex) select 'sheep', 'NAM064', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'NAM064');
insert into animal (species, name, origin, sex) select 'sheep', 'TV210856', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856');
insert into animal (species, name, origin, sex) select 'sheep', 'TV220509', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509');
insert into animal (species, name, origin, sex) select 'sheep', 'WIL200400', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'WIL200400');
insert into animal (species, name, origin, sex) select 'sheep', 'WP200964', 'reference', 'male' where not exists (select 1 from animal where farm_id = current_farm() and origin = 'reference' and name = 'WP200964');

-- The ewes. Born 1 June of the year in the tag, by Richard's rule.
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'G 190492', 'G', 190492, '940 110012824476', 'bred', 'female', '2019-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'G 190492');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200047', 'P', 200047, '940 110012043163', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200047');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200086', 'P', 200086, '940 110012041103', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200086');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200131', 'P', 200131, '940 110012041234', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200131');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200266', 'P', 200266, '940 110012041508', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200266');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200297', 'P', 200297, '940 110012041375', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200297');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200371', 'P', 200371, '940 110012041552', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200371');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200503', 'P', 200503, '940 110012042348', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'PCT Ewe'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200503');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200513', 'P', 200513, '940 110012041400', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Harsh no character'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200513');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200528', 'P', 200528, '940 110012042156', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Nice long white wool Commercial'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200528');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200593', 'P', 200593, '940 110012042182', 'bred', 'female', '2020-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200593');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200601', 'P', 200601, '940 110012042187', 'bred', 'female', '2020-06-01',
  'Merino', '1', null, 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Creamy'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200601');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'P 200644', 'P', 200644, '940 110012040905', 'bred', 'female', '2020-06-01',
  'Merino', '1', null, 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'P 200644');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210106', 'Y', 210106, '940 110015699154', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210106');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210151', 'Y', 210151, '940 110015699206', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210151');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210194', 'Y', 210194, '940 110015700226', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210194');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210204', 'Y', 210204, '940 110015700003', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Good sheep'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210204');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210273', 'Y', 210273, '940 110015701049', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210273');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210287', 'Y', 210287, '940 110015700152', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210287');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210392', 'Y', 210392, '940 110015701241', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Lost Lamb 2023'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210392');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210410', 'Y', 210410, '940 110015701007', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210410');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210446', 'Y', 210446, '940 110015699037', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Wool Good Keep'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210446');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210494', 'Y', 210494, '940 110015699225', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool Keep'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210494');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210572', 'Y', 210572, '940 110015698888', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 3,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210572');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210584', 'Y', 210584, '940 110015698380', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210584');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210613', 'Y', 210613, '940 110015699759', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210613');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210639', 'Y', 210639, '940 110018563830', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210639');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210739', 'Y', 210739, '940 110015698916', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210739');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210799', 'Y', 210799, '940 110015700321', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210799');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210802', 'Y', 210802, '940 110015699378', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210802');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210829', 'Y', 210829, '940 110015701129', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Long white wool'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210829');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210888', 'Y', 210888, '940 110015700203', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210888');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210894', 'Y', 210894, '940 110015700917', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210894');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210916', 'Y', 210916, '940 110015698596', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210916');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210964', 'Y', 210964, '940 110008612423', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210964');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'Y 210998', 'Y', 210998, '940 110015699136', 'bred', 'female', '2021-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 210112'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'Y 210998');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220023', 'R', 220023, '940 110020532299', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220023');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220024', 'R', 220024, '940 110020533596', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220024');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220066', 'R', 220066, '940 110020533645', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220066');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220074', 'R', 220074, '940 110020533669', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220074');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220089', 'R', 220089, '940 110020533643', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220089');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220133', 'R', 220133, '940 110020533563', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220133');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220179', 'R', 220179, '940 110020534667', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220179');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220188', 'R', 220188, '940 110020532215', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220188');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220245', 'R', 220245, '940 110020535057', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220245');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220259', 'R', 220259, '940 110020533890', 'bred', 'female', '2022-06-01',
  'Merino', '1', null, 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220259');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220263', 'R', 220263, '940 110020534171', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Short in the belly and perhaps all over'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220263');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220266', 'R', 220266, '940 110020533995', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220266');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220275', 'R', 220275, '940 110020534006', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220275');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220286', 'R', 220286, '940 110020533934', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220286');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220291', 'R', 220291, '940 110020533921', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220291');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220296', 'R', 220296, '940 110020533915', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220296');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220315', 'R', 220315, '940 110020535073', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220315');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220325', 'R', 220325, '940 110020535049', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220325');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220340', 'R', 220340, '940 110020532237', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 3,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220340');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220342', 'R', 220342, '940 110020532224', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220342');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220359', 'R', 220359, '940 110020532240', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220359');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220400', 'R', 220400, '940 110020534177', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220400');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220407', 'R', 220407, '940 110020535198', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220407');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220416', 'R', 220416, '940 110020533897', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220416');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220455', 'R', 220455, '940 110020534531', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220455');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220467', 'R', 220467, '940 110020532251', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220467');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220498', 'R', 220498, '940 110020533962', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220498');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220532', 'R', 220532, '940 110020532171', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220532');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220548', 'R', 220548, '940 110020533808', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220548');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220549', 'R', 220549, '940 110020533722', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220549');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220574', 'R', 220574, '940 110020533843', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220574');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220577', 'R', 220577, '940 110020533698', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220577');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220653', 'R', 220653, '940 110020530414', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220653');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220668', 'R', 220668, '940 110020535476', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220668');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'R 220682', 'R', 220682, '940 110020530440', 'bred', 'female', '2022-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'R 220682');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230040', 'BU', 230040, '940 110025659206', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230040');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230043', 'BU', 230043, '940 110025659240', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230043');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230045', 'BU', 230045, '940 110025659797', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230045');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230046', 'BU', 230046, '940 110025659819', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230046');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230047', 'BU', 230047, '940 110025659774', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230047');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230050', 'BU', 230050, '940 110025660222', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230050');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230056', 'BU', 230056, '940 110025659248', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230056');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230065', 'BU', 230065, '940 110025659800', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230065');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230067', 'BU', 230067, '940 110025659808', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A plus fleece'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230067');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230075', 'BU', 230075, '940 110025659763', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230075');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230079', 'BU', 230079, '940 110025659776', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230079');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230081', 'BU', 230081, '940 110025659828', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230081');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230082', 'BU', 230082, '940 110025659820', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230082');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230086', 'BU', 230086, '940 110025562306', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'HH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230086');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230088', 'BU', 230088, '940 110025659781', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230088');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230089', 'BU', 230089, '940 110025563234', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'BK SPOT EAR'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230089');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230094', 'BU', 230094, '940 110025562307', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230094');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230099', 'BU', 230099, '940 110043445869', 'bred', 'female', '2023-06-01',
  'Merino', '3', 'PP', 3,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230099');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230104', 'BU', 230104, '940 110025659843', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230104');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230108', 'BU', 230108, '940 110025563558', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230108');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230109', 'BU', 230109, '940 110025562308', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230109');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230119', 'BU', 230119, '940 110025660227', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230119');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230120', 'BU', 230120, '940 110025562277', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'HH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230120');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230128', 'BU', 230128, '940 110025659202', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230128');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230133', 'BU', 230133, '940 110025562252', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230133');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230139', 'BU', 230139, '940 110025659186', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230139');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230142', 'BU', 230142, '940 110025562235', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'GOOD WOOL'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230142');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230154', 'BU', 230154, '940 110025563580', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230154');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230157', 'BU', 230157, '940 110025659212', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230157');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230159', 'BU', 230159, '940 110025659205', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230159');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230163', 'BU', 230163, '940 110025563686', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230163');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230194', 'BU', 230194, '940 110025563534', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230194');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230196', 'BU', 230196, '940 110025562321', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230196');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230200', 'BU', 230200, '940 110025659834', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230200');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230214', 'BU', 230214, '940 110025562270', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230214');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230215', 'BU', 230215, '940 110025562081', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'HH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230215');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230218', 'BU', 230218, '940 110025562323', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230218');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230233', 'BU', 230233, '940 110025659112', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230233');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230237', 'BU', 230237, '940 110025659103', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230237');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230248', 'BU', 230248, '940 110025659100', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230248');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230261', 'BU', 230261, '940 110025659341', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230261');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230262', 'BU', 230262, '940 110025659130', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230262');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230266', 'BU', 230266, '940 110025659272', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230266');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230277', 'BU', 230277, '940 110025659859', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230277');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230283', 'BU', 230283, '940 110025563829', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230283');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230296', 'BU', 230296, '940 110025659278', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230296');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230300', 'BU', 230300, '940 110025659110', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230300');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230306', 'BU', 230306, '940 110025659282', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230306');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230317', 'BU', 230317, '940 110025659296', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'F2 Front'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230317');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230323', 'BU', 230323, '940 110025563434', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230323');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230324', 'BU', 230324, '940 110025563560', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230324');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230329', 'BU', 230329, '940 110025563424', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230329');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230330', 'BU', 230330, '940 110025562179', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230330');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230333', 'BU', 230333, '940 110025659095', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230333');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230348', 'BU', 230348, '940 110025659136', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230348');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230354', 'BU', 230354, '940 110025659270', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230354');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230364', 'BU', 230364, '940 110025562214', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230364');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230371', 'BU', 230371, '940 110025562220', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230371');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230372', 'BU', 230372, '940 110025562175', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230372');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230385', 'BU', 230385, '940 110025563778', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230385');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230386', 'BU', 230386, '940 110025563771', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230386');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230395', 'BU', 230395, '940 110025563521', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230395');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230397', 'BU', 230397, '940 110025562734', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230397');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230400', 'BU', 230400, '940 110025659610', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230400');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230403', 'BU', 230403, '940 110025659058', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230403');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230413', 'BU', 230413, '940 110025659613', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230413');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230420', 'BU', 230420, '940 110025659055', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230420');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230427', 'BU', 230427, '940 110025659652', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'TRAD'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230427');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230430', 'BU', 230430, '940 110025659223', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230430');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230432', 'BU', 230432, '940 110025659655', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230432');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230436', 'BU', 230436, '940 110025660195', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Good fleece'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230436');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230441', 'BU', 230441, '940 110025659620', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230441');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230447', 'BU', 230447, '940 110025659756', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230447');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230451', 'BU', 230451, '940 110025659680', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Hairy'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230451');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230455', 'BU', 230455, '940 110025659573', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230455');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230469', 'BU', 230469, '940 110025659728', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230469');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230480', 'BU', 230480, '940 110025660186', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230480');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230493', 'BU', 230493, '940 110025659744', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230493');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230507', 'BU', 230507, '940 110025659688', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230507');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230523', 'BU', 230523, '940 110025562686', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230523');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230525', 'BU', 230525, '940 110025660198', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230525');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230529', 'BU', 230529, '940 110025659687', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230529');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230540', 'BU', 230540, '940 110025563320', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230540');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230541', 'BU', 230541, '940 110025660209', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230541');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230549', 'BU', 230549, '940 110025659647', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'SPOTTY NOSE'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230549');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230557', 'BU', 230557, '940 110025659526', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230557');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230559', 'BU', 230559, '940 110025659468', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230559');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230562', 'BU', 230562, '940 110025659530', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230562');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230566', 'BU', 230566, '940 110025659470', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230566');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230569', 'BU', 230569, '940 110025659513', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230569');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230573', 'BU', 230573, '940 110025659461', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230573');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230576', 'BU', 230576, '940 110025659583', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'GOOD WOOL'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230576');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230582', 'BU', 230582, '940 110025659516', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Hairy'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230582');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230585', 'BU', 230585, '940 110025659574', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230585');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230589', 'BU', 230589, '940 110025659753', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230589');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230599', 'BU', 230599, '940 110025659000', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230599');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230602', 'BU', 230602, '940 110025659644', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230602');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230612', 'BU', 230612, '940 110025659499', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230612');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230617', 'BU', 230617, '940 110025562690', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'W2'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230617');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230623', 'BU', 230623, '940 110025659480', 'bred', 'female', '2023-06-01',
  'Merino', '3', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230623');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230625', 'BU', 230625, '940 110025659579', 'bred', 'female', '2023-06-01',
  'Merino', '3', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230625');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230633', 'BU', 230633, '940 110025562283', 'bred', 'female', '2023-06-01',
  'Merino', '2', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 230140'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230633');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230634', 'BU', 230634, '940 110025659810', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 230058'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230634');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230666', 'BU', 230666, '940 110025659196', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230666');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230689', 'BU', 230689, '940 110025659782', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 230137'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230689');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BU 230697', 'BU', 230697, '940 110025562232', 'bred', 'female', '2023-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 230147'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BU 230697');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240043', 'BK', 240043, '940 110033045220', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240043');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240052', 'BK', 240052, '940 110033044606', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240052');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240054', 'BK', 240054, '940 110033045218', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240054');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240057', 'BK', 240057, '940 110033044593', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240057');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240059', 'BK', 240059, '940 110033045194', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240059');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240071', 'BK', 240071, '940 110033045178', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240071');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240074', 'BK', 240074, '940 110033044763', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240074');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240075', 'BK', 240075, '940 110033045156', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240075');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240078', 'BK', 240078, '940 110033044764', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240078');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240088', 'BK', 240088, '940 110033044586', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240088');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240089', 'BK', 240089, '940 110033044574', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240089');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240098', 'BK', 240098, '940 110033045217', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240098');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240099', 'BK', 240099, '940 110033044577', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240099');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240104', 'BK', 240104, '940 110033045183', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240104');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240111', 'BK', 240111, '940 110033045153', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240111');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240118', 'BK', 240118, '940 110033045143', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Hairy'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240118');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240131', 'BK', 240131, '940 110033045197', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240131');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240136', 'BK', 240136, '940 110033044632', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240136');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240138', 'BK', 240138, '940 110033044623', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240138');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240145', 'BK', 240145, '940 110033044748', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240145');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240153', 'BK', 240153, '940 110033045237', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240153');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240162', 'BK', 240162, '940 110033045127', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240162');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240169', 'BK', 240169, '940 110033045084', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240169');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240172', 'BK', 240172, '940 110033044674', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Brown eyes'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240172');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240178', 'BK', 240178, '940 110033044695', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240178');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240182', 'BK', 240182, '940 110033042258', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Bare Bum'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240182');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240186', 'BK', 240186, '940 110033045126', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240186');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240187', 'BK', 240187, '940 110033044665', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240187');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240189', 'BK', 240189, '940 110033045115', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240189');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240201', 'BK', 240201, '940 110033044720', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240201');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240208', 'BK', 240208, '940 110033041672', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240208');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240213', 'BK', 240213, '940 110033044671', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240213');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240221', 'BK', 240221, '940 110033041697', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240221');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240239', 'BK', 240239, '940 110033041718', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Hairy'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240239');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240251', 'BK', 240251, '940 110033041703', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 1,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240251');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240262', 'BK', 240262, '940 110033042223', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240262');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240269', 'BK', 240269, '940 110033041647', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240269');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240311', 'BK', 240311, '940 110033039829', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240311');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240318', 'BK', 240318, '940 110033039790', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240318');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240327', 'BK', 240327, '940 110033041664', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'WOOL 2'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240327');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240331', 'BK', 240331, '940 110033039794', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'LL 2026'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240331');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240333', 'BK', 240333, '940 110033045680', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240333');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240334', 'BK', 240334, '940 110033045253', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240334');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240338', 'BK', 240338, '940 110033041662', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240338');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240343', 'BK', 240343, '940 110033041652', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240343');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240346', 'BK', 240346, '940 110033045707', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240346');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240383', 'BK', 240383, '940 110033041226', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240383');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240388', 'BK', 240388, '940 110033044662', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240388');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240393', 'BK', 240393, '940 110033039804', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240393');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240394', 'BK', 240394, '940 110033042167', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240394');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240401', 'BK', 240401, '940 110033041151', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240401');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240404', 'BK', 240404, '940 110033040322', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240404');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240409', 'BK', 240409, '940 110033039845', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Good big lamb'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240409');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240412', 'BK', 240412, '940 110033041221', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Good big lamb'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240412');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240413', 'BK', 240413, '940 110033040298', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240413');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240419', 'BK', 240419, '940 110033040308', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240419');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240420', 'BK', 240420, '940 110033040294', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240420');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240429', 'BK', 240429, '940 110033040340', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PH', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Big lamb'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240429');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240442', 'BK', 240442, '940 110033042197', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240442');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240446', 'BK', 240446, '940 110033045676', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240446');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240454', 'BK', 240454, '940 110033040343', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240454');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240460', 'BK', 240460, '940 110033040356', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240460');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240465', 'BK', 240465, '940 110033044736', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240465');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240482', 'BK', 240482, '940 110033044645', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), null
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240482');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240490', 'BK', 240490, '940 110033042238', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'Was 240489'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240490');
insert into animal (species, stock_code, year_letter, herd_number, nlis_tag, origin, sex, dob,
  breed, grade, horn, born_as, property_id, notes)
select 'sheep', 'BK 240491', 'BK', 240491, '940 110033039786', 'bred', 'female', '2024-06-01',
  'Merino', '1', 'PP', 2,
  (select id from property where farm_id = current_farm() and pic = '3SBES046'), 'A PLUS'
where not exists (select 1 from animal where farm_id = current_farm() and species = 'sheep'
  and origin <> 'reference' and stock_code = 'BK 240491');

-- Pedigree
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'G 190492' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160743' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'G 190492' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '171120' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200047' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180274' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200047' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151058' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200086' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180012' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200086' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '171010' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180936' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181046' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200266' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160246' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200266' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'A170390' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200297' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170734' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200297' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181030' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200371' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '150062' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200371' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '171504' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200503' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170434' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200503' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151057' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200513' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170566' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200513' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '171081' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200528' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160015' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200528' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'A170390' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200593' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170944' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200593' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'A170390' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200601' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170907' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200601' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'NAM064' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200644' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180759' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200644' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181258' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210106' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190411' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210106' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181070' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210151' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190807' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210151' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181046' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210194' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '150052' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210194' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181148' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210204' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190122' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210204' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181982' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210273' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190802' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210273' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210287' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180649' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210287' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151057' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210392' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190344' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210392' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191097' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210410' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180709' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210410' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181070' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210446' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190734' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210446' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191097' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210494' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180871' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210494' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181955' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210572' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170777' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210572' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181955' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210584' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170800' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210584' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191134' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210613' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180118' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210613' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '171007' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210639' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180969' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210639' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151057' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210739' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190720' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210739' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191073' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210799' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170643' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210799' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191073' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210802' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170906' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210802' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191851' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210829' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180211' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210829' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191026' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210888' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160007' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210888' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191026' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210894' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160300' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210894' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191026' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210916' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160560' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210916' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181070' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210964' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210964' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181258' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210998' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190794' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210998' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181046' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220023' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170530' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220023' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201543' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220024' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160015' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220024' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220066' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170009' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220066' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220074' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190038' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220074' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220089' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170084' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220089' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191004' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220133' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '150360' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220133' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201144' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220179' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180674' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220179' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201543' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220188' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190444' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220188' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WP200964' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220245' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200395' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220245' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220259' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170615' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220259' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220263' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160681' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220263' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220266' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220266' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191097' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220275' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200885' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220275' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220286' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200657' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220286' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191097' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220291' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200817' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220291' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191001' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220296' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200840' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220296' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201543' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220315' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190938' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220315' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201264' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220325' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190807' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220325' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WP200964' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220340' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180022' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220340' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181046' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220342' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190746' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220342' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201034' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220359' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180024' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220359' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181962' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200752' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191001' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220407' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200017' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220407' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191072' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220416' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200553' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220416' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201034' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220455' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200285' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220455' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WP200964' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220467' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200444' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220467' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201144' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220498' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180940' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220498' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220532' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '150689' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220532' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220548' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170788' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220548' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220549' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160124' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220549' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181148' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220574' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200206' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220574' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '181962' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220577' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200377' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220577' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191026' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220653' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190310' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220653' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220668' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200102' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220668' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201990' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220682' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190581' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220682' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230040' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200240' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230040' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230043' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230043' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230045' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200139' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230045' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230046' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200278' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230046' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230047' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190156' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230047' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WIL200400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230050' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200578' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230050' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WIL200400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230056' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210888' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230056' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230065' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200612' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230065' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230067' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200886' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230067' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221084' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230075' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180013' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230075' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221064' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230079' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200478' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230079' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230081' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200720' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230081' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230082' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190049' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230082' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230086' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180033' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230086' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230088' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230088' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230089' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200720' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230089' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230094' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190022' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230094' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230099' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200173' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230099' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230104' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180759' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230104' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'CN200113' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230108' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190023' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230108' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WIL200400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230109' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210840' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230109' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'WIL200400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230119' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210832' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230119' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230120' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200031' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230120' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230128' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210171' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230128' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230133' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190540' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230133' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230139' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200630' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230139' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211733' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230142' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180634' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230142' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230154' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180073' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230154' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230157' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200159' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230157' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230159' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180262' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230159' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211733' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230163' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190482' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230163' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230194' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180990' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230194' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201264' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230196' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210645' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230196' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201034' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230200' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210461' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230200' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230214' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190133' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230214' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230215' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190582' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230215' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211103' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230218' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200513' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230218' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230233' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200357' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230233' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230237' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200906' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230237' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211868' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230248' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200279' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230248' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211868' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230261' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180296' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230261' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211868' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230262' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190004' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230262' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221064' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230266' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190389' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230266' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221064' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230277' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190807' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230277' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230283' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200601' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230283' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211733' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230296' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200746' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230296' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211733' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230300' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200038' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230300' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211733' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230306' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180537' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230306' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201034' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230317' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180136' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230317' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230323' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200138' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230323' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230324' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190642' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230324' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230329' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180760' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230329' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201034' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230330' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180136' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230330' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211789' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230333' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180163' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230333' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211789' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230348' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160451' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230348' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211789' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230354' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170306' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230354' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'A211716' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230364' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200505' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230364' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230371' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230371' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230372' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200169' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230372' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'A211716' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230385' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200844' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230385' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230386' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200130' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230386' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230395' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '182700' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230395' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230397' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200778' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230397' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230400' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210007' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230400' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230403' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210399' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230403' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230413' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210775' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230413' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230420' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210226' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230420' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230427' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210559' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230427' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230430' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210670' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230430' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230432' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210490' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230432' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230436' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210132' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230436' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230441' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210417' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230441' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230447' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210183' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230447' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230451' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210602' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230451' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230455' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210853' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230455' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230469' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210192' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230469' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230480' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210121' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230480' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230493' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210964' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230493' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230507' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210704' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230507' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230523' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210734' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230523' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230525' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210070' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230525' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230529' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210880' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230529' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230540' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210617' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230540' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201185' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230541' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210793' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230541' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230549' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210830' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230549' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230557' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210004' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230557' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230559' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210572' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230559' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230562' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210897' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230562' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230566' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230566' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230569' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200106' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230569' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230573' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160878' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230573' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230576' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200177' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230576' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230582' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180076' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230582' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230585' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200375' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230585' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230589' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '183237' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230589' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211103' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230599' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190117' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230599' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211103' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230602' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200992' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230602' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211103' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230612' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200715' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230612' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211543' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230617' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180191' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230617' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '151545' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230623' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200221' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230623' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '191851' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230625' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200308' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230625' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230633' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200313' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230633' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KAM210447' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230634' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210194' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230634' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'KIA210266' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230666' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200163' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230666' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230689' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200500' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230689' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV210856' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230697' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200373' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230697' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240043' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200516' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240043' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231033' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240052' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210506' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240052' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240054' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210607' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240054' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231594' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240057' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190023' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240057' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221114' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240059' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210840' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240059' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240071' limit 1) and sire_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240074' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220467' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240074' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240075' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220455' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240075' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240078' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220085' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240078' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240088' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220532' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240088' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240089' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220549' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240089' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240098' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200532' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240098' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231474' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240099' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220380' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240099' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240104' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220043' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240104' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231429' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240111' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220636' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240111' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240118' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220188' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240118' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240131' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220259' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240131' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240136' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220517' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240136' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240138' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220419' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240138' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240145' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220289' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240145' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211270' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240153' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220465' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240153' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240162' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200479' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240162' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240169' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210639' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240169' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240172' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190197' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240172' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231429' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240178' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190732' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240178' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221552' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240182' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210670' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240182' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240186' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210857' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240186' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240187' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180710' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240187' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221236' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240189' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180617' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240189' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231109' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240201' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210652' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240201' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240208' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210614' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240208' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240213' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180630' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240213' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240221' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210571' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240221' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201978' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240239' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210736' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240239' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240251' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210822' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240251' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211874' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240262' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200439' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240262' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221063' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240269' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210325' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240269' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240311' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200844' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240311' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231033' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240318' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180847' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240318' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240327' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210080' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240327' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240331' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240331' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231109' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240333' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220223' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240333' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '211217' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240334' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220382' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240334' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240338' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240338' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221236' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240343' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '220078' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240343' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240346' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220407' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240346' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240383' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210214' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240383' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240388' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '190938' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240388' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240393' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210275' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240393' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231594' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240394' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200364' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240394' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240401' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210230' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240401' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221114' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240404' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210998' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240404' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240409' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210273' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240409' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '231474' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240412' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240412' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240413' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180284' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240413' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240419' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210268' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240419' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = 'TV220509' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240420' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200500' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240420' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221276' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240429' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200119' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240429' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201983' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240442' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210331' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240442' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240446' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '170039' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240446' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221114' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240454' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '210198' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240454' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '201242' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240460' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200571' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240460' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221063' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240465' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200305' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240465' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240482' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '200510' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240482' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221236' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240490' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '180013' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240490' limit 1) and dam_id is null;
update animal set sire_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '221468' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240491' limit 1) and sire_id is null;
update animal set dam_id = (select id from animal where farm_id = current_farm() and origin = 'reference' and name = '160878' limit 1) where id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240491' limit 1) and dam_id is null;

-- Status: alive and a breeder from the day she was born, there being no other date.
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'G 190492' limit 1), '2019-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'G 190492' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200047' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200047' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200086' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200086' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200131' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200266' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200266' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200297' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200297' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200371' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200371' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200503' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200503' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200513' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200513' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200528' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200528' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200593' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200593' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200601' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200601' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200644' limit 1), '2020-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'P 200644' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210106' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210106' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210151' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210151' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210194' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210194' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210204' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210204' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210273' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210273' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210287' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210287' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210392' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210392' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210410' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210410' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210446' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210446' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210494' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210494' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210572' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210572' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210584' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210584' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210613' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210613' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210639' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210639' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210739' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210739' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210799' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210799' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210802' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210802' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210829' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210829' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210888' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210888' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210894' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210894' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210916' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210916' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210964' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210964' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210998' limit 1), '2021-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'Y 210998' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220023' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220023' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220024' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220024' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220066' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220066' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220074' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220074' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220089' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220089' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220133' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220133' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220179' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220179' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220188' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220188' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220245' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220245' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220259' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220259' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220263' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220263' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220266' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220266' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220275' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220275' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220286' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220286' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220291' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220291' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220296' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220296' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220315' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220315' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220325' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220325' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220340' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220340' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220342' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220342' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220359' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220359' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220400' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220407' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220407' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220416' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220416' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220455' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220455' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220467' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220467' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220498' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220498' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220532' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220532' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220548' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220548' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220549' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220549' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220574' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220574' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220577' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220577' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220653' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220653' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220668' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220668' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220682' limit 1), '2022-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'R 220682' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230040' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230040' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230043' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230043' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230045' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230045' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230046' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230046' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230047' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230047' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230050' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230050' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230056' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230056' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230065' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230065' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230067' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230067' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230075' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230075' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230079' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230079' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230081' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230081' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230082' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230082' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230086' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230086' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230088' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230088' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230089' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230089' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230094' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230094' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230099' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230099' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230104' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230104' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230108' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230108' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230109' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230109' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230119' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230119' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230120' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230120' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230128' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230128' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230133' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230133' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230139' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230139' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230142' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230142' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230154' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230154' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230157' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230157' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230159' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230159' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230163' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230163' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230194' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230194' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230196' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230196' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230200' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230200' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230214' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230214' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230215' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230215' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230218' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230218' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230233' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230233' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230237' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230237' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230248' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230248' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230261' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230261' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230262' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230262' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230266' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230266' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230277' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230277' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230283' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230283' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230296' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230296' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230300' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230300' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230306' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230306' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230317' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230317' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230323' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230323' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230324' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230324' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230329' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230329' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230330' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230330' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230333' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230333' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230348' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230348' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230354' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230354' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230364' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230364' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230371' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230371' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230372' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230372' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230385' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230385' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230386' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230386' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230395' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230395' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230397' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230397' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230400' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230400' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230403' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230403' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230413' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230413' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230420' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230420' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230427' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230427' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230430' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230430' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230432' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230432' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230436' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230436' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230441' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230441' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230447' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230447' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230451' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230451' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230455' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230455' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230469' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230469' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230480' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230480' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230493' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230493' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230507' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230507' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230523' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230523' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230525' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230525' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230529' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230529' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230540' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230540' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230541' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230541' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230549' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230549' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230557' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230557' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230559' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230559' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230562' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230562' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230566' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230566' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230569' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230569' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230573' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230573' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230576' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230576' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230582' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230582' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230585' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230585' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230589' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230589' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230599' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230599' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230602' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230602' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230612' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230612' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230617' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230617' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230623' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230623' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230625' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230625' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230633' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230633' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230634' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230634' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230666' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230666' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230689' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230689' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230697' limit 1), '2023-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BU 230697' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240043' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240043' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240052' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240052' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240054' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240054' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240057' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240057' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240059' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240059' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240071' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240071' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240074' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240074' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240075' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240075' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240078' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240078' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240088' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240088' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240089' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240089' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240098' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240098' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240099' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240099' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240104' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240104' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240111' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240111' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240118' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240118' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240131' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240131' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240136' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240136' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240138' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240138' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240145' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240145' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240153' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240153' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240162' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240162' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240169' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240169' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240172' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240172' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240178' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240178' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240182' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240182' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240186' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240186' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240187' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240187' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240189' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240189' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240201' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240201' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240208' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240208' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240213' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240213' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240221' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240221' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240239' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240239' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240251' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240251' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240262' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240262' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240269' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240269' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240311' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240311' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240318' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240318' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240327' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240327' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240331' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240331' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240333' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240333' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240334' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240334' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240338' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240338' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240343' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240343' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240346' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240346' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240383' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240383' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240388' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240388' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240393' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240393' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240394' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240394' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240401' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240401' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240404' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240404' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240409' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240409' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240412' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240412' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240413' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240413' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240419' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240419' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240420' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240420' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240429' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240429' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240442' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240442' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240446' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240446' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240454' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240454' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240460' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240460' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240465' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240465' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240482' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240482' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240490' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240490' limit 1));
insert into animal_status (animal_id, effective_on, life_state, class, reason) select (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240491' limit 1), '2024-06-01', 'alive', 'breeder', 'Imported from the stud file' where not exists (select 1 from animal_status where animal_id = (select id from animal where farm_id = current_farm() and species = 'sheep' and origin <> 'reference' and stock_code = 'BK 240491' limit 1));

commit;
