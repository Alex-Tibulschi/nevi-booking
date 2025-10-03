self.addEventListener("install", (e) => {
  e.waitUntil(
    caches
      .open("app-shell")
      .then((c) => c.addAll(["/index.html", "/app.js", "/styles.css"]))
  );
});
self.addEventListener("fetch", (e) => {
  e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
});
