// Cloudflare Worker — apibay search proxy with CORS headers.
//
// Deploy (no install needed):
//   1. https://dash.cloudflare.com  →  Workers & Pages  →  Create application
//      →  Create Worker.
//   2. Give it a name, e.g. "apibay-proxy", and click Deploy.
//   3. Click "Edit code", replace the sample with this whole file, Deploy again.
//   4. Your URL is shown at the top, e.g.
//        https://apibay-proxy.<your-subdomain>.workers.dev
//      Point the page's PROXY_BASE constant at that URL.
//
// Usage:  GET https://apibay-proxy.<sub>.workers.dev/?q=rick+morty
//         -> apibay JSON array, with Access-Control-Allow-Origin: *

export default {
  async fetch(request) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
    };

    // CORS preflight
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

    try {
      const upstream = await fetch(apiUrl, {
        headers: { "User-Agent": "apibay-magnet-search" },
      });
      const body = await upstream.text();
      return new Response(body, {
        status: upstream.status,
        headers: {
          ...cors,
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=60",
        },
      });
    } catch (err) {
      return new Response(JSON.stringify({ error: String(err) }), {
        status: 502,
        headers: { ...cors, "Content-Type": "application/json" },
      });
    }
  },
};
