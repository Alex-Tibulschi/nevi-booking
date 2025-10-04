async function fetchJSON(url, opts) {
  const r = await fetch(url, opts);
  if (!r.ok) throw new Error(`HTTP ${r.status} for ${url}`);
  return r.json();
}

async function tryStatic() {
  // Try config.json (no-store so CF doesn't serve a stale one)
  try {
    const cfg = await fetchJSON('/config.json', { cache: 'no-store' });
    if (cfg && typeof cfg.servicesUrl === 'string' && cfg.servicesUrl.trim()) {
      console.log('[mode] STATIC via config.servicesUrl:', cfg.servicesUrl);
      return await fetchJSON(cfg.servicesUrl);
    }
    console.log('[mode] config.json present but no servicesUrl; will probe /services.json next');
  } catch (e) {
    console.log('[mode] no config.json or failed to parse, will probe /services.json:', e.message);
  }

  // Probe /services.json directly
  try {
    const s = await fetchJSON('/services.json', { cache: 'no-store' });
    console.log('[mode] STATIC via /services.json');
    return s;
  } catch (e) {
    console.log('[mode] /services.json not found:', e.message);
    return null;
  }
}

async function tryAPI() {
  const params = new URLSearchParams(location.search);
  const urlParam = params.get('api');                     // dev override
  const isLocal = ['localhost', '127.0.0.1'].includes(location.hostname);

  // Only allow API calls from localhost (so production never hits localhost)
  if (!isLocal && !urlParam) {
    console.log('[mode] Not localhost and no ?api= — refusing to call any API');
    throw new Error('No API allowed in production');
  }

  const apiBase = urlParam || 'http://localhost:8000';
  console.log('[mode] API via', apiBase);
  return await fetchJSON(`${apiBase}/services`);
}

async function init() {
  document.getElementById('services').innerHTML = 'Loading…';

  // 1) STATIC first
  const staticData = await tryStatic();
  if (staticData && staticData.services) {
    document.getElementById('api').textContent = '(static)';
    render(staticData.services);
    return;
  }

  // 2) Only if static failed, try API (dev/local only)
  try {
    const apiData = await tryAPI();
    document.getElementById('api').textContent = '(api)';
    render(apiData.services);
  } catch (e) {
    console.error('[error] Could not load services from static or API:', e);
    document.getElementById('services').innerHTML =
      '<div class="card">Unable to load services. Check config or upload services.json.</div>';
  }
}

function render(services) {
  const list = document.getElementById('services');
  list.innerHTML = (services || []).map(s =>
    `<div class="card"><strong>${s.name}</strong><div>${s.duration_min} min · £${(s.price_cents/100).toFixed(2)}</div></div>`
  ).join('');
}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js');
}

init();
