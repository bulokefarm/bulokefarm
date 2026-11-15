// send-mail — hands queued email to the farm's mailbox.
//
// The one piece of this system that is neither a page nor the database,
// and it is here for one reason: a browser must never hold the mailbox's
// password, and Postgres cannot speak to a mail server. Everything that
// is a decision — who is written to, in what words, whether an order
// gets an email at all — is made in the database (migration 76) and is a
// row in `mail` before this runs. This only carries:
//
//   mail_claim()   what is queued?           (queued -> sending)
//   SMTP           give each to the mailbox
//   mail_done()    it went / it did not, and why
//
// It takes no input. Calling it with nothing queued does nothing; calling
// it twice at once sends nothing twice (the claim is a lock). So it is
// safe for the website to call with the public key after an order, and
// for Sales to call after someone presses Send. It answers with two
// counts and never with anything about the mail itself.
//
// Secrets, set on the function in the Supabase dashboard — never in the
// repo, never in a page:
//
//   GMAIL_USER           the mailbox, e.g. bulokefarm@gmail.com
//   GMAIL_APP_PASSWORD   a Google "app password" for it (16 letters;
//                        needs 2-Step Verification on the account)
//
// It sends only mail whose From is that mailbox. A second farm in the
// same database, with a different address on its letterhead, gets a
// plain refusal in its log rather than its mail sent as someone else.
//
// Gmail is reached on port 465 (TLS from the first byte). Not 587 and
// not 25: Supabase closes both to functions.
//
// For a local stack: SMTP_HOST, SMTP_PORT and SMTP_TLS=false point it at
// the stack's own mail catcher, which wants no password.
//
// No libraries. SMTP is a short conversation, and a function with no
// imports has nothing to keep up to date.

const API = Deno.env.get("SUPABASE_URL") ?? "";
const KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const HOST = Deno.env.get("SMTP_HOST") || "smtp.gmail.com";
const PORT = Number(Deno.env.get("SMTP_PORT") || 465);
const SECURE = (Deno.env.get("SMTP_TLS") || "true").toLowerCase() !== "false";
const USER = (Deno.env.get("GMAIL_USER") || "").trim().toLowerCase();
const PASS = (Deno.env.get("GMAIL_APP_PASSWORD") || "").replace(/\s+/g, "");
const STEP_MS = 20_000; // how long any one step may take
const BATCH = 10;

type Mail = {
  id: string;
  attempts: number;
  from_email: string;
  from_name: string;
  to_email: string;
  to_name: string | null;
  reply_to: string | null;
  subject: string;
  body_text: string;
  body_html: string;
};

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });

async function rpc(fn: string, body: unknown): Promise<unknown> {
  const r = await fetch(`${API}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { apikey: KEY, Authorization: `Bearer ${KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const t = await r.text();
  if (!r.ok) throw new Error(`${fn}: ${r.status} ${t.slice(0, 300)}`);
  return t ? JSON.parse(t) : null;
}

// ── writing a message ───────────────────────────────────────────

const enc = new TextEncoder();
const dec = new TextDecoder();

function b64(bytes: Uint8Array): string {
  let s = "";
  for (let i = 0; i < bytes.length; i += 0x8000) s += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  return btoa(s);
}
const b64s = (s: string) => b64(enc.encode(s));
const lines76 = (s: string) => s.replace(/.{76}/g, "$&\r\n").replace(/\r\n$/, "");
const crlf = (s: string) => s.replace(/\r?\n/g, "\r\n");

// A header is one line. Whatever was typed into a name or a subject, a
// line break in it must not become a second header.
const oneLine = (s: string) => s.replace(/[\r\n\t\0]+/g, " ").trim();
const ascii = (s: string) => /^[\x20-\x7e]*$/.test(s);

// RFC 2047: anything not plain ASCII goes as =?UTF-8?B?…?= words, each
// short enough for a header line and cut between characters, not bytes.
function words(text: string): string {
  const s = oneLine(text);
  if (ascii(s)) return s;
  const out: string[] = [];
  let cur = "", n = 0;
  for (const ch of s) {
    const k = enc.encode(ch).length;
    if (n + k > 42) { out.push(cur); cur = ""; n = 0; }
    cur += ch; n += k;
  }
  if (cur) out.push(cur);
  return out.map((c) => `=?UTF-8?B?${b64s(c)}?=`).join("\r\n ");
}

function who(name: string | null, email: string): string {
  const n = oneLine(name || "");
  if (!n) return `<${email}>`;
  return ascii(n) ? `"${n.replace(/["\\]/g, "")}" <${email}>` : `${words(n)} <${email}>`;
}

// The same test the database applies before it queues (mail_put).
const ADDRESS = /^[^@\s<>,;:"()\[\]\\]+@[a-z0-9.-]+\.[a-z]{2,}$/;

function message(m: Mail): string {
  const b = "=_" + crypto.randomUUID().replace(/-/g, "").slice(0, 20);
  const part = (type: string, body: string) =>
    `--${b}\r\nContent-Type: ${type}; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n` +
    lines76(b64s(crlf(body))) + "\r\n";
  const html = '<!doctype html><html><head><meta charset="utf-8"></head>' +
    `<body style="margin:0;padding:16px;background:#ffffff">${m.body_html}</body></html>`;
  const head = [
    `From: ${who(m.from_name, m.from_email)}`,
    `To: ${who(m.to_name, m.to_email)}`,
    ...(m.reply_to && ADDRESS.test(m.reply_to) ? [`Reply-To: <${m.reply_to}>`] : []),
    `Subject: ${words(m.subject)}`,
    `Date: ${new Date().toUTCString().replace("GMT", "+0000")}`,
    "MIME-Version: 1.0",
    `Content-Type: multipart/alternative; boundary="${b}"`,
  ]; // no Message-ID: the mailbox gives it one of its own

  return head.join("\r\n") + "\r\n\r\n" + part("text/plain", m.body_text) + part("text/html", html) + `--${b}--`;
}

// ── the conversation with the mail server ───────────────────────

function timed<T>(p: Promise<T>, doing: string): Promise<T> {
  let t = 0;
  const late = new Promise<never>((_, no) => {
    t = setTimeout(() => no(new Error(`Timed out ${doing}`)), STEP_MS);
  });
  return Promise.race([p, late]).finally(() => clearTimeout(t));
}

class Smtp {
  #conn: Deno.Conn | null = null;
  #buf = new Uint8Array(0);

  async open() {
    const at = { hostname: HOST, port: PORT };
    this.#conn = await timed<Deno.Conn>(SECURE ? Deno.connectTls(at) : Deno.connect(at), `connecting to ${HOST}:${PORT}`);
    await this.#expect("On connecting", [220]);
    let me = "localhost";
    try { me = new URL(API).hostname || me; } catch { /* keep localhost */ }
    await this.#say(`EHLO ${me}`, "On saying hello", [250]);
    if (PASS) await this.#say("AUTH PLAIN " + b64s(`\0${USER}\0${PASS}`), "On signing in", [235]);
  }

  async send(from: string, to: string, data: string) {
    await this.#say(`MAIL FROM:<${from}>`, "On naming the sender", [250]);
    await this.#say(`RCPT TO:<${to}>`, "On naming the recipient", [250, 251]);
    await this.#say("DATA", "On starting the message", [354]);
    await this.#write(data.replace(/^\./gm, "..") + "\r\n.\r\n");
    await this.#expect("On handing over the message", [250]);
  }

  async close() {
    try { if (this.#conn) await this.#say("QUIT", "On leaving", [221]); } catch { /* leaving anyway */ }
    try { this.#conn?.close(); } catch { /* already closed */ }
    this.#conn = null;
  }

  async #write(s: string) {
    const d = enc.encode(s);
    let o = 0;
    while (o < d.length) o += await timed(this.#conn!.write(d.subarray(o)), "talking to the mail server");
  }

  async #line(): Promise<string> {
    for (;;) {
      const i = this.#buf.indexOf(10);
      if (i >= 0) {
        const l = dec.decode(this.#buf.subarray(0, i)).replace(/\r$/, "");
        this.#buf = this.#buf.slice(i + 1);
        return l;
      }
      const more = new Uint8Array(4096);
      const n = await timed(this.#conn!.read(more), "waiting for the mail server");
      if (n === null) throw new Error("The mail server hung up");
      const next = new Uint8Array(this.#buf.length + n);
      next.set(this.#buf);
      next.set(more.subarray(0, n), this.#buf.length);
      this.#buf = next;
    }
  }

  // A reply is one or more lines; all but the last have a hyphen after the code.
  async #expect(when: string, ok: number[]) {
    const said: string[] = [];
    let code = 0;
    for (;;) {
      const l = await this.#line();
      said.push(l.slice(4));
      if (!/^\d{3}-/.test(l)) { code = Number(l.slice(0, 3)); break; }
    }
    if (!ok.includes(code)) throw new Error(`${when}, the mail server said: ${code} ${said.join(" ")}`.slice(0, 400));
  }

  async #say(line: string, when: string, ok: number[]) {
    await this.#write(line + "\r\n");
    await this.#expect(when, ok);
  }
}

// What went wrong, for the log a person reads. The password is never part
// of an error — this makes sure of it.
function reason(e: unknown): string {
  let s = e instanceof Error ? e.message : String(e);
  if (PASS) s = s.split(PASS).join("•••");
  return s.slice(0, 400);
}

// ── one call: send what is queued ───────────────────────────────

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  let sent = 0, failed = 0;
  try {
    const rows = ((await rpc("mail_claim", { p_limit: BATCH })) ?? []) as Mail[];
    let smtp: Smtp | null = null;
    // Something wrong with the mailbox itself is wrong for every message.
    let all = SECURE && !(USER && PASS)
      ? "No mailbox is set up yet. The send-mail function needs GMAIL_USER and GMAIL_APP_PASSWORD (Supabase → Edge Functions → Secrets)."
      : "";

    for (const m of rows) {
      let err = all;
      if (!err && USER && m.from_email !== USER) {
        err = `This system sends as ${USER}, and the farm's email address is ${m.from_email}.`;
      }
      if (!err && !ADDRESS.test(m.to_email)) err = `“${m.to_email}” is not an address mail can go to.`;

      if (!err && !smtp) {
        smtp = new Smtp();
        try {
          await smtp.open();
        } catch (e) {
          const why = reason(e);
          all = err = (/\b535\b/.test(why)
            ? "The mailbox did not accept the app password. Make a new one (myaccount.google.com/apppasswords) and put it in the GMAIL_APP_PASSWORD secret. "
            : "Could not open the mailbox. ") + why;
          await smtp.close();
          smtp = null;
        }
      }
      if (!err && smtp) {
        try {
          await smtp.send(m.from_email, m.to_email, message(m));
        } catch (e) {
          err = "Not accepted. " + reason(e);
          await smtp.close(); // start the next one on a clean line
          smtp = null;
        }
      }

      await rpc("mail_done", { p_id: m.id, p_ok: !err, p_error: err || null });
      if (err) failed++; else sent++;
    }
    if (smtp) await smtp.close();
    return json({ sent, failed });
  } catch (e) {
    console.error("send-mail:", reason(e));
    return json({ error: "send-mail could not run", sent, failed }, 500);
  }
});
