-- What Buloke sells, and the butcher's standard sheet for each pack.
--
-- Taken from the Squarespace shop as it stood in November 2026 (names,
-- sizes, prices, SKUs, the $120 deposit) and from the butcher's
-- workbooks (Beef Orders H20260629, Lamb Orders H20251110) for the cut
-- sheets. Prices, wording and sheets are edited in Sales -> Products
-- from here on; this file is how they first got in.
--
-- Bank details are deliberately not here. They are typed into
-- Sales -> Settings and live only in the database.
--
-- Safe to run more than once: a product that exists is left exactly
-- as it is, edits and all.

select set_config('app.farm', (select id::text from farm where slug = 'buloke'), false);

insert into farm_business (abn, phone, email, website, invoice_terms_days, order_prefix, first_invoice_no)
values ('21 620 822 033', '0407 841 617', 'bulokefarm@gmail.com', 'www.bulokefarm.com.au', 15, 'BF', 1350)
on conflict (farm_id) do nothing;

-- ------------------------------------------------------------
-- Beef
-- ------------------------------------------------------------

insert into product (slug, name, kind, summary, description, image_url, deposit_cents, sort, cut_sheet)
values ('beef', 'Beef', 'beef',
  'Dry-aged, grass-fed beef packs from 12 kg to a whole beast.',
  $txt$Delivery throughout Melbourne and up the East Coast.

All our beef packs contain Porterhouse Steak, Rump Steak, Scotch Fillet, Eye Fillet, Oyster Blade Steak, Blade Roast, Stewing Steak, Osso-Bucco, Silverside Roast, Topside Roast and Brisket. They come as a variety of Steaks, Roasts, Schnitzel, Sliced or Diced, and Fine Mince.

Each carcass can dress out differently and animals can grow at slightly different rates. A deposit is required to secure your order and once butchered and packed we will invoice you with the balance remaining. Our price is based on retail weight, meaning the weight of the product as it is sold.$txt$,
  '/img/beef-pack.jpg', 12000, 10,
  $json${
    "columns": ["Cut", "Choices", "Butchering selection", "Size (g)"],
    "rows": [
      ["Eye Fillet", "Steak or Roast", "2 x 125gm steaks", "250"],
      ["Scotch Fillet", "Steak or Roast", "2 x 300gm steaks", "600"],
      ["Porterhouse", "Steak or Roast", "3 x 300gm steaks", "900"],
      ["T-Bone", "Steak", "Not to be Done", ""],
      ["Rump Steak", "Gourmet Steak, Diced, Traditional Steak", "2 x 300gm steaks (Gourmet)", "600"],
      ["Osso Bucco", "Osso or Gravy Beef", "2 x pieces of osso bucco", "600"],
      ["Silverside", "Roast, Diced, Stir Fry", "1 x 1kg roast", "1000"],
      ["Topside", "Roast, Diced, Stir Fry", "1 x 1kg roast", "1000"],
      ["Oyster Blade Steak", "Steak", "2 x 200gm steaks", "400"],
      ["Bolar Blade", "Steak, Roast, Diced", "1 x 1kg roast", "1000"],
      ["Round Steak", "Roast, Diced, Stir Fry, BBQ Steak", "Schnitzels (600g)", "600"],
      ["Brisket", "Rolled Whole or Minced", "1 x 1kg Rolled Whole", "1000"],
      ["Chuck", "Stew, Diced, Minced", "4 x 500gm beef diced", "2000"],
      ["Mince", "Mince, hamburger mince", "4 x 500gm beef mince", "2000"],
      ["Flank", "Whole or Minced", "Mince (fine)", ""],
      ["Beef Marrow Bones", "Cut", "Marrow bones (cut into pieces please) 500gm", "Small Bag"],
      ["Other Bones", "Cut", "All other bones you can keep", ""],
      ["Ox tail, All Offal", "Options", "If available please keep aside", ""]
    ],
    "notes": [
      ["Smaller Roasts", "Means we try to have more Roasts to divide up between packs. If we had 12 or more orders we would like to get an even spread of each Roast into a Box."],
      ["12kg Pack", "This is Beef weighed in Pack. If we include Marrow Bones the Box will weigh more. Marrow Bones are considered outside of the 12kg weight."],
      ["Soup Bones", "Generally include a small bag of cut up Marrow Bones. Weight of Soup Bones is not included in the 12kg; this is extra."]
    ]
  }$json$::jsonb)
on conflict (farm_id, slug) do nothing;

insert into product_option (product_id, sku, name, label, size_kg, price_cents, cartons, sheet_multiple, sort)
select p.id, v.sku, v.name, v.label, v.size_kg, v.price_cents, v.cartons, v.mult, v.sort
  from product p,
       (values ('BFB12KG',  '12kg Beef Pack',    'Small',       12,  32400,  1,  1, 10),
               ('BFB24KG',  '24kg Beef Pack',    'Medium',      24,  64800,  2,  2, 20),
               ('BFB48KG',  '48kg Beef Pack',    'Family',      48, 124800,  4,  4, 30),
               ('BFB96KG',  '96kg Beef Pack',    'Large',       96, 249600,  8,  8, 40),
               ('BFB144KG', '144kg Whole Beast', 'Whole Beast', 144, 360000, 12, 12, 50))
         as v(sku, name, label, size_kg, price_cents, cartons, mult, sort)
 where p.farm_id = current_farm() and p.slug = 'beef'
   and not exists (select 1 from product_option o where o.product_id = p.id and o.sku = v.sku);

-- The one thing beef asks (migration 74): a choice, never a box to type in.
-- Null means never set; a product cleared on purpose holds [] and is left alone.
update product
   set questions = '[{"label": "Soup bones", "choices": ["Yes please", "None"]}]'::jsonb
 where farm_id = current_farm() and slug = 'beef' and questions is null;

-- ------------------------------------------------------------
-- Lamb
-- ------------------------------------------------------------

insert into product (slug, name, kind, summary, description, image_url, deposit_cents, sort, cut_sheet)
values ('lamb', 'Lamb', 'lamb',
  'Whole and half lamb packs, $22 a kilo.',
  $txt$Whole Lamb Packs $440, Half Lamb Packs $220.

WHOLE LAMB
4 x Lamb Shanks, Approx 6-8 Loin Chops, Approx 6-8 Chump Chops, 1 x Large Loin Roast
1 x 8 Point Rack of Lamb, 8 x Lamb Cutlets
2 x Half Leg Roasts (Bone In), 1 x Large Boneless Leg Roast, 1 x Forequarter Half (Bone In)
Approx 5-7 BBQ Chops, Lamb Neck Chops
Lamb Spare Ribs, Lamb Mince, Lamb Bones

HALF LAMB
2 x Lamb Shanks, Approx 6-8 Loin Chops, Approx 6-8 Chump Chops
1 x 8 Point Rack of Lamb, 2 x Half Leg Roasts (Bone-In), 1 x Forequarter Half (1/2) Rolled
Approx 5-7 BBQ Chops, Lamb Spare Ribs, Lamb Mince, Lamb Bones

Each carcass can dress out differently and lambs can grow at slightly different rates. A deposit is required to secure your order and once butchered and packed we will invoice you with the balance remaining. Our price is $22 per kilogram. This is retail weight, meaning the weight of the product as it is sold.$txt$,
  '/img/lamb-pack.jpg', 12000, 20,
  $json${
    "columns": ["Cut of lamb", "Packaging instructions"],
    "rows": [
      ["2 x Lamb Shanks", "1 bag with 2 shanks in it"],
      ["Approx 6-8 Loin Chops", "2 bags (divide chops between each bag)"],
      ["Approx 5-8 Chump Chops", "2 bags (divide chops between 2 bags)"],
      ["1 x 8 Point Rack of Lamb", "1 bag"],
      ["2 x Half Leg Roasts (Bone In)", "2 bags - one roast in each bag"],
      ["1 x Forequarter Roast (1/2) rolled", "1 bag"],
      ["Approx 5-7 BBQ Chops", "3 bags (divide chops between 3 bags)"],
      ["Lamb Spare Ribs", "1 bag"],
      ["Lamb Mince", "1 bag"],
      ["Lamb Bones", "1 bag"]
    ],
    "notes": [
      ["10kg Pack", "This is Lamb weighed in Pack. Minimum of 10kg. 16 labels."]
    ]
  }$json$::jsonb)
on conflict (farm_id, slug) do nothing;

insert into product_option (product_id, sku, name, label, size_kg, price_cents, cartons, sheet_multiple, sort, cut_sheet)
select p.id, v.sku, v.name, null, v.size_kg, v.price_cents, v.cartons, 1, v.sort, v.sheet::jsonb
  from product p,
       (values ('BFL10KG', '1/2 Lamb Pack',   10, 22000, 1, 10, null),
               ('BFL20KG', 'Whole Lamb Pack', 20, 44000, 2, 20,
                $json${
                  "columns": ["Cut of lamb", "Packaging instructions"],
                  "rows": [
                    ["4 x Lamb Shanks", ""],
                    ["Approx 6-8 Loin Chops", ""],
                    ["Approx 6-8 Chump Chops", ""],
                    ["1 x Large Loin Roast", ""],
                    ["1 x 8 Point Rack of Lamb", ""],
                    ["8 x Lamb Cutlets", ""],
                    ["2 x Half Leg Roasts (Bone In)", ""],
                    ["1 x Large Boneless Leg Roast", ""],
                    ["1 x Forequarter Half (Bone In)", ""],
                    ["Approx 5-7 BBQ Chops", ""],
                    ["Lamb Neck Chops", ""],
                    ["Lamb Spare Ribs", ""],
                    ["Lamb Mince", ""],
                    ["Lamb Bones", ""]
                  ],
                  "notes": [
                    ["20kg Pack", "This is Lamb weighed in Pack. Minimum of 20kg."]
                  ]
                }$json$))
         as v(sku, name, size_kg, price_cents, cartons, sort, sheet)
 where p.farm_id = current_farm() and p.slug = 'lamb'
   and not exists (select 1 from product_option o where o.product_id = p.id and o.sku = v.sku);

-- ------------------------------------------------------------
-- Pies. Not cut from a harvest, not sent by carrier.
-- ------------------------------------------------------------

insert into product (slug, name, kind, summary, description, image_url, deposit_cents, from_harvest, local_only, sort)
values ('pies', 'Gourmet Wagyu X Beef Mince Pies', 'other',
  'Packs of two, frozen, made from our own beef.',
  $txt$Pack of 2 - Gourmet Wagyu X Beef Mince Pies. We've taken our premium farm-raised beef and turned it into something truly comforting — a gourmet pie made with care, using local ingredients and real flavours. Perfect for quick dinners, weekend lunches, or those nights you just want something hearty and wholesome.

Bake at 180˚C for 40 minutes from frozen, or until heated through. Keep frozen pies in the freezer at or below -18˚C.

Ingredients: Premium Wagyu Mince, Onion, Herbs & Spices (Garlic, Thyme, Parsley, Sage, Rosemary, Pepper), Tomato (Tomato, Thickener (1422), Acidity Regulator 330), Beef Stock (Sea Salt, Maize Maltodextrin, Cane Sugar, Natural Vegetable Flavours, Yeast Extract, Rice Flour, Dehydrated (Onion, Celery, Garlic), Caramelised Sugar Syrup, Disodium Guanylate & Inosinate, Canola Oil), Worcestershire Sauce (Sugar, Apple Paste, Treacle, Food Acid (260), Thickener (1422), Salt, Spices, Colour (150c), Natural Flavours, Lemon Oil, Spice Extract), Corn Flour, Water, Sugar.

Pastry: Flour (Wheat), Water, Salt, Egg, Animal Fats, Baking Powder, Vegetable Margarine [Vegetable Oil, Emulsifier (471, Soybean Lecithin), Food Acid (330), Antioxidant (307B), Natural Colour (160A)].

Made on premises that contains all known allergens. Baked on equipment that processes Sesame, Milk, Almonds, Fish, Crustaceans, Barley, Pecans, Peanuts and Sulphites. Contains Wheat, Gluten, Soy and Egg.

If you're interested in our pies and you're outside of our local postcodes, please just email us and we'll see what we can arrange.$txt$,
  '/img/pies.jpg', 0, false, true, 30)
on conflict (farm_id, slug) do nothing;

insert into product_option (product_id, sku, name, label, size_kg, price_cents, cartons, sort)
select p.id, v.sku, v.name, v.label, null, 1500, 0, v.sort
  from product p,
       (values ('PIE2',  '2 x Gourmet Wagyu X Beef Mince Pies', 'Classic', 10),
               ('PIE2P', '2 x Gourmet Wagyu X Beef Mince Pies (with a hint of Pepper)', 'With a hint of pepper', 20))
         as v(sku, name, label, sort)
 where p.farm_id = current_farm() and p.slug = 'pies'
   and not exists (select 1 from product_option o where o.product_id = p.id and o.sku = v.sku);

-- What is asked of the butcher for whatever is left of a beef carcass
-- once the packs are cut. Copied onto each new beef harvest by the
-- page; kept here as the note of what the default was.
--
--   Eye Fillet 125gm steaks · Scotch Fillet 300gm steaks · Porterhouse 300gm steaks
--   Rump 300gm steaks (Gourmet) · Osso Bucco pieces · Silverside and Topside 500gm diced
--   Oyster Blade 200gm steaks · Bolar Blade 1kg roasts · Round as Schnitzels (600g)
--   Brisket 1kg Rolled Whole Roasts · Chuck 500gm diced · Mince 500gm packs
--   Flank minced (fine) · Marrow bones cut, 500gm · other bones the butcher keeps
--   Ox tail and offal kept aside if available
