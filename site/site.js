/* Buloke Farm — the public site’s one script. No build step, no libraries.
 *
 * Every page loads config.js then this. It does four things:
 *
 *   1. Paints the header and footer, so there is one copy of each.
 *   2. Keeps the order (the "cart") in localStorage under bf.cart as
 *      [{option_id, qty}] — ids and quantities only. Names and prices are
 *      always read fresh from the shop, and the server ignores any price
 *      a browser sends anyway.
 *   3. Talks to the shop: three functions, and nothing else on the network.
 *        shop_front       what is for sale and when the next harvest is
 *        delivery_lookup  whether the carrier goes to a postcode, and when
 *        place_order      writes the order, returns its reference
 *   4. Renders whichever page it is on: the shop home (body data-page="home"),
 *      a product (body data-product="beef"), or the order form
 *      (body data-page="order"). Every other page is plain HTML.
 *
 * Two rules that are easy to break:
 *   - Everything from the API goes through esc() before it reaches innerHTML.
 *   - A YYYY-MM-DD from the API is a calendar date, not an instant. It is
 *     parsed as local midnight and never passed through toISOString(), which
 *     would move it a day for anyone east of Greenwich.
 */
(function () {
  "use strict";

  const SHOP = window.SHOP || {};
  const EMAIL = "bulokefarm@gmail.com";
  const UNREACHABLE = "Couldn’t reach us — please email " + EMAIL;
  const BUTCHER = "Cherry Tree Organics, Shop 1, 22-24 Old Princes Highway, Beaconsfield";
  const MAX_QTY = 20;
  const MAX_LINES = 20;

  /* ---------------------------------------------------------- helpers */

  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  function esc(v) {
    return String(v == null ? "" : v).replace(/[&<>"']/g, (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
  }

  // 32400 -> "$324", 1550 -> "$15.50", 124800 -> "$1,248"
  function money(cents) {
    const c = Math.max(0, Math.round(Number(cents) || 0));
    const dollars = String(Math.floor(c / 100)).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    const rest = c % 100;
    return "$" + dollars + (rest ? "." + (rest < 10 ? "0" : "") + rest : "");
  }

  const kg = (n) => (Math.round(Number(n) * 10) / 10) + " kg";

  const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const MONS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August",
                  "September", "October", "November", "December"];

  function toDate(d) {
    if (!/^\d{4}-\d{2}-\d{2}/.test(d || "")) return null;
    const t = new Date(String(d).slice(0, 10) + "T00:00:00");
    return isNaN(t.getTime()) ? null : t;
  }
  // "Fri 18 Dec 2026"
  function fmtDate(d) {
    const t = toDate(d);
    return t ? DAYS[t.getDay()] + " " + t.getDate() + " " + MONS[t.getMonth()] + " " + t.getFullYear() : "";
  }
  // "December 2026"
  function fmtMonth(d) {
    const t = toDate(d);
    return t ? MONTHS[t.getMonth()] + " " + t.getFullYear() : "";
  }

  // ["Tue","Fri"] -> "Tue and Fri"; three or more get commas
  function listAnd(a) {
    if (a.length < 2) return a.join("");
    return a.slice(0, -1).join(", ") + " and " + a[a.length - 1];
  }

  const clampQty = (q) => Math.min(MAX_QTY, Math.max(1, parseInt(q, 10) || 1));

  const mailto = (addr) => '<a href="mailto:' + esc(addr) + '">' + esc(addr) + "</a>";

  function unavailableHtml() {
    return '<div class="unavailable"><strong>Ordering is unavailable right now.</strong>' +
      "Please try again shortly, or email " + mailto(EMAIL) + " and we’ll look after you.</div>";
  }

  /* ---------------------------------------------------------- the shop */

  // POST one of the shop’s functions. Resolves with the JSON; rejects with
  // an Error whose message can be shown to a customer as it stands: the
  // server’s own words for a 400, ours for anything else.
  function rpc(fn, body) {
    const ctl = typeof AbortController === "function" ? new AbortController() : null;
    const timer = setTimeout(() => { if (ctl) ctl.abort(); }, 15000);
    return fetch(SHOP.url + "/rest/v1/rpc/" + fn, {
      method: "POST",
      headers: {
        "apikey": SHOP.key,
        "Authorization": "Bearer " + SHOP.key,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(body),
      signal: ctl ? ctl.signal : undefined
    })
      .then((res) => res.text().then((txt) => ({ res: res, txt: txt })))
      .then((r) => {
        clearTimeout(timer);
        let data = null;
        try { data = r.txt ? JSON.parse(r.txt) : null; } catch (e) { data = undefined; }
        if (r.res.ok && data !== undefined) return data;
        const said = r.res.status === 400 && data && typeof data.message === "string" && data.message;
        throw new Error(said || UNREACHABLE);
      }, () => {
        clearTimeout(timer);
        throw new Error(UNREACHABLE);
      });
  }

  // One shop_front call per page view, shared by whoever asks.
  let shopPromise = null;
  function loadShop() {
    if (!shopPromise) {
      shopPromise = rpc("shop_front", { p_farm: SHOP.farm }).then((d) => {
        if (!d || !Array.isArray(d.products)) throw new Error(UNREACHABLE);
        d.harvests = Array.isArray(d.harvests) ? d.harvests : [];
        d.farm = d.farm || {};
        d.products.forEach((p) => { p.options = Array.isArray(p.options) ? p.options : []; });
        return d;
      });
    }
    return shopPromise;
  }

  // option id -> { p: its product, o: the option }
  function optionIndex(shop) {
    const m = {};
    shop.products.forEach((p) => p.options.forEach((o) => { m[o.id] = { p: p, o: o }; }));
    return m;
  }

  // Meat packs are priced by packed weight, so the figure is an estimate.
  const isEstimate = (p) => !!p.from_harvest;
  const priceText = (p, cents) => (isEstimate(p) ? "about " : "") + money(cents);

  // "Small · 12 kg" — or, for something not sold by weight, its label.
  function optionName(o) {
    const bits = [o.label || o.name];
    if (o.size_kg != null) bits.push(kg(o.size_kg));
    return bits.join(" · ");
  }
  // "Small · 12 kg · about $324"; `full` spells out a weightless option’s whole name.
  function optionLine(p, o, full) {
    const name = o.size_kg == null && full ? o.name : optionName(o);
    return name + " · " + priceText(p, o.price_cents);
  }

  // "from about $324", or just the price when every size costs the same.
  function fromPrice(p) {
    const prices = p.options.map((o) => o.price_cents);
    if (!prices.length) return "";
    const lo = Math.min.apply(null, prices), hi = Math.max.apply(null, prices);
    return (lo === hi ? "" : "from ") + priceText(p, lo);
  }

  // Only these have a page of their own; anything new in the shop goes to the order form.
  const PRODUCT_PAGES = { beef: 1, lamb: 1, pies: 1 };
  const productHref = (p) => (PRODUCT_PAGES[p.slug] ? "/" + p.slug : "/order");

  /* ---------------------------------------------------------- harvest dates */

  function harvestItem(h) {
    const month = fmtMonth(h.pickup_on || h.harvest_on);
    if (h.status === "planned") {
      return '<li class="harvest"><span class="tag">Planned</span><p>' +
        esc(month ? month + ", dates to be confirmed" : "Dates to be confirmed") + "</p></li>";
    }
    if (h.status === "closed") {
      return '<li class="harvest"><span class="tag tag-closed">Fully booked</span>' +
        (month ? "<p>" + esc(month) + "</p>" : "") + "</li>";
    }

    const rows = [];
    if (h.pickup_on) rows.push(["Local pick-up", fmtDate(h.pickup_on), ""]);
    if (h.delivery_on) rows.push(["Delivery", fmtDate(h.delivery_on), ""]);
    if (h.interstate_on || h.interstate_note) {
      rows.push(["Interstate deliveries", fmtDate(h.interstate_on), h.interstate_note || ""]);
    }
    let html = '<li class="harvest"><span class="tag tag-open">Taking orders now</span>';
    if (rows.length) {
      html += '<dl class="dates">' + rows.map((r) =>
        "<dt>" + esc(r[0]) + "</dt><dd>" + esc(r[1]) +
        (r[2] ? " <small>" + esc(r[1] ? "(" + r[2] + ")" : r[2]) + "</small>" : "") + "</dd>").join("") + "</dl>";
    } else {
      html += "<p>Dates to be confirmed.</p>";
    }
    if (h.pickup_place) {
      html += '<p class="fine">Pick-up from ' + esc(h.pickup_place) +
        (h.pickup_hours ? " (" + esc(h.pickup_hours) + ")" : "") + "</p>";
    }
    if (typeof h.left_kg === "number" && h.left_kg < 60) {
      html += '<p class="fine">About ' + Math.max(0, Math.round(h.left_kg)) + " kg left</p>";
    }
    return html + "</li>";
  }

  function harvestBlock(shop, kind) {
    const mine = shop.harvests.filter((h) => h.kind === kind);
    if (!mine.length) {
      return '<p class="muted">Next harvest dates to be confirmed — order now and we’ll be in touch.</p>';
    }
    return '<ul class="harvest-list">' + mine.map(harvestItem).join("") + "</ul>";
  }

  /* ---------------------------------------------------------- the order, kept in the browser */

  const CART_KEY = "bf.cart";
  let memCart = null;          // stands in when localStorage is unavailable
  let onCartChange = null;     // the order page listens

  function readCart() {
    let raw = memCart;
    if (!raw) {
      try { raw = JSON.parse(localStorage.getItem(CART_KEY) || "[]"); } catch (e) { raw = []; }
    }
    const out = [];
    if (!Array.isArray(raw)) return out;
    raw.forEach((it) => {
      if (!it || typeof it.option_id !== "string" || !it.option_id) return;
      const same = out.find((x) => x.option_id === it.option_id);
      if (same) same.qty = clampQty(same.qty + clampQty(it.qty));
      else if (out.length < MAX_LINES) out.push({ option_id: it.option_id, qty: clampQty(it.qty) });
    });
    return out;
  }

  function writeCart(items) {
    try {
      localStorage.setItem(CART_KEY, JSON.stringify(items));
      memCart = null;
    } catch (e) {
      memCart = items;
    }
    paintCartCount();
  }

  function addToCart(optionId, qty) {
    const cart = readCart();
    const same = cart.find((x) => x.option_id === optionId);
    if (same) same.qty = clampQty(same.qty + qty);
    else if (cart.length < MAX_LINES) cart.push({ option_id: optionId, qty: clampQty(qty) });
    writeCart(cart);
  }

  function paintCartCount() {
    const n = readCart().reduce((sum, it) => sum + it.qty, 0);
    $$(".cart-count").forEach((el) => {
      el.hidden = n === 0;
      el.textContent = String(n);
      const link = el.closest("a");
      if (!link) return;
      if (n) link.setAttribute("aria-label", "Order Now, " + n + " in your order");
      else link.removeAttribute("aria-label");
    });
  }

  window.addEventListener("storage", (ev) => {
    if (ev.key !== CART_KEY && ev.key !== null) return;
    paintCartCount();
    if (onCartChange) onCartChange();
  });

  /* ---------------------------------------------------------- header and footer */

  const NAV = [
    ["/buloke-farm", "Buloke Farm"],
    ["/aboutus", "About Us"],
    ["/why-buloke-meat", "Why Buloke Meat"],
    ["/our-difference", "Our Difference"],
    ["/how-to-cook-it", "How To Cook It"],
    ["/recipes", "Recipes"],
    ["/dog-walking", "Dog Walking"]
  ];
  const NAV_PARENT = { "/beef-recipes": "/recipes", "/lamb-recipes": "/recipes" };

  // "/aboutus.html", "/aboutus/" and "/aboutus" are the same page.
  function herePath() {
    let p = location.pathname.replace(/\/index(\.html)?$/, "/").replace(/\.html$/, "");
    if (p.length > 1) p = p.replace(/\/+$/, "");
    return p || "/";
  }

  function navLinks() {
    const here = herePath();
    return NAV.map((n) => {
      const cur = n[0] === here ? ' aria-current="page"' : (NAV_PARENT[here] === n[0] ? ' class="is-here"' : "");
      return '<li><a href="' + n[0] + '"' + cur + ">" + n[1] + "</a></li>";
    }).join("");
  }

  function paintChrome() {
    const header = $("#site-header");
    if (header) {
      header.innerHTML =
        '<div class="wrap header-inner">' +
          '<a class="brand" href="/" aria-label="Buloke Farm — beef and lamb orders">' +
            '<img src="/img/logo.jpg" alt="" width="591" height="510">' +
            '<span class="brand-name" aria-hidden="true">Buloke Farm</span>' +
          "</a>" +
          '<nav class="site-nav" id="site-nav" aria-label="Main"><ul>' + navLinks() + "</ul></nav>" +
          '<a class="btn btn-order" href="/order">Order Now <span class="cart-count" hidden></span></a>' +
          '<button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-nav" aria-label="Menu">' +
            '<svg class="bars" width="22" height="22" viewBox="0 0 22 22" aria-hidden="true"><path d="M3 6h16M3 11h16M3 16h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>' +
            '<svg class="x" width="22" height="22" viewBox="0 0 22 22" aria-hidden="true"><path d="M5 5l12 12M17 5L5 17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>' +
          "</button>" +
        "</div>";
      header.insertAdjacentHTML("beforebegin", '<a class="skip-link" href="#main">Skip to content</a>');

      const nav = $("#site-nav"), toggle = $(".nav-toggle", header);
      const setOpen = (open) => {
        nav.classList.toggle("is-open", open);
        toggle.setAttribute("aria-expanded", open ? "true" : "false");
      };
      toggle.addEventListener("click", () => setOpen(toggle.getAttribute("aria-expanded") !== "true"));
      nav.addEventListener("click", (ev) => { if (ev.target.closest("a")) setOpen(false); });
      document.addEventListener("keydown", (ev) => {
        if (ev.key === "Escape" && toggle.getAttribute("aria-expanded") === "true") { setOpen(false); toggle.focus(); }
      });
    }

    const footer = $("#site-footer");
    if (footer) {
      footer.innerHTML =
        '<div class="wrap footer-inner">' +
          '<div><img class="footer-logo" src="/img/logo.jpg" alt="Buloke Farm" width="591" height="510" loading="lazy"></div>' +
          "<div><h2>Buloke Farm</h2>" +
            "<address><p>267 North Canal Rd<br>Trafalgar VIC 3824</p>" +
            "<p>" + mailto(EMAIL) + "</p></address>" +
            "<p>ABN 21 620 822 033</p></div>" +
          '<div><h2>Explore</h2><ul><li><a href="/">Beef &amp; Lamb Orders</a></li>' +
            NAV.map((n) => '<li><a href="' + n[0] + '">' + n[1] + "</a></li>").join("") + "</ul></div>" +
          "<div><h2>Follow</h2><ul>" +
            '<li><a href="https://www.instagram.com/bulokefarm/" rel="noopener">Instagram</a></li>' +
            '<li><a href="https://www.facebook.com/bulokefarm" rel="noopener">Facebook</a></li>' +
          "</ul></div>" +
        "</div>";
    }
    paintCartCount();
  }

  /* ---------------------------------------------------------- shop home */

  function tileHtml(p) {
    const extra = p.deposit_cents > 0 ? money(p.deposit_cents) + " deposit per pack"
      : (p.local_only ? "Pick-up / local only" : "");
    return '<a class="tile" href="' + esc(productHref(p)) + '">' +
      '<div class="tile-photo">' + (p.image_url
        ? '<img src="' + esc(p.image_url) + '" alt="" loading="lazy" width="800" height="600">' : "") + "</div>" +
      '<div class="tile-body">' +
        "<h3>" + esc(p.name) + "</h3>" +
        (p.summary ? '<span class="tile-summary">' + esc(p.summary) + "</span>" : "") +
        '<span class="tile-price">' + esc(fromPrice(p)) + (extra ? "<small>" + esc(extra) + "</small>" : "") + "</span>" +
        '<span class="tile-cta">' + (p.options.length > 1 ? "Choose yours" : "Order") + " &rarr;</span>" +
      "</div></a>";
  }

  function initHome() {
    const tiles = $("#shop-products"), dates = $("#shop-harvests");
    loadShop().then((shop) => {
      const selling = shop.products.filter((p) => p.options.length);
      if (tiles) tiles.innerHTML = selling.length ? selling.map(tileHtml).join("") : unavailableHtml();
      if (dates) {
        const cut = selling.filter((p) => p.from_harvest);
        dates.innerHTML = cut.length ? cut.map((p) =>
          '<div class="card"><h3>' + esc(p.name) + " packs</h3>" + harvestBlock(shop, p.kind) + "</div>").join("")
          : '<p class="muted">Next harvest dates to be confirmed — order now and we’ll be in touch.</p>';
      }
    }).catch(() => {
      if (tiles) tiles.innerHTML = unavailableHtml();
      if (dates) dates.innerHTML = '<p class="muted">Harvest dates aren’t available right now. Email ' +
        mailto(EMAIL) + " and we’ll let you know.</p>";
    });
  }

  /* ---------------------------------------------------------- product page */

  // The shop’s description is plain text: a blank line starts a paragraph,
  // a single newline is a line break, and a short line in capitals
  // ("WHOLE LAMB") is a sub-heading.
  function descriptionHtml(text) {
    const isHeading = (line) => line.length >= 3 && line.length <= 48 &&
      /[A-Z]{2}/.test(line) && !/[a-z]/.test(line);
    let html = "";
    String(text || "").replace(/\r\n?/g, "\n").split(/\n\s*\n/).forEach((block) => {
      let para = [];
      const flush = () => { if (para.length) { html += "<p>" + para.join("<br>") + "</p>"; para = []; } };
      block.split("\n").forEach((raw) => {
        const line = raw.trim();
        if (!line) return;
        if (isHeading(line)) { flush(); html += "<h3>" + esc(line) + "</h3>"; }
        else para.push(esc(line));
      });
      flush();
    });
    return html;
  }

  // Thumbnails are plain links to the photo, so they work with no script;
  // with it, a click swaps the big picture instead.
  function initGallery() {
    const g = $("[data-gallery]");
    if (!g) return;
    const main = $(".gallery-stage img", g);
    g.addEventListener("click", (ev) => {
      const a = ev.target.closest(".gallery-thumbs a");
      if (!a || !main) return;
      ev.preventDefault();
      const img = $("img", a);
      main.src = a.getAttribute("href");
      if (img) {
        main.alt = img.alt;
        main.setAttribute("width", img.getAttribute("width"));
        main.setAttribute("height", img.getAttribute("height"));
      }
      $$(".gallery-thumbs a", g).forEach((t) => t.removeAttribute("aria-current"));
      a.setAttribute("aria-current", "true");
    });
  }

  function qtyHtml(id, value, label, attrs) {
    return '<div class="qty">' +
      '<button type="button" data-step="-1" aria-label="One fewer"' + (value <= 1 ? " disabled" : "") + ">&minus;</button>" +
      '<input type="number" inputmode="numeric" min="1" max="' + MAX_QTY + '" step="1" value="' + value + '"' +
        (id ? ' id="' + id + '"' : "") + ' aria-label="' + esc(label) + '"' + (attrs || "") + ">" +
      '<button type="button" data-step="1" aria-label="One more"' + (value >= MAX_QTY ? " disabled" : "") + ">+</button>" +
      "</div>";
  }

  function initProduct(slug) {
    initGallery();
    const buy = $("#product-buy"), sum = $("#product-summary"),
          desc = $("#product-desc"), harvest = $("#product-harvest");
    if (!buy) return;

    loadShop().then((shop) => {
      const p = shop.products.find((x) => x.slug === slug);
      if (!p || !p.options.length) {
        buy.innerHTML = '<div class="unavailable"><strong>Not available at the moment.</strong>' +
          'See <a href="/">what we’re taking orders for</a>, or email ' + mailto(EMAIL) + ".</div>";
        return;
      }
      const weighed = p.options.some((o) => o.size_kg != null);

      const title = $("#product-name");
      if (title && p.name) title.textContent = p.name;
      if (sum && p.summary) sum.textContent = p.summary;
      if (desc) desc.innerHTML = descriptionHtml(p.description);

      buy.innerHTML =
        '<form class="buy" id="buy-form">' +
          "<fieldset><legend>" + (weighed ? "Size" : "Choose") + '</legend><div class="choices">' +
            p.options.map((o, i) =>
              '<label class="choice"><input type="radio" name="option" value="' + esc(o.id) + '"' + (i === 0 ? " checked" : "") + ">" +
              '<span class="choice-text"><span class="choice-title">' + esc(optionName(o)) + "</span>" +
              (o.size_kg == null && o.label && o.name !== o.label ? '<span class="choice-sub">' + esc(o.name) + "</span>" : "") +
              '</span><span class="choice-price">' + esc(priceText(p, o.price_cents)) + "</span></label>").join("") +
          "</div></fieldset>" +
          '<div class="buy-row">' +
            '<div><label class="label" for="buy-qty">Quantity</label>' + qtyHtml("buy-qty", 1, "Quantity") + "</div>" +
            '<button class="btn" type="submit">Add to order</button>' +
          "</div>" +
          '<p class="buy-status" role="status"></p>' +
        "</form>" +
        '<div class="note">' +
          (isEstimate(p) ? "<p><strong>Prices are estimates.</strong> The final price is by packed retail weight.</p>" : "") +
          (p.deposit_cents > 0
            ? "<p><strong>" + money(p.deposit_cents) + " deposit per pack</strong> secures your order. No payment now — " +
              "we’ll email an invoice for the deposit with payment details, and the balance is invoiced once your order is packed.</p>"
            : "<p><strong>No deposit, and no payment now.</strong> We’ll email an invoice with payment details.</p>") +
          (p.local_only ? "<p><strong>Pick-up / local only.</strong> Further away? Email " + mailto(EMAIL) + " and we’ll see what we can arrange.</p>" : "") +
        "</div>";

      if (harvest && p.from_harvest) {
        harvest.innerHTML = "<h2>Next harvest</h2>" + harvestBlock(shop, p.kind);
        harvest.hidden = false;
      }

      const form = $("#buy-form"), qty = $("#buy-qty"), status = $(".buy-status", form);
      const paintQty = (n) => {
        qty.value = n;
        $('[data-step="-1"]', form).disabled = n <= 1;
        $('[data-step="1"]', form).disabled = n >= MAX_QTY;
      };
      form.addEventListener("click", (ev) => {
        const b = ev.target.closest("[data-step]");
        if (b) paintQty(clampQty(clampQty(qty.value) + Number(b.dataset.step)));
      });
      qty.addEventListener("change", () => paintQty(clampQty(qty.value)));
      form.addEventListener("submit", (ev) => {
        ev.preventDefault();
        const picked = form.elements.option.value;
        if (!picked) return;
        const n = clampQty(qty.value);
        addToCart(picked, n);
        paintQty(1);
        status.innerHTML = "Added to your order." + ' <a href="/order">Review and place your order &rarr;</a>';
      });
    }).catch(() => {
      buy.innerHTML = unavailableHtml();
    });
  }

  /* ---------------------------------------------------------- order page */

  function initOrder() {
    const root = $("#order-root"), form = $("#order-form"), loading = $("#order-loading");
    if (!root || !form) return;

    const lines = $("#cart-lines"), totals = $("#cart-totals"), addSel = $("#add-option"),
          addBtn = $("#add-btn"), notice = $("#cart-notice"),
          deliveryBox = $("#delivery-fields"), lookup = $("#postcode-lookup"), localNote = $("#local-note"),
          summary = $("#order-summary"), errorBox = $("#order-error"), submit = $("#order-submit");

    let shop = null, index = {}, busy = false, done = false;

    const fulfilment = () => form.elements.fulfilment.value || "pickup_butcher";
    const cartNow = () => readCart().filter((it) => index[it.option_id]);

    // "12kg Beef Pack" already says its size; "1/2 Lamb Pack" does not.
    function lineSub(p, o) {
      const bits = [];
      const name = o.name.toLowerCase();
      if (o.label && name.indexOf(o.label.toLowerCase()) < 0) bits.push(o.label);
      if (o.size_kg != null && name.replace(/\s/g, "").indexOf(kg(o.size_kg).replace(/\s/g, "")) < 0) bits.push(kg(o.size_kg));
      bits.push(priceText(p, o.price_cents) + " each");
      return bits.join(" · ");
    }

    function paintCart() {
      const cart = cartNow();
      let total = 0, deposit = 0, est = false;
      lines.innerHTML = cart.length ? cart.map((it) => {
        const p = index[it.option_id].p, o = index[it.option_id].o;
        total += o.price_cents * it.qty;
        deposit += (p.deposit_cents || 0) * it.qty;
        est = est || isEstimate(p);
        return '<li class="cart-line" data-id="' + esc(o.id) + '">' +
          '<div><span class="cart-name">' + esc(o.name) + '</span><span class="cart-sub">' + esc(lineSub(p, o)) + "</span></div>" +
          '<div class="cart-amount">' + esc(priceText(p, o.price_cents * it.qty)) + "</div>" +
          '<div class="cart-controls">' + qtyHtml("", it.qty, "Quantity of " + o.name) +
            '<button type="button" class="link-btn" data-remove>Remove<span class="sr-only"> ' + esc(o.name) + "</span></button></div>" +
          "</li>";
      }).join("") : '<li class="cart-empty">Nothing in your order yet — choose a pack below to get started.</li>';

      totals.innerHTML = cart.length
        ? '<dl class="totals">' +
            '<div class="grand"><dt>' + (est ? "Estimated total" : "Total") + "</dt><dd>" + (est ? "about " : "") + money(total) + "</dd></div>" +
            (deposit > 0 ? "<div><dt>Deposit to secure your order</dt><dd>" + money(deposit) + "</dd></div>" : "") +
          "</dl>" +
          (est ? '<p class="fine">Pack prices are estimates — the final price is by packed retail weight.</p>' : "")
        : "";

      summary.textContent = !cart.length || deposit > 0
        ? "No payment now. We’ll email an invoice for the deposit" + (cart.length ? " (" + money(deposit) + ")" : "") +
          " with payment details; the balance is invoiced once your order is packed."
        : "No payment now. We’ll email an invoice with payment details.";

      paintLocalNote();
    }

    // Pies don’t go by carrier. Say so the moment the two are combined.
    function paintLocalNote() {
      const names = [];
      cartNow().forEach((it) => {
        const p = index[it.option_id].p;
        if (p.local_only && names.indexOf(p.name) < 0) names.push(p.name);
      });
      const show = names.length > 0 && fulfilment() === "delivery";
      localNote.hidden = !show;
      localNote.textContent = show
        ? listAnd(names) + " are pick-up / local only. Place the order and we’ll be in touch about getting them to you."
        : "";
    }

    function setQty(id, qty) {
      const cart = readCart();
      const it = cart.find((x) => x.option_id === id);
      if (!it) return;
      it.qty = clampQty(qty);
      writeCart(cart);
      paintCart();
    }

    lines.addEventListener("click", (ev) => {
      const li = ev.target.closest(".cart-line");
      if (!li) return;
      const id = li.dataset.id;
      const step = ev.target.closest("[data-step]");
      if (step) {
        const it = readCart().find((x) => x.option_id === id);
        if (!it) return;
        const dir = step.dataset.step;
        setQty(id, it.qty + Number(dir));
        // The list was redrawn; put the keyboard back where it was.
        const again = $$(".cart-line", lines).find((x) => x.dataset.id === id);
        const btn = again && $('[data-step="' + dir + '"]', again);
        if (btn && !btn.disabled) btn.focus(); else if (again) $("input", again).focus();
      } else if (ev.target.closest("[data-remove]")) {
        writeCart(readCart().filter((x) => x.option_id !== id));
        paintCart();
        addSel.focus();
      }
    });
    lines.addEventListener("change", (ev) => {
      const li = ev.target.closest(".cart-line");
      if (li && ev.target.matches("input")) setQty(li.dataset.id, ev.target.value);
    });
    // Enter in a quantity box means "that many", not "place the order".
    lines.addEventListener("keydown", (ev) => {
      if (ev.key === "Enter" && ev.target.matches("input")) { ev.preventDefault(); ev.target.blur(); }
    });

    function say(msg) { notice.textContent = msg; notice.hidden = !msg; }

    addBtn.addEventListener("click", () => {
      if (!addSel.value) { addSel.focus(); return; }
      addToCart(addSel.value, 1);
      addSel.value = "";
      say("");
      clearError();
      paintCart();
    });

    function paintDelivery() {
      const on = fulfilment() === "delivery";
      deliveryBox.hidden = !on;
      ["street", "suburb", "state", "postcode"].forEach((n) => { form.elements[n].required = on; });
      paintLocalNote();
    }
    $$('input[name="fulfilment"]', form).forEach((r) => r.addEventListener("change", paintDelivery));

    // The carrier’s run for a postcode. Answers are kept, and a slow answer
    // for a postcode that has since been changed is dropped.
    const zones = {};
    let asked = 0;
    function paintLookup(pc, z, failed) {
      lookup.className = "lookup " + (failed ? "" : z ? "yes" : "no");
      if (failed) {
        lookup.textContent = "We couldn’t check " + pc + " just now — place the order and we’ll confirm delivery.";
      } else if (z) {
        const days = Array.isArray(z.days) ? z.days : [];
        lookup.textContent = "We deliver to " + pc + (z.zone ? " (" + z.zone + ")" : "") +
          (days.length ? " on " + listAnd(days) : "");
        const state = form.elements.state;
        if (!state.value && z.region && $$("option", state).some((o) => o.value === z.region)) state.value = z.region;
      } else {
        lookup.textContent = "We don’t have a regular run to " + pc +
          " yet — place the order and we’ll get in touch about delivery";
      }
    }
    form.elements.postcode.addEventListener("input", () => {
      const pc = form.elements.postcode.value.trim();
      const mine = ++asked;
      if (!/^\d{4}$/.test(pc)) { lookup.textContent = ""; lookup.className = "lookup"; return; }
      if (pc in zones) { paintLookup(pc, zones[pc]); return; }
      lookup.className = "lookup";
      lookup.textContent = "Checking " + pc + "…";
      rpc("delivery_lookup", { p_farm: SHOP.farm, p_postcode: pc }).then((z) => {
        zones[pc] = z || null;
        if (mine === asked) paintLookup(pc, zones[pc]);
      }, () => {
        if (mine === asked) paintLookup(pc, null, true);
      });
    });

    function showError(msg) {
      // The message as it came, with our address made tappable if it is in there.
      errorBox.innerHTML = esc(msg).split(esc(EMAIL)).join(mailto(EMAIL));
      errorBox.hidden = false;
      errorBox.scrollIntoView({ block: "nearest" });
    }
    function clearError() { errorBox.hidden = true; errorBox.textContent = ""; }

    form.addEventListener("submit", (ev) => {
      ev.preventDefault();
      if (busy || done || !shop) return;
      clearError();

      const cart = cartNow();
      if (!cart.length) { say("Your order is empty — choose a pack first."); addSel.focus(); return; }
      if (!form.checkValidity()) { form.reportValidity(); return; }

      const val = (n) => (form.elements[n].value || "").trim();
      const ful = fulfilment(), delivery = ful === "delivery";
      const p = {
        name: val("name"),
        email: val("email"),
        phone: val("phone"),
        company: val("company"),
        fulfilment: ful,
        street: delivery ? val("street") : "",
        suburb: delivery ? val("suburb") : "",
        state: delivery ? val("state") : "",
        postcode: delivery ? val("postcode") : "",
        instructions: delivery ? val("instructions") : "",
        note: val("note"),
        website: form.elements.website.value,
        items: cart.map((it) => ({ option_id: it.option_id, qty: it.qty }))
      };
      const ordered = cart.map((it) => ({ qty: it.qty, name: index[it.option_id].o.name, cut: !!index[it.option_id].p.from_harvest }));

      busy = true;
      submit.disabled = true;
      submit.textContent = "Placing your order…";
      rpc("place_order", { p_farm: SHOP.farm, p: p }).then((res) => {
        if (!res || !res.ref) throw new Error(UNREACHABLE);
        done = true;
        onCartChange = null;
        writeCart([]);
        showConfirmation(res, p, ordered);
      }).catch((e) => {
        busy = false;
        submit.disabled = false;
        submit.textContent = "Place order";
        showError(e && e.message ? e.message : UNREACHABLE);
      });
    });

    function whenLine(res, p) {
      const h = res.harvest || null;
      if (p.fulfilment === "delivery") {
        const fee = " The delivery fee depends on where you are and is confirmed on your invoice.";
        if (h && (h.delivery_on || h.interstate_on)) {
          return (h.delivery_on ? "Delivery: " + fmtDate(h.delivery_on) + "." : "") +
            (h.interstate_on ? " Interstate deliveries: " + fmtDate(h.interstate_on) + "." : "") + fee;
        }
        return "We’ll be in touch to confirm your delivery date." + fee;
      }
      if (p.fulfilment === "pickup_farm") {
        return (h && h.pickup_on ? "Local pick-up: " + fmtDate(h.pickup_on) + ". " : "") +
          "We’ll be in touch to arrange a time to pick up from us in Trafalgar.";
      }
      const place = (h && h.pickup_place) || BUTCHER;
      return h && h.pickup_on
        ? "Pick-up: " + fmtDate(h.pickup_on) + ", from " + place + "."
        : "We’ll be in touch to confirm when your order is ready to pick up from " + place + ".";
    }

    function showConfirmation(res, p, ordered) {
      const email = (shop.farm && shop.farm.email) || EMAIL;
      const dep = Number(res.deposit_cents) || 0;
      const steps = [];
      steps.push(dep > 0
        ? "We’ll email an invoice for the deposit (" + money(dep) + ") with payment details. There is nothing to pay online."
        : "We’ll email an invoice with payment details. There is nothing to pay online.");
      if (ordered.some((l) => l.cut)) {
        steps.push("Once your order is butchered and packed we confirm the weights and invoice the balance.");
      }
      steps.push(whenLine(res, p));

      root.innerHTML =
        '<section class="confirm" tabindex="-1" aria-labelledby="confirm-h">' +
          '<p class="eyebrow">Order received</p>' +
          '<h1 id="confirm-h">Thank you — we’ve got your order</h1>' +
          '<p class="confirm-ref"><span>Your reference</span><strong>' + esc(res.ref) + "</strong></p>" +
          "<ul>" + ordered.map((l) => "<li>" + l.qty + " &times; " + esc(l.name) + "</li>").join("") + "</ul>" +
          "<h2>What happens next</h2>" +
          "<ol>" + steps.map((s) => "<li>" + esc(s) + "</li>").join("") + "</ol>" +
          "<p>Questions? Email " + mailto(email) + " and mention " + esc(res.ref) + ".</p>" +
          '<p class="actions"><a class="btn btn-ghost" href="/">Back to the shop</a></p>' +
        "</section>";
      const box = $(".confirm", root);
      window.scrollTo(0, 0);
      box.focus({ preventScroll: true });
    }

    loadShop().then((d) => {
      shop = d;
      index = optionIndex(d);

      // Something put in the order last week may since have been withdrawn.
      const kept = readCart();
      const live = kept.filter((it) => index[it.option_id]);
      if (live.length !== kept.length) {
        writeCart(live);
        say("Something in your order is no longer available and has been taken out.");
      }

      addSel.innerHTML = '<option value="">Choose a pack…</option>' + d.products.filter((p) => p.options.length).map((p) =>
        '<optgroup label="' + esc(p.name) + '">' + p.options.map((o) =>
          '<option value="' + esc(o.id) + '">' + esc(optionLine(p, o, true)) + "</option>").join("") + "</optgroup>").join("");

      onCartChange = paintCart;
      paintDelivery();
      paintCart();
      if (loading) loading.hidden = true;
      form.hidden = false;
    }).catch(() => {
      form.hidden = true;
      if (loading) { loading.className = ""; loading.innerHTML = unavailableHtml(); }
    });
  }

  /* ---------------------------------------------------------- go */

  function boot() {
    paintChrome();
    const b = document.body;
    if (b.dataset.page === "home") initHome();
    if (b.dataset.product) initProduct(b.dataset.product);
    if (b.dataset.page === "order") initOrder();
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
