// The carrier's booking manifest, made in one place so it is the same file
// wherever it is downloaded: Sales → Delivery, and the butcher's sheets.
//
// A module: `import { manifestRows, manifestFile, … } from "/carrier.js"`.

// Blackbird's twenty columns, in their order.
export const MANIFEST = ["Detrack Job Type", "Sender Name", "Group", "Order Identifier", "Delivery Identifier", "No. Cartons", "No. Pallets", "Delivery Name",
  "Phone Number", "Email", "Time Window", "Delivery Date", "Delivery Type", "Delivery Address", "Delivery State", "Delivery Suburb", "Delivery Postcode",
  "Delivery Zone ID", "Special Instructions", "No. of Shipping Labels"];

const kg = v => v == null || v === "" ? "" : String(+(+v).toFixed(2));
const pad4 = n => n < 10000 ? String(n).padStart(4, "0") : String(n);
const pcCell = pc => /^[1-9]\d{3}$/.test(pc || "") ? Number(pc) : (pc || "");

// What the driver is told when nobody typed anything: "24kg (2 Cartons, 12kg each)".
export const cartonText = o => `${kg(o.kg)}kg (${o.cartons} Carton${o.cartons > 1 ? `, ${kg(o.kg / o.cartons)}kg each` : ""})`;
// The number on the shipping label: the carrier's own reference if one was typed, else the order number.
export const labelId = o => o.carrier_ref || pad4(o.order_no);

// The rows under the heading row.
//
// m = { farm, prefix, phone, email,       the sender, as on the letterhead
//       code, deliveryOn,                 the harvest: its code, and its delivery day for orders with none of their own
//       deliveries: [order…],             as v_order has them: order_no, carrier_ref, cartons, kg, to_name, to_phone,
//                                         customer_email, deliver_on, ship_type, to_street, to_state, to_suburb,
//                                         to_postcode, ship_instructions
//       zoneOf(postcode),                 the carrier's zone for a postcode, or ""
//       collect }                         null, or where and when the carrier collects: { name, street, suburb, state,
//                                         postcode, window, note, on }
//
// A date is { d: "2026-12-11" } so the spreadsheet can make it a real date.
//
// The collection, when there is one, is the first row. It is the carrier's
// own collection job of 4 June 2026 put into these columns: the butcher's
// shop and its address, an 11:00-18:00 window, the farm's phone and email
// as the contact, "Pick up from …", and every carton.
export function manifestRows(m){
  const zone = pc => m.zoneOf(pc) || "";
  const rows = m.deliveries.map(o => ["Delivery", m.farm, m.farm, m.prefix, labelId(o), o.cartons, "", o.to_name, o.to_phone || "",
    o.customer_email || "", "08:00-18:00", { d: o.deliver_on || m.deliveryOn || "" }, o.ship_type, o.to_street || "", o.to_state || "", o.to_suburb || "",
    pcCell(o.to_postcode), zone(o.to_postcode), o.ship_instructions || cartonText(o), o.cartons]);
  const c = m.collect;
  if(c && rows.length){
    const total = rows.reduce((a, r) => a + r[5], 0);
    rows.unshift(["Collection", m.farm, m.farm, m.prefix, "C" + (m.code || "").replace(/^H/, ""), total, "", c.name, m.phone || "",
      m.email || "", c.window, { d: c.on || "" }, "Business", c.street, c.state, c.suburb, pcCell(c.postcode), zone(c.postcode), c.note, total]);
  }
  return rows;
}

const stamp = () => { const d = new Date(); return d.getFullYear() + String(d.getMonth() + 1).padStart(2, "0") + String(d.getDate()).padStart(2, "0"); };
// kind: "xlsx" or "csv".
export const manifestName = (farm, kind) => `Booking Manifest - ${farm}_${stamp()}.${kind}`;
export const manifestFile = (rows, kind) => kind === "xlsx" ? xlsx("Template", [MANIFEST, ...rows]) : csv([MANIFEST, ...rows]);

export function csv(rows){
  return new Blob([rows.map(r => r.map(v => { const s = v && typeof v === "object" ? (v.d || "") : String(v ?? "");
    return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s; }).join(",")).join("\r\n")], { type: "text/csv" });
}

// A real .xlsx with nothing but the browser: a zip of six small XML
// files, stored uncompressed. Strings are shared strings and dates are
// real date cells, because that is what the carrier's own template has.
const CRC = (() => { const t = new Uint32Array(256); for(let n = 0; n < 256; n++){ let c = n; for(let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; t[n] = c >>> 0; } return t; })();
const crc32 = u8 => { let c = 0xFFFFFFFF; for(let i = 0; i < u8.length; i++) c = CRC[(c ^ u8[i]) & 0xFF] ^ (c >>> 8); return (c ^ 0xFFFFFFFF) >>> 0; };
function zip(files){
  const enc = new TextEncoder(), parts = [], central = []; let off = 0;
  for(const [name, text] of files){
    const nm = enc.encode(name), data = enc.encode(text), crc = crc32(data), n = data.length;
    const lh = new DataView(new ArrayBuffer(30));
    lh.setUint32(0, 0x04034b50, true); lh.setUint16(4, 20, true); lh.setUint16(12, 0x21, true);
    lh.setUint32(14, crc, true); lh.setUint32(18, n, true); lh.setUint32(22, n, true); lh.setUint16(26, nm.length, true);
    const ch = new DataView(new ArrayBuffer(46));
    ch.setUint32(0, 0x02014b50, true); ch.setUint16(4, 20, true); ch.setUint16(6, 20, true); ch.setUint16(14, 0x21, true);
    ch.setUint32(16, crc, true); ch.setUint32(20, n, true); ch.setUint32(24, n, true); ch.setUint16(28, nm.length, true); ch.setUint32(42, off, true);
    parts.push(new Uint8Array(lh.buffer), nm, data); central.push(new Uint8Array(ch.buffer), nm);
    off += 30 + nm.length + n;
  }
  const end = new DataView(new ArrayBuffer(22));
  end.setUint32(0, 0x06054b50, true); end.setUint16(8, files.length, true); end.setUint16(10, files.length, true);
  end.setUint32(12, central.reduce((a, b) => a + b.length, 0), true); end.setUint32(16, off, true);
  return new Blob([...parts, ...central, new Uint8Array(end.buffer)], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
}
export function xlsx(sheetName, rows){
  const x = s => String(s).replace(/[&<>"]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
  const colName = i => { let s = ""; i++; while(i){ s = String.fromCharCode(65 + (i - 1) % 26) + s; i = Math.floor((i - 1) / 26); } return s; };
  const strs = [], idx = new Map();
  const sid = v => { if(!idx.has(v)){ idx.set(v, strs.length); strs.push(v); } return idx.get(v); };
  const cell = (v, r, c) => { const ref = colName(c) + r;
    if(v === null || v === undefined || v === "") return "";
    if(typeof v === "number") return `<c r="${ref}"><v>${v}</v></c>`;
    if(typeof v === "object"){ if(!v.d) return ""; const [y, m, dd] = v.d.split("-").map(Number);
      return `<c r="${ref}" s="1"><v>${Math.round((Date.UTC(y, m - 1, dd) - Date.UTC(1899, 11, 30)) / 86400000)}</v></c>`; }
    return `<c r="${ref}" t="s"><v>${sid(String(v))}</v></c>`; };
  const ns = 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"', head = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
  const sheet = `${head}<worksheet ${ns}><sheetData>${rows.map((row, i) => `<row r="${i + 1}">${row.map((v, c) => cell(v, i + 1, c)).join("")}</row>`).join("")}</sheetData></worksheet>`;
  return zip([
    ["[Content_Types].xml", `${head}<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/><Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/></Types>`],
    ["_rels/.rels", `${head}<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>`],
    ["xl/workbook.xml", `${head}<workbook ${ns} xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="${x(sheetName)}" sheetId="1" r:id="rId1"/></sheets></workbook>`],
    ["xl/_rels/workbook.xml.rels", `${head}<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/></Relationships>`],
    ["xl/styles.xml", `${head}<styleSheet ${ns}><fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts><fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills><borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="14" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/></cellXfs></styleSheet>`],
    ["xl/sharedStrings.xml", `${head}<sst ${ns} count="${strs.length}" uniqueCount="${strs.length}">${strs.map(s => `<si><t xml:space="preserve">${x(s)}</t></si>`).join("")}</sst>`],
    ["xl/worksheets/sheet1.xml", sheet]]);
}

export function download(blob, name){
  const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = name;
  document.body.appendChild(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

// ── a harvest's label files ─────────────────────────────────────
// Kept in the private bucket "harvest-files" (migration 79), one folder
// a harvest: <farm id>/<harvest id>/<stamp>-<file name>. The stamp keeps
// two uploads of "labels.pdf" apart and is not shown.
export const FILES = "harvest-files";
export const FILE_TYPES = ["application/pdf", "image/png", "image/jpeg"];
export const FILE_MAX = 25 * 1024 * 1024;
export const filePath = (farmId, harvestId, name) => {
  // Only letters, digits, dot, dash and underscore reach the store; anything
  // else becomes one underscore. The ending is kept, so a name with nothing
  // usable in it is still "file.pdf".
  const m = String(name).normalize("NFKD").match(/^(.*?)(\.[A-Za-z0-9]{1,8})?$/s);
  const stem = (m[1] || "").replace(/[^A-Za-z0-9._-]+/g, "_").replace(/^[._-]+|[._-]+$/g, "").slice(-110) || "file";
  return `${farmId}/${harvestId}/${Date.now()}-${stem}${(m[2] || "").toLowerCase()}`;
};
export const sizeText = n => n == null ? "" : n < 1024 ? n + " B" : n < 1048576 ? Math.round(n / 1024) + " KB" : (n / 1048576).toFixed(1) + " MB";
