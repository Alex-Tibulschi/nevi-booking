# Nevi Booking

> Salon Booking PWA with a mocked Prism API and infrastructure scaffolding for production-ready deployment.

Nevi Booking ships a service-oriented Progressive Web App that demonstrates how a salon or studio could expose schedules, services, and bookings through a simple API + PWA stack while keeping hosting and infrastructure concerns versioned in Terraform.

## Core pillars

| Area | Description |
| --- | --- |
| **Client (PWA)** | `app/web` hosts the single-page HTML/CSS/JS bundle with a service worker, manifest, and offline metadata so it can install like a native app. |
| **Mock API** | `app/api` is a minimal Python/Prism server that proxies the API contract defined in `docs/openapi.yaml` and returns canned responses from `services.json`. |
| **Docs & policies** | `docs` carries the OpenAPI schema, example service catalog, policy contracts, and staff scheduling data that the client & API rely on. |
| **Infra & Ops** | `infra` holds Terraform modules for networking, database subnet groups, and authentication checks, while `ops` contains Docker Compose manifests for local testing. |

## Getting started

### Prerequisites

- Python 3.11+ (for `app/api` if you bolt on native execution)
- Docker & Docker Compose (tested with Compose v2+)
- Terraform 1.6+ (for `infra` modules) if you plan to deploy to the cloud

### Running locally

1. **Start the mock API**
   ```bash
   docker compose -f ops/compose/prism.yaml up --build
   ```
   The Prism server reads `app/api/services.json` and `docs/openapi.yaml`, so update those files to experiment with new endpoints.

2. **Serve the PWA**
   ```bash
   docker compose -f ops/compose/web.yaml up --build
   ```
   The static `app/web` files are served via a lightweight web server that caches via `service-worker.js`.

3. **Browser experience**
   - Open `http://localhost:3000` (or whatever port is defined in `ops/compose/web.yaml`).
   - Install the PWA using your browser’s “Install app” option.

Use `docs/services.example.json` and `docs/staff_schedule.example.json` as templates for customizing what the PWA displays.

## Directory reference

- `app/api` – Python-based Prism proxy (see `main.py` and `Dockerfile`). `requirements.txt` lists runtime dependencies.
- `app/web` – Vanilla JS PWA that consumes the mocked API; includes `manifest.json`, `service-worker.js`, and a simple `styles.css` layout.
- `infra` – Terraform modules for `_authcheck`, networking, and RDS subnet groups. Each subfolder contains `main.tf`, `providers.tf`, and optional `backend.tf` + `variables.tf` for remote state.
- `ops/compose` – Compose manifests for the Prism API (`prism.yaml`) and the static web server (`web.yaml`). Combine them with `docker compose -f ops/compose/prism.yaml -f ops/compose/web.yaml up` for a full stack.
- `docs` – Definitions that drive both client and API behavior (`openapi.yaml`, policy templates, service catalogs).

## Development workflow

1. **Update data/contract** – edit `docs/openapi.yaml` and the sample JSON files to shape endpoints.
2. **Refresh mock data** – regenerate `app/api/services.json` or align it with new responses.
3. **Rebuild the front-end** – as this is vanilla JS, simply editing `app/web` files is enough. Reload the browser or clear cache to see changes.
4. **Smoke tests** – run `curl` or a browser tab against the Prism endpoint to confirm the API follows the OpenAPI spec.

## Infrastructure & production notes

- `_authcheck` verifies the Terraform pipeline can authenticate before provisioning resources.
- `infra/network` defines VPC/subnet/security policies, while `infra/data/rds-subnet-group` prepares the RDS networking objects.
- The Terraform `providers.tf` files are wired to your environment via `backend.tf`; copy or adapt them for your cloud provider.

## Contribution & maintenance

1. Fork the repository and create a topic branch (e.g., `feature/pwa-offline`).
2. Update the OpenAPI schema + sample data if you add new endpoints.
3. Ensure `docker compose` still spins up both the Prism API and web client without errors.
4. Submit a pull request with a summary of the API changes, any policy updates in `docs`, and notes on how to test locally.

Feel free to extend the `app/web` UI, swap out Prism for a real backend, or add Terraform modules for storage buckets, email notifications, or scheduled jobs.
