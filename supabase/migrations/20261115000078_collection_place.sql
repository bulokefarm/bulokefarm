-- ============================================================
-- 78. Where the carrier collects from.
--
-- A delivery run starts with a collection: the carrier picks the
-- cartons up from the butcher's shop before it takes them anywhere.
-- The row the Delivery page wrote for that was a guess. It had the
-- butcher's name and, under Delivery Address, the harvest's pick-up
-- place in words ("Cherry Tree Organics, Beaconsfield"): no street,
-- no suburb, no state, no postcode. A driver cannot be sent to that.
--
-- A collection as the carrier's own system holds one (4 June 2026)
-- has the shop's street address, suburb, state and postcode, a window
-- of 11:00-18:00, the farm's phone and email as the contact, and the
-- instruction "Pick up from Cherry Tree Organics".
--
-- The cartons are collected from the same place every time, so the
-- place is the farm's, not each harvest's: typed once in Sales ->
-- Settings, kept on farm_business. harvest.pickup_place stays what it
-- is — words for a customer who is picking up their own box.
--
-- The phone and email on the collection are the farm's own (they are
-- who the carrier rings), so there is no second phone here.
--
-- Safe to run more than once.
-- ============================================================

alter table farm_business
  add column if not exists collect_name     text,
  add column if not exists collect_street   text,
  add column if not exists collect_suburb   text,
  add column if not exists collect_state    text,
  add column if not exists collect_postcode text,
  add column if not exists collect_window   text,
  add column if not exists collect_note     text;

alter table farm_business drop constraint if exists farm_business_collect_postcode_check;
alter table farm_business add  constraint farm_business_collect_postcode_check
  check (collect_postcode ~ '^[0-9]{4}$');
alter table farm_business drop constraint if exists farm_business_collect_window_check;
alter table farm_business add  constraint farm_business_collect_window_check
  check (collect_window ~ '^[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}$');

comment on column farm_business.collect_name is
  'Where the carrier collects the cartons from: the butcher''s shop. Goes on the collection row of the manifest (Sales -> Delivery).';
comment on column farm_business.collect_street is
  'Street address of the collection, as the carrier is to have it. Suburb, state and postcode are their own columns, as on the manifest.';
comment on column farm_business.collect_window is
  'When the carrier may collect, as the manifest writes a time window: 11:00-18:00. Blank means that.';
comment on column farm_business.collect_note is
  'Instructions for the driver on the collection. Blank means "Pick up from" and the name.';
