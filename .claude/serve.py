"""A static server that behaves like Cloudflare Pages for local testing.

    python .claude/serve.py public 8788     # the app:  /sales -> public/sales.html
    python .claude/serve.py site   8789     # the public website

Clean URLs only; no caching. Not used in production — Pages serves the
directories as they are.
"""
import http.server
import os
import sys

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "public")
port = int(sys.argv[2]) if len(sys.argv) > 2 else 8788


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=root, **k)

    def translate_path(self, path):
        p = super().translate_path(path)
        if not os.path.exists(p) and os.path.exists(p + ".html"):
            return p + ".html"
        return p

    def send_error(self, code, message=None, explain=None):
        nf = os.path.join(root, "404.html")
        if code == 404 and os.path.exists(nf):
            body = open(nf, "rb").read()
            self.send_response(404)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        super().send_error(code, message, explain)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt, *args):
        if "404" in (args[1] if len(args) > 1 else ""):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    print(f"serving {root} on http://localhost:{port}", flush=True)
    http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
