// --- helpers ---
async function fetchJSON(url, opts) {
  const r = await fetch(url, opts);
  if (!r.ok) throw new Error(`HTTP ${r.status} for ${url}`);
  return r.json();
}



async function loadConfig() {
  try {
    // no-store so we don't get a stale config from SW/CF
    return await fetchJSON('/config.json', { cache: 'no-store' });
  } catch {
    return {};
  }
}

function render(services) {
  const list = document.getElementById('services');
  list.innerHTML = (services || []).map(s =>
    `<div class="card"><strong>${s.name}</strong><div>${s.duration_min} min · £${(s.price_cents/100).toFixed(2)}</div></div>`
  ).join('');
}

// --- main ---
async function init() {
  const cfg = await loadConfig();
  //const params = new URLSearchParams(location.search);
  //const apiOverride = params.get('api');               // e.g. ?api=http://54.171.xx.xx:8000
  const isLocalHost = ['localhost','127.0.0.1'].includes(location.hostname);

  let data;

  const params = new URLSearchParams(location.search);
  const apiOverride = params.get('api');
  const httpsOverride = apiOverride?.startsWith('https://');
  if (httpsOverride) {
    const base = apiOverride.replace(/\/$/, '');
    document.getElementById('api').textContent = '(api)';
    const data = await fetchJSON(`${base}/services`);
    return render(data.services);
  }
  
  if (apiOverride && isLocalHost) {
    // Force API when on localhost and ?api= is present
    const base = apiOverride.replace(/\/$/, '');
    console.log('[mode] API override via ?api=', base);
    document.getElementById('api').textContent = '(api)';
    data = await fetchJSON(`${base}/services`);
  } else if (cfg.servicesUrl && cfg.servicesUrl.trim()) {
    // Static mode (used on CloudFront)
    console.log('[mode] STATIC via config.servicesUrl:', cfg.servicesUrl);
    document.getElementById('api').textContent = '(static)';
    data = await fetchJSON(cfg.servicesUrl, { cache: 'no-store' });
  } else {
    // Auto: try static, else API (dev fallback)
    try {
      console.log('[mode] probing /services.json');
      data = await fetchJSON('/services.json', { cache: 'no-store' });
      document.getElementById('api').textContent = '(static)';
    } catch {
      const base = (apiOverride || cfg.apiBase || 'http://localhost:8000').replace(/\/$/, '');
      console.log('[mode] fallback API via', base);
      document.getElementById('api').textContent = '(api)';
      data = await fetchJSON(`${base}/services`);
    }
  }

  render(data.services);
}

// register SW (ok to keep during dev, but see cache-bust below)
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js');
}

init();
