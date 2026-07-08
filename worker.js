// Cloudflare Worker — apibay search proxy with CORS headers.
//
// Deploy (no install needed):
//   1. https://dash.cloudflare.com  →  Workers & Pages  →  open your worker.
//   2. Edit code, replace everything with this file, then click Deploy.
//
// Usage:  GET https://apibay-proxy.<sub>.workers.dev/?q=rick+morty
//         -> apibay JSON array, with Access-Control-Allow-Origin: *
//
// Reliability notes:
//   * A browser-like User-Agent avoids apibay throttling bot/default agents.
//   * Successful responses are cached at the Cloudflare edge (cacheTtlByStatus)
//     so repeat queries never re-hit apibay.
//   * 429s are retried a few times with backoff before giving up.

const UPSTREAM_HEADERS = {
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Accept": "application/json, text/plain, */*",
  "Referer": "https://thepiratebay.org/",
};

export default {
  async fetch(request) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors });
    }

    const q = new URL(request.url).searchParams.get("q");
    if (!q) {
      return new Response(JSON.stringify({ error: "missing ?q= parameter" }), {
        status: 400,
        headers: { ...cors, "Content-Type": "application/json" },
      });
    }

    const apiUrl =
      "https://apibay.org/q.php?q=" + encodeURIComponent(q).replace(/%20/g, "+");

    let status = 502;
    let body = JSON.stringify({ error: "upstream request failed" });

    for (let attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await new Promise((r) => setTimeout(r, 400 * attempt)); // 400ms, 800ms backoff
      }
      try {
        const upstream = await fetch(apiUrl, {
          headers: UPSTREAM_HEADERS,
          // Cache good responses at the edge; never cache errors.
          cf: { cacheEverything: true, cacheTtlByStatus: { "200-299": 300, "400-599": 0 } },
        });
        status = upstream.status;
        body = await upstream.text();
        if (status !== 429) break; // only retry on rate-limit
      } catch (err) {
        status = 502;
        body = JSON.stringify({ error: String(err) });
      }
    }

    return new Response(body, {
      status,
      headers: {
        ...cors,
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=300",
      },
    });
  },
};
