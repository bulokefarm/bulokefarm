// Where the shop's three public functions live. The key is the project's
// anon key: public by design, and it can call shop_front, delivery_lookup
// and place_order and nothing else.
window.SHOP = {
  url:  "https://hgnzignikbpdbbyubahu.supabase.co",
  key:  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhnbnppZ25pa2JwZGJieXViYWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU1NTgzNTcsImV4cCI6MjEwMTEzNDM1N30.U5vvmmZfSP0SOXsvLaxpjJ6LjWjOvaOYwTZ9VKyfFs0",
  farm: "buloke"
};

// Local testing only: on localhost a JSON {url,key} in localStorage "bf.api" overrides url/key.
(function () {
  var host = location.hostname;
  if (host !== "localhost" && host !== "127.0.0.1") return;
  try {
    var o = JSON.parse(localStorage.getItem("bf.api") || "null");
    if (o && typeof o.url === "string" && o.url) window.SHOP.url = o.url.replace(/\/+$/, "");
    if (o && typeof o.key === "string" && o.key) window.SHOP.key = o.key;
  } catch (e) { /* no storage, or not JSON: use the real one */ }
})();
