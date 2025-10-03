const api =
  new URLSearchParams(location.search).get("api") || "http://localhost:8000";
async function fetchJSON(p) {
  const r = await fetch(p);
  return r.json();
}
async function init() {
  document.getElementById("api").textContent = api;
  const svc = await fetchJSON(`${api}/services`);
  const list = document.getElementById("services");
  list.innerHTML = svc.services
    .map(
      (s) =>
        `<div class="card"><strong>${s.name}</strong><div>${
          s.duration_min
        } min · £${(s.price_cents / 100).toFixed(2)}</div></div>`
    )
    .join("");
}
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js");
}
init();
