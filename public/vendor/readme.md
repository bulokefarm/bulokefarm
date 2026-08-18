# vendor/

## supabase.js

`@supabase/supabase-js` **2.111.0**, self-contained. One file, no network
imports, no build step. Exports `createClient`.

Built from the published UMD bundle, which is the only artefact in the
package with its whole dependency graph already inlined:

    npm pack @supabase/supabase-js@2.111.0
    tar -xzf supabase-supabase-js-2.111.0.tgz
    { cat package/dist/umd/supabase.js
      echo 'export const createClient = supabase.createClient;'
      echo 'export default supabase;'; } > public/vendor/supabase.js

### Do not save the file esm.sh serves at /@supabase/supabase-js@2

That URL returns a four-line *stub*, not a bundle:

    import "/node/buffer.mjs";
    import "/node/process.mjs";
    export * from "/@supabase/supabase-js@2.111.0/es2020/supabase-js.bundle.mjs";

Those paths are absolute and were relative to esm.sh. Served from our own
origin they resolve to `/node/process.mjs` here, Pages answers with the
404 HTML page, the browser rejects it on MIME type, and the module fails.
The `try/catch` in each page then falls through to esm.sh — so the app
still works and the "vendored" copy silently does nothing. This shipped
that way and was only caught by a console error.

### Checking it is real

    wc -c public/vendor/supabase.js        # ~210 KB, not ~180 bytes
    grep -n 'import "' public/vendor/supabase.js   # must print nothing

### Upgrading

Repeat the commands above with the new version, update this file, then
confirm the console is clean and the herd list loads. Pin the exact
version — never `@2`.
