// Shared menu for all three pages. Loaded as a plain script, not a
// module, so it can attach before the page's own code runs.
//
// Pages opt in with two things:
//   <button id="navbtn" aria-label="Menu">≡</button>   somewhere in the header
//   window.__signOut = () => db.auth.signOut();        so the menu can sign out
//
// Clicks are delegated, so a header that gets re-rendered keeps working.
(function () {
  var LINKS = [
    ["/",        "Herd & recording", "Animals, map, family tree, everything you record"],
    ["/reports", "Records & reports", "LPA treatments, feed, movements — printable"],
    ["/map",     "Paddock editor",    "Trace fence lines on satellite imagery"]
  ];

  var here = location.pathname.replace(/index\.html$/, "").replace(/\/$/, "") || "/";

  var css = document.createElement("style");
  css.textContent = `
  #navbtn{border:0;background:none;font-size:22px;line-height:1;cursor:pointer;
    padding:6px 8px;color:inherit;border-radius:8px;flex:none}
  #navbtn:hover{background:rgba(0,0,0,.06)}
  #navveil{position:fixed;inset:0;background:rgba(22,21,15,.42);z-index:9998;
    opacity:0;pointer-events:none;transition:opacity .16s}
  #navveil.on{opacity:1;pointer-events:auto}
  #navdrawer{position:fixed;top:0;right:0;bottom:0;width:min(310px,86vw);z-index:9999;
    background:#FFF;border-left:1px solid #D9D6CC;transform:translateX(100%);
    transition:transform .18s ease-out;display:flex;flex-direction:column;
    font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;color:#16150F}
  #navdrawer.on{transform:none}
  #navdrawer .nhead{display:flex;align-items:center;gap:10px;padding:16px 16px 14px;
    border-bottom:1px solid #D9D6CC}
  #navdrawer .nhead img{width:30px;height:30px;border-radius:7px}
  #navdrawer .nhead b{font-size:13px;letter-spacing:.14em;text-transform:uppercase;flex:1}
  #navdrawer .nclose{border:0;background:none;font-size:24px;line-height:1;color:#5A574E;
    cursor:pointer;padding:2px 6px}
  #navdrawer a{display:block;padding:14px 16px;border-bottom:1px solid #D9D6CC;
    text-decoration:none;color:inherit}
  #navdrawer a:hover{background:#E2EDEA}
  #navdrawer a[aria-current="page"]{background:#E2EDEA;box-shadow:inset 3px 0 0 #12564F}
  #navdrawer a .t{display:block;font-weight:600;font-size:15px}
  #navdrawer a .d{display:block;font-size:12.5px;color:#5A574E;margin-top:3px;line-height:1.4}
  #navdrawer .nfoot{margin-top:auto;padding:14px 16px calc(16px + env(safe-area-inset-bottom));
    border-top:1px solid #D9D6CC}
  #navdrawer .nfoot button{width:100%;min-height:44px;border:1px solid #D9D6CC;border-radius:9px;
    background:#FFF;font:inherit;font-size:14px;font-weight:600;cursor:pointer;color:#8C2F2A}
  #navdrawer .nfoot p{margin:10px 0 0;font-size:11.5px;color:#5A574E;text-align:center}
  @media print{#navbtn,#navveil,#navdrawer{display:none !important}}`;
  document.head.appendChild(css);

  var veil = document.createElement("div");
  veil.id = "navveil";

  var d = document.createElement("aside");
  d.id = "navdrawer";
  d.setAttribute("aria-hidden", "true");
  d.innerHTML =
    '<div class="nhead"><img src="/mark.png" alt=""><b>Buloke Farm</b>' +
    '<button class="nclose" aria-label="Close">&times;</button></div>' +
    LINKS.map(function (l) {
      var cur = l[0] === here;
      return '<a href="' + l[0] + '"' + (cur ? ' aria-current="page"' : "") +
             '><span class="t">' + l[1] + (cur ? " ·" : "") + '</span>' +
             '<span class="d">' + l[2] + "</span></a>";
    }).join("") +
    '<div class="nfoot"><button id="navout">Sign out</button>' +
    '<p>admin.bulokefarm.com.au</p></div>';

  document.addEventListener("DOMContentLoaded", function () {
    document.body.appendChild(veil);
    document.body.appendChild(d);
  });

  function open()  { veil.classList.add("on");   d.classList.add("on");
                     d.setAttribute("aria-hidden","false"); }
  function close() { veil.classList.remove("on"); d.classList.remove("on");
                     d.setAttribute("aria-hidden","true"); }

  document.addEventListener("click", function (e) {
    if (e.target.closest("#navbtn"))  { e.preventDefault(); open();  return; }
    if (e.target.closest(".nclose") || e.target === veil) { close(); return; }
    if (e.target.closest("#navout")) {
      if (!confirm("Sign out?")) return;
      var done = function () { location.reload(); };
      if (typeof window.__signOut === "function") {
        try { Promise.resolve(window.__signOut()).then(done, done); }
        catch (err) { done(); }
      } else done();
    }
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") close();
  });
})();
