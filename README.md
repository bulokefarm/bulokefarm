# Buloke Farm

Livestock records for 267 North Canal Rd, Trafalgar, Victoria.
PIC 3BWWY089.

Cattle and sheep on one property, with a second PIC to come. Replaces a
55-column spreadsheet and several others besides. Six static HTML pages
talking to a Supabase Postgres database, and a public website beside
them that takes orders into the same database. No build step, no
server, no framework — the phone app is about 41 KB over the wire.

Since migration 55 the one database holds more than one farm. Each
farm's people see only that farm's records; the pages, the migrations
and the deployment are shared. See *A farm is the layer above the PIC*
below, and `farm_scope_plan.md` for how it was done and proved.

Live at **https://admin.bulokefarm.com.au**

---

## 1. The pages

| File | Path | Where it's used |
|---|---|---|
| `public/index.html` | `/` | Phone. Herd, paddock map, family tree, tank store, all recording. |
| `public/reports.html` | `/reports` | Laptop. LPA records, shed work, joining register. Printable, editable, with change history. |
| `public/stock.html` | `/stock` | Laptop. Livestock trading account by financial year, for tax. |
| `public/map.html` | `/map` | Laptop. Tracing paddock boundaries on satellite imagery, and spraying. |
| `public/sales.html` | `/sales` | Laptop. Customers, orders, payments, invoices, harvests, the carrier's manifest, products. |
| `public/butcher.html` | `/butcher` | The butcher's login. Summary, customer list and a cut sheet per box, for printing. |
| `site/` | `www.bulokefarm.com.au` | The public website: what we sell, the farm, and the order form. A second Pages project. |

The phone app links to the others under **Record → Manage → On a
laptop**. `public/nav.js` is the shared menu.

### What the app does

**Herd** — three views behind one toggle. *List* filtered by class,
*Paddocks* grouped by where stock are, *Family tree* showing descent
down either the dam or the sire line.

**Map** — paddock boundaries as flat SVG. No tiles, no map library: the
expensive work happens once in the boundary editor, and the phone just
draws stored coordinates.

**Due** — expected calvings and lambings by season, derived from
joinings.

**Record** — feed out, move mob, weights, treatments, joinings, join
planning, calvings, shed work, stock brought on, sale/consignment. Plus the flasks (tank store and
straw movements) and Manage (feed store, bulk update, field visibility, and for a stud that
records with Sheep Genetics, breeding values: drop in the ASBV export CSV).

**Correcting a joining** — a joining on an animal's card opens: result,
dates, sire, season, attempt. Anyone who records can correct one; an
owner can delete one that never happened. The joining register on
`/reports` edits the same record.

**Days on feed** — every herd row and animal card shows how long stock
have been on a ration, what it is, and the projected empty date; and for
90 days afterwards, how long the finished run lasted. Costs no extra
query: it rides on `v_animal_current`. Taking a mob off is
**Record → Manage → Feed store → the load → "the feeder ran dry"**, or
the *Fed until* field on the row in `/reports`.

**Stock account** — opening, purchases, natural increase, sales, deaths,
rations, closing. One schedule per species per financial year, with the
animals behind every figure.

---

## 2. Design decisions

These are the things to re-read before changing anything.

**Nothing is silently rewritten.** Treatments, feeding, consignments,
weights, calvings, joinings, shearing, straw movements and animal
records all have change-log triggers capturing before, after, who and
when. Corrections are normal; invisible corrections turn a compliance
record into an assertion.

**Derived values are never stored.** Age, growth rate, head counts,
stocking rate, slaughter-clear dates, feed remaining, straws on hand,
the whole trading account — all computed on read. Roughly a third of the
spreadsheet's columns were stored calculations, and they had gone stale.

**A count is the sum of its movements.** Feed stock and straws both work
this way: a delivery, a use, a discard, a recount are each a row, and
the number on screen is their total. A counter that can disagree with
its own working is worse than no counter.

**Reports show their working.** The trading account is counted off a
per-animal view, so opening a year lists the animals behind every
figure. It is allowed not to reconcile — a mismatch means a status
history that can't be true, and June is when you want to hear about it.

**Species is a scope, not a filter.** A ewe is not a breeder cow and a
lamb is not a calf, so the words on the buttons depend on which mob you
are looking at. Set once, it follows through the herd list, every record
form, Due and the reports.

**The register keeps what was written.** Straw movements name the cow as
she was written on the sheet — `SD U 08`, `Tonnie T14` — alongside a
nullable link to an animal. The text is the record; the link is an
improvement. `cryo_ref_code()` resolves what it can and is re-run
whenever a herd is imported.

**Feeding targets a paddock, not animals.** You record that the back
gully got two rolls; who ate it comes from `paddock_stay`. The Irwins
grain runs are the exception — they came from a per-animal sheet and
name their animals directly, so both shapes have to be counted.

**Spraying is a record against the ground, not the stock.** Section 2 is
a chemical put into an animal; Section 3B is a chemical put onto a
paddock. They share nothing useful — 3B has no animals attached at the
time and its withholding period governs *grazing*, not slaughter — so
they are separate tables. A tank mix is one `spray_event` with a
`spray_product` row per product, each carrying its own batch number and
withholds, because that is how the labels read and how the mix clears.

**Three ways in, one record.** Spraying can be entered from **Record →
Spraying** on the phone, from a selected paddock on `/map`, or from
**+ Record spraying** on `/reports`. The map is where the job is
usually thought about, so it also hatches any paddock inside a grazing
withhold and labels it `NO GRAZE`. All three write the same
`spray_event` plus one `spray_product` per thing in the tank.

**Every spray names paddocks, plural.** A boom run crosses three
paddocks on one tank, one wind reading, one batch number; recorded as
three events that is three chances to type the batch differently.
`spray_paddock` joins them, same shape as `treatment_animal`. Area and
`location_note` sit on the join, because 8 ha of one paddock and 0.3 ha
along the fence of another is still one run. A paddock cannot be
deleted while it holds spray history.

Migration 40 let free text stand in for the paddock so a laneway had
somewhere to go; 41 took it back, because the free-text case was
invisible to `paddock_graze_block()` — the records least likely to be
remembered were the ones the guard could never catch. A laneway worth
spraying is a laneway worth a paddock row.

**`record_spray()` writes a pass in one transaction.** A join table
cannot enforce "at least one" the way NOT NULL could, and the browser
sends one statement at a time — so pass, paddocks and products could
half-save, and being told it failed after the pass was already on file
gets the same spray entered twice. The function refuses an empty
paddock list, and counts the rows that actually landed rather than
trusting the length of what was sent: an id that is not a paddock joins
to nothing and would otherwise leave a pass covering nowhere.

**No safe-to-graze date is stored.** It is `applied_on + withhold`, and
the binding one is the latest across the mix. `v_paddock_withhold` does
that arithmetic and `move_animals` refuses a paddock still inside it.
A withhold that is null means *unknown*, never zero: the paddock is
held for 60 days and the report names the gap rather than clearing it
by guesswork. Overriding the refusal is allowed and is written onto the
`paddock_stay` reason, so a deliberate call stays visible.

**A run is not a drop.** Rolling out a bale feeds them that day. A self
feeder they stay on for weeks. Both are LPA 3C records and both count
against the store, but only a run (`feed_event.is_run`) accrues days on
feed. Without the distinction, every cow in a paddock that once got a
bale reads as on a finishing ration, climbing daily, forever.

**An empty silo is not a mob off feed.** `feed_source.exhausted_on`
means there is nothing left to feed out. `feed_event.ended_on` means the
animals came off. For a self feeder those are weeks apart, and only the
second stops the clock. Nothing infers one from the other: the estimate
says when it is likely, the yard says when it is true.

**PIC is ownership, not location.** `animal.property_id` is whose the
animal is — for NVD, NLIS and tax. `paddock.property_id` is which land.
With two PICs on one property those are different things, and the
paddock's PIC must never be used to filter a herd.

**A farm is the layer above the PIC.** `farm` is who runs the app on
this land; `property` is which registration each animal and paddock
sits under. Richard and Dad are two own-PICs under the one farm and
stock together; Toland Merino is another farm with PICs of its own.
Every table carries `farm_id`, and every policy asks "is this row on
the session's farm" before it asks about role. The pages never send
`farm_id`: a root table defaults it from `current_farm()`, and a table
that links to others takes it from what it links to, by a trigger that
also refuses a link to anything the session cannot see — foreign keys
are checked as the table owner and would not. Uniqueness that used to
mean "one in the database" now means one per farm: stock codes, NLIS
tags, NVD serials, lineage names, PICs in the address book, and the
primary PIC. Nothing is stored twice and no view had to change,
because every view runs as the caller. A login belongs to a farm
through `farm_member`, which is where role and active live;
`farm_user` is a profile. Owners add people by the email they signed
up with, under **Record → Manage → Who can see this farm**. The
Buloke mark is the app's own mark, on the loading screen and the
home-screen icon for every farm; a farm's own logo, if it has one,
appears once signed in.

**A calving puts the calf on the ground.** Recording a calving used to
write one row against the cow, and the calf was a line in her history
with nothing in the herd to tag, sex or drench. `record_calving()`
writes the calving, the calf, its status and its paddock in one
transaction, the same shape as `record_spray()`. The calf carries this
year's letter and no number — `stock_code` stays null until a tag is
decided in the yard, so it shows as `X ?` under the year's drop and
twins don't collide on the unique index. The open joining nearest the
date names the sire and is resolved by it. When the tag is written
later, `animal_code_parts` fills the letter and number in from it.
`year_letter()` takes the letter the herd already uses for that year,
falling back to the NLIS cycle (no I or O; 2005 was A, so 2026 is X);
sheep get the colour letter instead, see below.
A row on **Due** opens the cow's card, so the calving is two taps from
the list of who is due.

**A lamb is recorded against the paddock, not the ewe.** Sheep run as
mobs: the rams go out to a paddock of ewes, and at lambing what is
seen is a lamb in the back gully, not which ewe it came from.
`record_drop()` takes what is actually known — paddock, day, how many,
the ram that was out with that mob, sex if checked — and puts each
lamb in the herd the same way as a calf: this year's letter, no
number, classed lamb, in that paddock, dam null. The form suggests the
ram from the natural joinings that name the paddock and are due about
then. No calving row is written and no ewe's expectation is resolved,
because guessing a ewe would say something the record doesn't know.
Numbers go on at marking through **Record → Manage → Tag the drop**,
one row per untagged animal by paddock.

**A mob comes off Due as a group.** A mob joining writes one joining
per ewe and one expectation per ewe, and since lambs are recorded by
paddock none of those rows ever resolves on its own. When lambing is
over, the mob's heading on **Due** offers *Lambing over*:
`close_expectations()` marks every joining behind the mob with the
outcome `closed` — season over, result not recorded per dam — with a
note, and `refresh_expectation()` drops the expectations as it always
has when no live joining remains. No ewe is called lambed or empty;
the joining's change log keeps the before and after; a closed joining
sits with the untested ones in the conception-rate views rather than
counting as a failure. An expectation with no joining behind it is
refused by name, not deleted. A ewe you do know about gets her lambing
recorded, or her joining marked empty, before the mob is closed.

**A season is a financial year.** It runs July to June and is named
for the year the calf or lamb is due in: due 21 Sept 2027 is 2027-2028.
It is not typed once there is a date — `season_of()` works it out from
a joining's due date and a plan's forecast, so moving either moves the
season. Only an undated joining or plan keeps the season it was given.

**A plan is not a joining.** **Record → Join planning** is the same two
forms as a joining — a straw to one cow, a bull to a mob — writing a
`planned_joining` row instead. Everything that reads `joining` treats
it as evidence: the Due list, the conception-rate views, which joining
a calving answers, and the straw count. A plan on that table would need
every one of them to know to skip it, so it has a table of its own with
the things only a real joining has left off — attempt, bull-out date,
confidence, outcome. The forecast is not stored: `v_planned_joining`
works it out as `planned_on` plus the plan's nominated gestation, else
the dam's own, else 285 or 145, so correcting a cow's gestation moves
every open forecast for her. A nominated figure on a plan does not
rewrite the cow — the joining form does that because a joining is her
being measured, and a plan is not. A dam can carry a plan for each join —
the first AI, a back-up straw, then usually the bull — numbered by the
same `attempt` a joining has, one open plan per dam, season and attempt.
Recording the joining closes the plan it answers: a trigger sets
`joining_id` on the open plan for that dam, season and attempt (else
her earliest open one), so the joining is recorded exactly as before
and nothing is retyped. An earlier plan still open when a later joining
goes in has been passed over and is dropped; when a joining is marked
in calf or calved, the back-ups after it are dropped as of the test. Dropping a plan sets `cancelled_on`; the row stays. The card
shows her open plan, the herd list has a *Planned* filter, the joining
register on `/reports` lists open plans under their own filter whatever
the report period, and the AI form pre-selects the planned straw when
the cow has one. The straw select on that form has a search box above
it, since the tank list is long and a phone select is a wheel.

**Sheep run a different alphabet.** Cattle stock codes carry the NLIS
year letter — X for 2026 — and the app colours them from a palette of
its own. Sheep tags are coloured on the NLIS eight-year cycle and the
code starts with the colour: BK black 2024, W white 2025, O orange
2026, G light green 2027, P purple 2028, Y yellow 2029, R red 2030,
BU sky blue 2031, then round again — two letters where one would be
ambiguous, so a sheep's "letter" can be two characters. `year_letter(date, species)` hands
out both. For cattle the herd is the record — the letter tagged cattle
born that year already carry wins over the arithmetic; untagged
placeholders don't vote, since they are this function's own output.
For sheep the cycle is the rule as stated and nothing votes. The tag
block for a sheep is drawn in the colour its letter names, so it is
the colour in the ear; the card names the colour and the drop. Light
tags get dark ink.

**Reference animals.** `animal` also holds sires and dams that were
never on the property (`origin = 'reference'`). Pedigree stays a single
self-join instead of nullable text columns.

**An order is written down once.** It used to be typed four times: into
the sales spreadsheet, into the butcher's workbook, into the carrier's
manifest, into the invoice. `customer_order` and `order_line` are the
one record; the butcher's sheets (`butcher_sheet()`), the Blackbird
manifest (**Sales → Delivery**) and the invoice (`issue_invoice()`) are
read off it. Totals, what is owing, and how many kilos of a harvest are
sold are computed (`v_order`, `v_harvest`), never stored; what has been
paid is the sum of `order_payment` rows, deposit and balance and refund
alike. Money is integer cents, ex GST: meat is GST-free and freight
carries 10%, so the invoice's BAS summary is two sums.

**An invoice keeps what it said.** `issue_invoice()` copies the order as
it stands — who, where, each line, the freight — into `invoice` and
`invoice_line`, and from then on the invoice is its own record. A
customer who moves, or a price that changes, must not rewrite an invoice
already sent. Numbers are handed out per farm by trigger, starting from
`farm_business.first_invoice_no`; a void invoice keeps its number.

**A harvest is what orders are placed against.** One kill: its dates,
its butcher, what it should yield. *Open* shows its dates on the website
and takes web orders; *planned* shows the month. The butcher sees a
harvest only once it is released to them (`butcher_released_at`), so a
half-entered order book is not mistaken for the job.

**The butcher is on the farm but not in the herd.** A fourth role.
`can_read()` now names the roles that read (owner, manager, viewer); a
butcher is a member and not a reader, so every policy written before
the role existed refuses them without being touched. They read through
two functions that hand back exactly what goes on the printed sheets —
who the box is for, a phone number, where it is going if it is being
sent, what to cut. No prices, no payments, no emails.

**The shop front is three functions.** Someone with no login can ask
what is for sale and when the next harvest is (`shop_front`), whether
the carrier goes to a postcode (`delivery_lookup`), and place an order
(`place_order`) — and nothing else; anon reads no table. A web order is
a request: status `new`, nothing paid, priced from the product and not
from what the browser sent. `place_order` never changes a customer it
already knows — anyone can type anyone's email — so what was typed is
kept on the order and **Sales** shows the two side by side. Five orders
an hour from one email, forty in all, then it asks people to write.

**A pack is what the cut sheet says it is.** The old shop's beef form
had a free-text box for every cut. In five years they were filled in
a handful of times, each a small promise the butcher then had to keep
for one pack among a dozen; they did not come across. What a customer
may choose is a question with a short list of answers
(`product.questions`), never a box to type in. Beef asks one — soup
bones, yes or none — and the answer (`order_line.answers`) prints on
the box's cut sheet. The first choice is the standard: it is what an
order gets if nothing is said. `place_order()` keeps only answers to
questions the product really asks, from the choices it really offers.

**A harvest is counted in boxes.** Six lambs are twelve boxes; three
are spoken for; nine are left. A box is what is sold and what is packed
(a whole lamb is two, a half is one, a 24 kg beef pack is two), so the
balance is kept in boxes and said the other way beside them — lambs for
lamb, kilos for beef. *For sale* is `harvest.boxes_for_sale` if someone
typed it; otherwise it is worked out: head × 2 for lamb, and for beef
the kilos for sale ÷ the smallest box that kind is sold in, once those
kilos are known. *Sold* is every box on the butcher's sheets. The sum
is `v_harvest_balance`, written once and read by three things: the
butcher's summary, the website (the landing page leads with the coming
harvests and what is left of each, and each pack says how many the
harvest still has room for), and `place_order()`, which puts a website
order on the first open harvest of its kind with room for it. A full
harvest behaves as a closed one always has: the website says *Fully
booked*, the order is still taken, and it waits under **No harvest**
for a person to place. Until the head or the weight is entered nothing
is known, nothing is said, and nothing is held back.

**The page does not write what nobody looked at.** A harvest's
“Remaining” sheet is not on the form; it is behind a button. A Sales
page left open for a day once saved a harvest and wrote its day-old
copy of that sheet back over one cleared since — which is how a lamb
harvest came to tell the butcher what to do with the eye fillet. The
editor now reads the harvest afresh when it opens, and writes the sheet
only if someone opened and changed it there.

**Bank details are not in the repo.** They are typed into **Sales →
Settings**, live in `farm_business`, and only an owner can change them.

**The carrier collects from one place.** Before it delivers anything
the carrier picks the cartons up from the butcher's shop, and that job
is the first row of the manifest. It needs what a driver needs: a
street address, suburb, state and postcode, a time window, someone to
ring. The shop is the same every harvest, so its address is the farm's
(`farm_business.collect_*`, typed once in **Sales → Settings**), not
each harvest's; the phone and email on the row are the farm's own. The
row is the carrier's own collection job of 4 June 2026 put into the
manifest's columns. `harvest.pickup_place` is something else: words for
a customer picking up their own box.

**The database writes an email; a function sends it.** Three emails go
out, all from the mailbox on the letterhead (`farm_business.email`): a
confirmation to the customer and a notice to the farm when an order
arrives from the website, and an invoice when someone presses **Email
invoice…** in Sales. Each is a row in `mail` — who to, the subject, the
words — written in SQL from the order or the invoice as it stands
(migration 76), and that row is the record of what was said. Sending is
the one thing in this system that is neither a page nor the database:
`supabase/functions/send-mail` claims what is queued, hands each to
Gmail, and reports back. It exists because a browser must never hold
the mailbox's password and Postgres cannot talk to a mail server; it
decides nothing. So an order never depends on email — `place_order()`
queues after the order is written, and a failure there is undone alone.
Nothing is sent twice — the claim is a lock. And nothing old is sent by
surprise — a row not sent within a day is marked failed, and a person
may send it again from **Sales → Settings → Email**. The confirmation
says what the website's thank-you page says (`queue_order_mail()` here,
`showConfirmation` in `site/site.js`: change one, change the other).
The invoice goes in the body of the email, not as an attachment.
Website confirmations are a switch the owner turns on
(`farm_business.email_web_orders`) once the test email has arrived. A
second farm with a different address on its letterhead is refused in
its log, not sent as the first.

**A subscriber is not a customer.** A customer has ordered; a
subscriber gave an email address to be told when there is meat to
order. Most of one are not the other, so `subscriber` is its own table,
and a subscriber who has also ordered is found by their email
(`v_subscriber`), not by a link someone has to keep in step. The list
keeps everyone who has left it: `unsubscribed`, and `bounced` (what
Mailchimp calls cleaned). Those two are the more important half — a
list that only remembers who said yes will, the first time it is
re-imported, write to someone who said no. `status_on` is when each
became what they are, and it settles every disagreement:
`import_subscribers()` lets the later change win, and at the same
moment the one that is not *subscribed*. Only *subscribed* addresses
can be copied or downloaded from **Sales → Mailing list**.

**People's details are not in the repo either.** Customers and
subscribers are loaded from the page (**Import…**) or by a converter
whose output is run and thrown away — `import_mailchimp_audience.py`
says so at the top. The seeds carry stock, products and a carrier's
schedule; they do not carry anyone's email address.

---

## 3. Data model

```
animal ──┬─ animal_status       dated life state + class transitions
         ├─ weight_event
         ├─ treatment_animal ── treatment      LPA section 2
         ├─ shearing_animal ─── shearing       shearing, crutching, marking
         ├─ paddock_stay ────── paddock        where, and where it's been
         ├─ consignment_animal─ consignment    NVD, waybill, LPA 5A/5B
         ├─ joining ─────────── calving        outcomes incl. empty
         │      └─ ai_semen                    which straw, for an AI
         ├─ planned_joining ─── joining        a plan, closed by the joining, by trigger
         └─ expected_calving                   derived from joining, by trigger

ai_semen ─┬─ cryo_txn ───────── animal         straw ledger, female as written
embryo  ──┘                                    two tanks, six locations each

spray_event ─┬─ spray_product                  LPA 3B, tank mix = many products
             └─ spray_paddock ── paddock       one pass, many paddocks

feed_source ─┬─ feed_event ──┬─ paddock         LPA 3C / 3D
             │               ├─ feed_event_animal
             │               └─ feed_event_ref   tags as written on paper
             └─ feed_adjustment                  recounts, spoilage

product ── product_option                      what is sold, in what sizes, with its cut sheet
harvest                                        one kill: dates, butcher, yield, costs
customer ── customer_order ─┬─ order_line      what they ordered; actual kg once packed
                            ├─ order_payment   deposit, balance, refund: paid is their sum
                            └─ invoice ── invoice_line   a copy, numbered, kept as sent
delivery_zone                                  postcode -> carrier zone and days
subscriber                                     the mailing list, with everyone who has left it
mail                                           every email asked for: the words, and whether it went
farm_business                                  ABN, bank details: the invoice letterhead; where the carrier collects from

farm                who runs the app on this land: name, address, mark, hostname
 └─ farm_member     who belongs to it, and as what: viewer / manager / owner
property            PIC, under a farm. is_primary (one per farm) drives the page letterheads
farm_user           profile: display name, phone. Role and active live on farm_member
user_pref           per-user field visibility
record_change_log   append-only audit trail
```

`animal.species` is `cattle` or `sheep`. Stock codes are unique **per
farm and species** — `R 97` is a cow and also a ewe, and both are right.
Every table but `heartbeat`, `user_pref` and `farm_user` carries
`farm_id`.

### Key views

| View | For |
|---|---|
| `v_animal_current` | The herd, every column, with age, status, paddock, clearance |
| `v_paddock_current` | Paddocks with live head count and stocking rate |
| `v_treatment_report` | LPA section 2, with which PICs and species were on the run |
| `v_spray_report` | LPA 3B, one row per product with derived graze and cut dates |
| `v_paddock_withhold` | Paddocks stock should not be grazing yet. Empty is normal |
| `v_feed_event` / `v_feed_store` | LPA 3C / 3D, with what's left in the shed |
| `v_feed_cover` | Who a feeding event covers, by paddock or by name |
| `v_feed_load` | Per load: head, intake rate, projected empty date |
| `v_animal_feed` / `v_animal_feed_last` | The run an animal is on, and the one it came off |
| `v_feed_unmapped` | Animals named on the paper feed record but not on file |
| `v_consignment` | LPA 5A / 5B |
| `v_shearing` | Shed work with head count and tags |
| `v_animal_clearance` | Withholding and export interval per animal |
| `v_joining_result` | The joining register — method, sire or straw, result |
| `v_joining_performance` | Conception rate by bull and season |
| `v_planned_joining` | Join plans with the forecast calving or lambing, and whether still open |
| `v_stock_year_animal` | One row per animal per bucket per year — the account's working |
| `v_stock_year` / `v_stock_year_class` | The trading account, counted off the above |
| `v_stock_entry` / `v_stock_exit` | When stock came on and left, sale/death/ration inferred |
| `v_ai_semen` / `v_embryo` | Lots with what's on hand and the shelf label |
| `v_cryo_location` | What is in each tank and canister |
| `v_cryo_unmapped` | Females named on the register but not on file, and why |
| `v_record_history` | Change log in plain language |
| `v_me` | The signed-in login on its farm: role, active, and the farm's name and mark |
| `v_farm_public` | Farm names and marks by hostname, for the login screen. Readable by anon, by design |
| `v_order` | An order with its sums: goods, GST, total, paid, owing, kilos, cartons, who it goes to |
| `v_harvest` | A harvest with what is sold out of it, what is left, and what it cost |
| `v_customer` | Customers with order count, last order, spent and owing |
| `v_invoice` | An invoice with subtotal, shipping, GST, paid, due, and the BAS split |
| `v_delivery_postcode` | One row per postcode: the carrier's zone and the days they run |
| `v_harvest_balance` | What each harvest has to sell, what is sold and what is left, in boxes. Not on `v_harvest`: a later migration cannot add a column to a view an earlier one builds |
| `v_subscriber` | The mailing list, with whether each address has ever ordered |
| `v_mail` | The email log: what went to whom, about which order or invoice, and what did not go and why |

### Deliberately not used

**PostGIS.** Boundaries are GeoJSON in `jsonb`; the only geometry maths
needed is polygon area, which is a dozen lines.

**A frontend framework.** Four files, no build, no `node_modules`.

**UTC.** The session timezone is `Australia/Melbourne` (migration 39),
because `current_date` on UTC is yesterday here until 10am AEST. In the
browser, **never `toISOString()` for a calendar date** — it returns the
UTC day, so anything recorded before 10am was dated a day early on the
LPA record. Build dates from local parts (`today()` in `index.html`,
`localDay()` in `reports.html`, `localToday()` in `map.html`), and do
date arithmetic anchored at UTC midnight with `setUTCDate` so no zone
enters into it at all. `fmt()` already parses `d+"T00:00:00"` as local
and is correct — that was the model to follow.

**A CDN at runtime.** `vendor/supabase.js` must be a real self-contained
bundle, ~210 KB with no `import` statements in it. What esm.sh serves at
`/@supabase/supabase-js@2` is a four-line *stub* whose imports are
absolute paths relative to esm.sh; saved locally they resolve against
our own origin, Pages answers with its 404 HTML, and the module fails on
MIME type. The `try/catch` in each page then falls through to esm.sh, so
the app still works and the vendored copy silently does nothing. That
shipped and ran for months. Check with
`grep -n 'import "' public/vendor/supabase.js` — it must print nothing.
Build instructions are in `public/vendor/readme.md`.

---

## 4. Repository

```
public/                 served as-is by Cloudflare Pages: admin.bulokefarm.com.au
site/                   the public website, served as-is by a second Pages project
  config.js             which Supabase project and farm the shop talks to
hidden/                 pages taken off the website for now (Dog Walking). Not served.
                        To bring one back: move it into site/, add it to NAV in site.js
                        and to _headers, and take its line out of site/_redirects
  vendor/supabase.js    the client, self-hosted, not a CDN (see its readme)
  _headers              cache and security headers, per clean URL
supabase/
  migrations/           schema, applied in filename order
  seed/buloke/          Buloke's data loads, run once, in numeric order
    notes/              flagged rows from each import
  seed/toland/          Toland Merino's, the same way
    notes/
  seed/tools/           the xlsx/csv -> SQL converters; last argument is the farm slug
  functions/send-mail/  hands queued email to the farm's mailbox. The only server-side code
  config.toml           the Supabase CLI, for a local stack (ports 544xx)
  schema.sql            snapshot, written back by the backup workflow
.github/workflows/      keepalive and backup
```

**Migrations define shape; seeds carry data.** Migrations run first on a
rebuild, so anything depending on imported records has to be a seed.

### Migrations

| # | What |
|---|---|
| 01–12 | Core schema, users and RLS, paddocks, feed, change log, consignments, joinings, keepalive |
| 13 | Joining method: AI or bull out. `ai_semen`, per-dam gestation |
| 14 | Livestock trading account by financial year |
| 15 | Exit date on the herd view |
| 16 | Leaving the herd closes the paddock stay |
| 17 | The animals behind each trading-account figure |
| 18 | PIC groundwork: not-null, `is_primary`, PIC through the report views |
| 19 | Sheep: `species`, enum values, `shearing` |
| 20 | Stock codes unique per species |
| 21 | Species into the views the app reads |
| 22 | Trading account splits by species |
| 23 | Species on the reports |
| 24 | Sire identified by tag, not only by name |
| 25–30 | Expected calvings derived from joinings, and the repairs that took |
| 31 | The cryo store: tanks, locations, embryos, ledger |
| 32 | Straw markings split into marker, straw, size, goblet |
| 33 | Resolving the females named on the register |
| 34 | Days on feed on the herd view; store balance from the written amounts |
| 35 | Feeder dry ≠ silo empty. Intake rate, projected empty date, `feed_run_end()` |
| 36 | The two Irwins loads rebuilt; `feed_event_ref` for tags not yet on file |
| 37 | A run they stay on vs a one-off drop (`is_run`) |
| 38 | The run they just came off, kept alongside the one they are on |
| 39 | Melbourne time, not UTC. `farm_today()`, and the due dates it exposed |
| 40–42 | Spraying: LPA 3B, `record_spray()`, many paddocks per pass, grazing withholds on `move_animals` |
| 43 | A calving creates the calf: `record_calving()`, `year_letter()`, tag parts filled from `stock_code` |
| 44 | A lamb seen in a paddock, ewe not known: `record_drop()` |
| 45 | Lambing over for a mob: joining outcome `closed`, `close_expectations()`, closed is untested in the rate views |
| 46 | A sheep's letter is its tag colour (BK W O G P Y R BU): `year_letter(date, species)`, `animal_code_parts` reads one or two letters, today's `X ?` lambs repaired to `O ?` |
| 47 | The heartbeat writes: `beat_at`, `beat()` for the keepalive |
| 48 | Functions not for the API: trigger functions and `refresh_expectation` revoked from anon/authenticated, `my_role` from anon, search_path pinned on ten older functions |
| 49 | Join planning: `planned_joining`, `v_planned_joining` with the forecast, `plan_fulfilled()` closes the plan when the joining is recorded |
| 50 | The ten AI joinings recorded ahead of their date become plans; the joinings go, kept in the change log |
| 51 | The ten undated attempt-2 bull joinings for 2027-2028 removed — a fallback column, not a decision |
| 52 | The `ensure_rls` event trigger written down; it existed only on the live database |
| 53 | The farm: `farm`, `farm_member`, `current_farm()`, `my_role()` re-sourced, `v_me`, `v_farm_public`, `add_member()`, the `farm-logos` bucket |
| 54 | `farm_id` on every table, backfilled to Buloke with the audit triggers off; links checked and farm derived by trigger; uniqueness per farm |
| 55 | Every policy scoped to the session's farm; `farm_user.role` and `active` dropped; the unwritten `ai_semen_write` policy dropped |
| 56 | Where each farm is: `farm.lat`/`lng`, carried by `v_me`, so the paddock editor opens on the signed-in farm |
| 57 | A login on several farms can see them (`v_my_farms`) and switch: the menu lists them, and on the phone the mark at top left opens it |
| 58 | `animal.gestation_days` allows 130 to 310, not the cattle-only 250 to 310 that refused every ewe |
| 59 | Bringing stock on: `receive_stock()`, bought in or bred here, by tag or head count, with the inward consignment for LPA 5A |
| 60 | `add_member()` no longer tells an owner to have someone sign up; logins are created, there is no sign-up screen |
| 61 | `animal.polled` becomes `animal.horn`: P or H as seen, PP, PH or HH as tested. `animal.born_as`: single, twin, triplet, as a stud records it |
| 62 | A tag can have six digits: `BU 230040` is a Toland ewe, colour then her stud number |
| 63 | Back-up plans: `planned_joining.attempt`, one open plan per dam, season and attempt; the joining closes the plan it answers, and in calf drops the back-ups |
| 64 | A season is the July–June financial year the birth is due in: `season_of()`; a joining's season follows its due date and a plan's its forecast, by trigger, and a dam's gestation correction moves her plans' seasons. The April 2026 ewe joining moved from 2025-2026 to 2026-2027 |
| 69 | The butcher: a fourth role. `can_read()` names the roles that read; members and profiles of the farm are for readers |
| 70 | Selling: `product`, `product_option`, `harvest`, `customer`, `customer_order`, `order_line`, `order_payment`, `invoice`, `invoice_line`, `delivery_zone`, `farm_business`; per-farm order and invoice numbers; `save_order()`, `issue_invoice()`; `v_order`, `v_harvest`, `v_customer`, `v_invoice` |
| 71 | What the butcher sees: `butcher_harvests()`, `butcher_sheet()`, and `butcher_pack()` to tick a pack off and weigh it |
| 72 | The shop front, callable with no login: `shop_front()`, `delivery_lookup()`, `place_order()` |
| 73 | The mailing list: `subscriber` with subscribed, unsubscribed and bounced; `import_subscribers()`, where the later change wins and an opt-out is never undone by an older yes; `v_subscriber` |
| 74 | What a product asks on the order form: `product.questions`, `order_line.answers`, `answers_for()`. Choices only. Beef asks about soup bones. `shop_front()`, `place_order()`, `save_order()` and `butcher_sheet()` replaced whole to carry them |
| 75 | A box is a carton: `butcher_sheet()` numbers one box per carton, so a whole lamb is two boxes and a 24 kg beef pack is two 12 kg boxes, each with its sheet |
| 76 | Email: `mail` is the queue and the record. `queue_order_mail()`, `mail_order()`, `mail_invoice()`, `mail_test()` and `mail_retry()` write it; `mail_claim()` and `mail_done()` are the sender's alone; `v_mail`; `farm_business.email_web_orders`. `place_order()` replaced whole to queue an order's two emails |
| 77 | The harvest balance: `harvest.boxes_for_sale`, `v_harvest_balance`. `butcher_sheet()`, `shop_front()` and `place_order()` replaced whole: the summary shows it, the website is told it, and a website order goes on the first open harvest with room. Takes the beef “Remaining” sheet off any lamb harvest that was given one by accident |
| 78 | Where the carrier collects from: `farm_business.collect_name`, `collect_street`, `collect_suburb`, `collect_state`, `collect_postcode`, `collect_window`, `collect_note`. The collection row of the manifest is written from them |

### Seeds

Under `seed/buloke/`. Each starts by naming its farm —
`select set_config('app.farm', …)` — because a script run as
`postgres` has no membership for `current_farm()` to find; without it
every root insert fails with *No farm*. The same line goes at the top
of anything you run by hand in the SQL editor that inserts records.

| # | What |
|---|---|
| 10 | The 31 head from `Cattle Data.xlsx` |
| 20 | Autumn/winter 2026 drenches and grain |
| 30 | 50 historical animals, 29 consignments, back to 2011 |
| 40 | 90 sheep, joinings, drenches, shed work, sales |
| 50 | 50 semen lots, 20 embryo lots, 372 movements back to 2008 |
| 60 | What is sold: beef, lamb and pies with their sizes, prices and the butcher's standard cut sheets; the invoice letterhead, less the bank details; the butcher's shop the carrier collects from |
| 61 | Blackbird Logistics' delivery schedule: 2,322 suburbs with zone and days. Generated by `seed/tools/migrate_blackbird_schedule.py`; re-run both when a new schedule is issued |
| 90 | Joining outcome backfill — must run last |

---

## 5. Making changes

1. Write the SQL into a **new numbered file** in `supabase/migrations/`
2. Commit and push
3. Paste the same SQL into the Supabase **SQL Editor** and run it

The file is the record; running it is execution. If you paste SQL that
isn't in a file, the repo quietly stops being true and a rebuild won't
reproduce the database. Migration 52 is what that looks like: an event
trigger that lived only on the live database, and a rebuild that died
at 48 because of it.

A rebuild can be run locally: `supabase start` (Docker; `config.toml`
enables the database, the API, logins, the function runtime and a mail
catcher) applies every migration to an
empty database, and yesterday's backup artifact restores into a second
database beside it for testing against real data. The farm-scope
migrations were proved that way — see `farm_scope_plan.md` §8. `supabase/schema.sql` is the check — the backup
job rewrites it weekly, so drift surfaces as a commit.

Every migration is written to be **safely re-runnable** — `if not
exists`, `or replace`, `drop policy if exists`. Keep it that way, and
**prove it by actually re-running them**, in order, three times, against
a scratch database with realistic data. A single forward pass hides a
whole class of bug: migrations 34–38 each applied perfectly the first
time and, on the second, variously aborted, deleted a delivery record
that had just been created, and silently took an entire mob off feed.
None of it was visible until the second run.

```bash
# a scratch Postgres is enough; no Supabase needed for the shape
initdb -D /tmp/pg/data -A trust && pg_ctl -D /tmp/pg/data -o "-p 5433" start
for pass in 1 2 3; do
  for f in supabase/migrations/*.sql; do
    psql -p 5433 -d scratch -v ON_ERROR_STOP=1 -f "$f" || echo "FAIL $f pass $pass"
  done
done
```

### Rules learned the hard way

- **Check which definition is current.** Views get redefined and the
  last one wins. `grep -rn "view v_name" supabase/migrations/` before
  touching one, or you will rebuild it from a version that has since
  gained columns and silently drop them.
- **`create or replace view` can only append columns.** Adding one at
  the front, renaming, or reordering needs `drop view if exists` first.
- **Appending to a view breaks every earlier migration that built it.**
  Once migration 38 adds a column to `v_animal_current`, re-running 34
  or 35 tries to replace it with fewer columns and aborts with *cannot
  drop columns from view*. Every migration that appends to a view a
  later one also appends to needs a guard that steps aside:

  ```sql
  do $guard$
  begin
    if not exists (select 1 from information_schema.columns
                    where table_name = 'v_animal_current'
                      and column_name = 'off_feed_on') then
      execute $v$ create or replace view v_animal_current ... $v$;
    end if;
  end $guard$;
  ```

  Guarded so far: `v_animal_current` and `v_animal_feed` (34),
  `v_feed_load` and `v_animal_current` (35). The nested `$guard$` /
  `$v$` quoting is required — plain `$$` collides with the body.
- **A backfill is a one-time statement with a permanent trigger.** A
  repair `update` at the end of a migration re-fires on every later run,
  against data a subsequent migration has since changed its mind about.
  Migration 34 closed feeding runs when the store emptied; 35 overturned
  that rule, but 34's backfill kept enforcing it on every re-run, zeroing
  days-on-feed for the whole mob. Guard backfills on whether the later
  migration exists, not just on whether the rows look untouched.
- **Key an idempotent update on something stable.** "Update any row that
  isn't already correct" matches the row a previous run of the same
  migration just inserted. Migration 36 keyed the June feed source that
  way and, on the second run, rewrote the March delivery into a duplicate
  June one. Key on the relationship — the event that points at it —
  rather than on the values being set.
- **An insert matching zero rows is not an error.** `insert ... select
  ... from animal where stock_code = any(array[...])` silently writes
  nothing if none of the tags exist. That is how 3.95 tonne of grain
  never reached Section 3C: seed 20 referenced animals that seed 30
  creates. Order seeds so references exist first, or check the row count.
- **Drop dependent views before touching a column they read**, and
  recreate them explicitly. `cascade` drops them silently and leaves
  them gone. Current chains: `v_animal_current` ← `v_animal_clearance`;
  `v_cryo_location` ← `v_ai_semen`, `v_embryo`; `v_stock_year` and
  `v_stock_year_class` ← `v_stock_year_animal` ← `v_stock_entry`,
  `v_stock_exit`; `v_harvest` and `v_customer` ← `v_order`;
  `v_subscriber` ← `v_customer`. The sales views are built with
  `create or replace` and never dropped for exactly this reason: 70
  dropped `v_customer` on every run, and stopped being re-runnable the
  day 73 built a view on it.
- **Adding an argument to a function creates a second function.**
  `create or replace` only replaces a matching argument list, so the old
  form survives and a call with the original arity then matches both —
  Postgres refuses it as ambiguous rather than choosing. `drop function`
  with the full old signature first. Migration 40 does this to
  `move_animals`.
- **`alter type ... add value` cannot be used in the transaction that
  added it.** The migration adding an enum value and the load using it
  are two separate runs. The SQL editor runs a paste as one
  transaction, so a view in the same file that names the new value as
  a literal fails too — migration 45 compares `outcome::text` for that
  reason. A plpgsql body may name it; that is not checked until it runs.
- **`on conflict` cannot infer a partial unique index** unless the
  statement repeats the predicate. Usually the predicate was
  unnecessary — nulls are already distinct.
- **`lpad` truncates.** `lpad('122', 2, '0')` is `'12'`.
- **Untyped literals in a `union` resolve against each other** before
  the insert target is considered. Cast enum values on every branch.
- **A repair that deletes rows must write the replacements** in the same
  migration. A trigger only fires on a write, so deleting and expecting
  it to rebuild leaves nothing behind.
- **Match on more than a name.** One bull can hold three blocks in a
  register and one cow two joinings in a season; taking the first match
  loses the others.
- **Single-letter globals get shadowed.** `viewDetail` destructured its
  queries as `const [w, t, c, sh] = await Promise.all(...)`, shadowing
  the module-level vocabulary helper `w(key, species)` for the whole
  function. Every female's detail page threw *w is not a function*, and
  because it was an `async` view called from `render`, it surfaced as an
  unhandled rejection with a blank screen rather than an obvious error.
  `node --check` will not catch this; shadowing is legal JavaScript.

### Deploying

`git push` to `main`. Cloudflare Pages rebuilds in under a minute. There
is no build step — it serves `public/` as-is.

Pages settings: framework preset **None**, build command **empty**,
output directory **public**.

The public website is a second Pages project on the same repository,
identical but for output directory **site** and the domain
`www.bulokefarm.com.au`. It has its own `_headers` and a `_redirects`
that only forwards the old Squarespace addresses. To look at either
locally as Pages would serve it: `python .claude/serve.py public 8788`
or `python .claude/serve.py site 8789`. On localhost only, a JSON
`{url, key}` in localStorage under `bf.api` points a page at a local
Supabase stack instead of production.

The sender is not a page and is deployed on its own, only when it
changes: `supabase functions deploy send-mail --project-ref <ref>`. Its
two secrets are set in the dashboard, **Edge Functions → Secrets**:
`GMAIL_USER` and `GMAIL_APP_PASSWORD`. To try it locally, `supabase
functions serve --env-file <file>` with
`SMTP_HOST=supabase_inbucket_bulokefarm`, `SMTP_PORT=1025`,
`SMTP_TLS=false` and `GMAIL_USER` the farm's address: mail then lands
in the stack's own catcher, `http://127.0.0.1:54424`, and goes nowhere
else.

**`_headers` must name the clean URLs.** Pages serves `/` and `/reports`,
not `/index.html`, so a `/*.html` rule matches the filename nobody
requests and applies to nothing — `X-Frame-Options` was missing from
every page for months without a symptom. Add a block per page path.
Verify with `curl -sI https://admin.bulokefarm.com.au/`, which is also
the quickest confirmation a deploy has actually landed.

**Never add `_redirects`** rewriting `/foo` to `/foo.html`. Pages already
serves clean URLs and the rule causes a redirect loop.

---

## 6. Operations

### Infrastructure

| Thing | Where |
|---|---|
| Domain | VentraIP (`ns1-3.nameserver.net.au`), one CNAME: `admin` → `bulokefarm.pages.dev` |
| Main website | `site/`, a second Cloudflare Pages project, once `www` is pointed at it. Until then Squarespace is still what the public sees |
| Carrier | Blackbird Logistics, booked through their Detrack account: the manifest is downloaded from **Sales → Delivery** and imported under Jobs. Its first row is the collection from the butcher's shop (**Sales → Settings**) |
| Email | The farm's own Gmail mailbox, reached at `smtp.gmail.com:465` with an app password. What was sent is in that mailbox's Sent folder; the log is **Sales → Settings → Email**. Not 587: Supabase closes 25 and 587 to functions |
| Hosting | Cloudflare Pages, project `bulokefarm` |
| Database | Supabase project `production`, region **Oceania (Sydney)** |
| Repo | `github.com/bulokefarm/bulokefarm` |

Sydney, not Singapore: the Vocus path from Trafalgar to `ap-southeast-1`
was dropping packets past Perth.

### Keys

The anon key is in the HTML and that is correct — it is designed to be
public, and row level security protects the data. Every table denies by
default, then grants read to active farm users, write to managers and
owners, delete to owners.

The **service_role** key bypasses RLS entirely. Never in this repo,
never in the HTML.

The **mailbox's app password** is a secret on the `send-mail` function
(`GMAIL_APP_PASSWORD`, beside `GMAIL_USER`). It opens the whole
mailbox, not only sending. Never in this repo, never in the HTML, never
in a table. If it leaks, or the function is retired, delete it at
myaccount.google.com/apppasswords: that ends it at once, and a new one
goes in the same secret.

The Supabase client is self-hosted at `public/vendor/supabase.js`, with
esm.sh only as a fallback. Refresh it with:

```
curl -L "https://esm.sh/@supabase/supabase-js@2.111.0?bundle&target=es2020" \
  -o public/vendor/supabase.js
```

`?bundle` matters. Without it the file is a stub re-importing paths that
404 on our origin, the fallback quietly takes over, and every cold start
goes back to fetching from a CDN.

### GitHub secrets

| Secret | Notes |
|---|---|
| `SUPABASE_ANON_KEY` | Use the copy button — truncated pastes cause 401s |
| `SUPABASE_DB_URL` | **Session pooler**, port **5432** |

The database URL must be the session pooler
(`aws-0-ap-southeast-2.pooler.supabase.com`), username
`postgres.hgnzignikbpdbbyubahu`. The direct connection is IPv6-only and
unreachable from GitHub runners. Port 6543 is transaction mode and won't
work with `pg_dump`. Special characters in the password need URL
encoding — `/` becomes `%2F`.

### Backups

`Weekly backup` produces a dump as a GitHub artifact. **They expire
after 90 days** — a rolling window, not an archive. Download one every
few months and keep it somewhere you own.

The same job writes `supabase/schema.sql` back to the repo whenever the
live schema differs from the last snapshot, so unrecorded SQL-editor
changes turn up as a Monday-morning commit.

### Keepalive

A free Supabase project pauses after a week of "insufficient activity",
which Supabase reads as a few database requests every day. One weekday
read was not enough — the pause warning arrived in September 2026 with
the job green. `Keep database awake` now runs three times a day, every
day: five reads of `heartbeat` and one call to `beat()` (migration 47),
which writes a timestamp. If the warning comes again, opening the
project in the Supabase dashboard counts as activity while you decide
whether to go to the paid plan, which cannot be paused.

If a request returns 404 shortly after creating a table, PostgREST's
schema cache is stale: `notify pgrst, 'reload schema';`

### Security advisor

Supabase → Advisors → Security. Three warnings are expected and stay:

- `beat()` callable by anon — the keepalive's write (migration 47).
- `my_role()` callable by signed-in users — every policy needs it.
- Leaked password protection disabled — a Pro-plan toggle.
- `shop_front()`, `delivery_lookup()` and `place_order()` callable by
  anon — the public website (migration 72).
- `butcher_harvests()`, `butcher_sheet()` and `butcher_pack()` callable
  by signed-in users — the butcher's only way in (migration 71). Each
  checks the caller's role itself.

Anything else is new. User sign-ups are off in Authentication → Sign In /
Providers; users are added by hand, below.

### Adding a user

1. Supabase → Authentication → Users → Add user, auto-confirm
2. ```sql
   update farm_user
      set display_name = 'Name', phone = '04xx xxx xxx',
          role = 'manager', active = true
    where id = (select id from auth.users where email = 'them@example.com');
   ```

Roles: `viewer` reads, `manager` records, `owner` also deletes, and
`butcher` sees the cut sheets at `/butcher` and nothing else. New
accounts land inactive and see nothing until switched on. `display_name`
and `phone` fill the LPA "treated by" field automatically.

**Don't disable the email provider** to stop signups — that turns off
sign-in too. The setting you want is "Allow new users to sign up".

---

## 7. Still to do

**Rupari's herd.** The second PIC exists in the schema but the animals
aren't in. Until they are, 212 straw and embryo movements name a cow the
database doesn't hold — `select * from v_cryo_unmapped` — and six lines
of the Irwins feed record name stock that isn't on file:
**V 06, V 10, V 11, V 17, W 05** — `select * from v_feed_unmapped`.
Afterwards, re-run the update in migration 33 and
`select feed_resolve_refs();`. Both numbers should drop hard.

Head counts on `v_feed_load` already include the unresolved tags, so the
projected empty dates are right today — the paper says six head ate the
June load and six is what the tonnage divides by. Counting only animals
on file read 148 days instead of 74.

**The valuation side of the trading account.** Head counts are done and
reconcile. Values need a purchase price on `animal`, a per-year
per-class valuation election, and a natural-increase figure. The
election is the accountant's call, and there are now two species of it.

**Rations are inferred**, not recorded: slaughtered with no consignment
to a saleyard, abattoir or agent. Near-deterministic given how
`consign_animals` works, but a fourth life state would settle it.

**LPA gaps.** Five cattle drenches have no operator name. The 2021
vaccination and 2022 drench have dates only. Both sheep drenches have no
product or batch. All fixable by clicking the row in `/reports`.

**Two possible duplicate sires** — is `Davelle Cool Beau` the same
animal as `Davelle Cool Beau N51`? `Quicksilver` and
`Bre. Quicksilver (P)`? Their progeny stay split across two lines until
this is settled.

**Seed data that would come back on a rebuild.** `10_herd.sql` still
contains eight joinings with `due_on = 1900-10-11` and no service date.
Migration 27 clears them and constrains against a repeat, but the seed
carries them.

**Seed order.** `30_historical.sql` creates V 23 and V 25, but
`20_treatments_2026.sql` attaches the 17 March grain feeding to them and
runs first, so it matched nothing and the load vanished. Migration 36
rebuilds it, but a clean rebuild would lose it again. Renumber the
historical seed ahead of the treatments, or make the treatment inserts
report a zero row count instead of passing silently.

**Due dates that may be a day early.** The browser computed `due_on` by
mixing a UTC anchor with local day arithmetic, so a joining and a due
date on opposite sides of a daylight-saving change land a day short —
the ordinary June-joined, March-due pattern. Fixed going forward in
migration 39; the stored values are listed by
`select * from v_due_date_check`. A `drift` of exactly 1 is the bug,
anything else was a deliberate adjustment, so they are not rewritten
automatically. The one-line accept is in the migration's comments.

**Selling, the parts not built.** Email carries no attachment: an
invoice goes in the body, and a PDF is still Print → Save as PDF.
Nothing is emailed when an order is packed, delivered or paid. The
queue is sent when a page wakes the sender (the website after an
order, Sales when someone presses Send or opens the page); there is no
timer behind it. Deliveries are booked by downloading the manifest and
importing it into Detrack; the Detrack number and tracking link are
pasted back. That wants a second function, holding a Detrack API key,
and has none yet. There is no card payment. A harvest is
not yet linked to the animals that went on it (`consignment`), and
whether pies carry GST is the accountant's call: they are set GST-free.
Campaigns are still written and sent in Mailchimp. The mailing list
here is a copy taken on 15 November 2026: export the audience again and
import it under **Sales → Mailing list** before relying on it, and add
anyone who unsubscribes by replying. The new website has no sign-up
form yet.

**Smaller things.** The masthead head count ignores the species scope.
`n/B/R` (`marking_code`) meaning still unknown. `TOL 20-P1065`'s EID is
the placeholder `3SBES046ASR06xxx`.

Flagged rows from every import are in `supabase/seed/<farm>/notes/`.
