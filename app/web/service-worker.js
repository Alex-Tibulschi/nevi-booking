const CACHE = "app-shell-v2"; // bump version to bust old cache
const ASSETS = [
  "/index.html",
  "/app.js",
  "/styles.css",
  "/manifest.json",
  "/config.json", // include cfg so it can work offline after first run
  "/services.json", // include static services for demo
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))
        )
      )
  );
});

// Only handle SAME-ORIGIN GET requests; don't touch cross-origin calls
self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  const sameOrigin = url.origin === self.location.origin;
  if (e.request.method !== "GET" || !sameOrigin) return;

  e.respondWith(
    fetch(e.request)
      .then((resp) => resp)
      .catch(async () => {
        const cached = await caches.match(e.request);
        if (cached) return cached;
        // As a last resort, return the shell (helps for navigations)
        if (e.request.mode === "navigate") return caches.match("/index.html");
        // Return an empty 503 instead of undefined to avoid TypeError
        return new Response("Offline", { status: 503, statusText: "Offline" });
      })
  );
});
