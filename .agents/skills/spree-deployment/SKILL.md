---
name: spree-deployment
description: Use when deploying a Spree 6 application to production or scaling it — Docker image builds, Render/AWS/Railway/Kubernetes/VPS, required environment variables, Solid Queue (jobs in Puma vs a dedicated `bin/jobs` worker), Solid Cache, optional Sidekiq/Redis, the Mission Control `/jobs` dashboard, serving the React dashboard at `/dashboard` or from a static host, migrations on boot and `spree:upgrade`, S3/R2 storage, CDN_HOST, Meilisearch, PostgreSQL/MySQL/SQLite, and observability (spree_opentelemetry, Sentry). Common phrasings include "deploy Spree", "Spree Docker image", "spree build --production", "Render deploy", "Spree environment variables", "split the worker", "SOLID_QUEUE_IN_PUMA", "jobs not running", "/jobs dashboard locked", "dashboard 404 in production", "images point at localhost", "S3 setup", "Sidekiq instead of Solid Queue", "OpenTelemetry tracing". Spree-specific bits only — generic Rails deployment is out of scope.
---

# Deploying Spree

A Spree 6 production deployment is **one Docker image + one database**. The same image runs the Store/Admin API, serves the React admin at `/dashboard`, and — by default — processes background jobs in-process. Jobs (Solid Queue) and cache (Solid Cache) live in the database; Redis is optional. Everything is configured with environment variables.

Project layout reminder: the Rails app is `server/` (older projects: `backend/`), the admin dashboard is `apps/dashboard/`. Classic flavor (plain Rails app with Spree gems at the repo root) uses the same env vars and Rails config — only the paths and the CLI wrapper differ.

## Topology decision

| Shape | When | How |
|---|---|---|
| **Combined** (default) | Most stores; one container is the whole app | Web container runs Puma with the Solid Queue plugin (`SOLID_QUEUE_IN_PUMA=true`) |
| **Split worker** | Heavy imports, big catalogs, marketplaces syncing many sellers, multi-tenant | Same image, second service with command `bin/jobs`; set `SOLID_QUEUE_IN_PUMA=false` on web |
| **Distributed** | Independent scaling/release of surfaces | API behind a load balancer; dashboard as static files on a CDN; storefront (Next.js) on Vercel/Node host |
| **Sidekiq** | Only when a dedicated Solid Queue worker with raised `JOB_THREADS`/`JOB_CONCURRENCY` no longer keeps up | Swap Active Job adapter to Sidekiq on Redis/Valkey (see below) |

Start combined; every step up is configuration, not code.

## Building the image

```bash
spree eject                                    # once — materializes server/ incl. its production Dockerfile
spree build --production                       # → <project>-spree:latest
spree build --production --tag registry.example.com/my-store:v42

# without the CLI, from the project root:
docker build . -f server/Dockerfile -t my-store
```

Build from the **project root** as context: the Dockerfile detects `server/` (Rails) and `apps/dashboard/` (your customized dashboard) and bakes your dashboard build into the image. Without `apps/dashboard/`, the stock dashboard is baked in. `spree build --production` recognizes the layout-aware Dockerfile by its `.spree-custom-app` marker (`.spree-custom-dashboard` in the first release); without either it falls back to building with `server/` as the context. So if your `server/Dockerfile` predates this layout support, update it from the spree-starter template — otherwise you ship the stock dashboard over your customized one.

Uncustomized stores can run the official multi-arch image `ghcr.io/spree/spree:<version>` directly.

## Environment variables

Strictly required: `DATABASE_URL`, `SECRET_KEY_BASE`. Practically required: `RAILS_HOST` and the three Active Record encryption keys. Full table: [references/environment-variables.md](references/environment-variables.md).

| Variable | Why it matters |
|---|---|
| `DATABASE_URL` | `postgres://…`, `mysql2://…`, or `sqlite3:db/production.sqlite3` |
| `SECRET_KEY_BASE` | `openssl rand -hex 64`. Keep stable — sessions, cookies, JWT fallback and secret-API-key digests depend on it |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`, `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`, `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` | Encrypt webhook signing secrets, gateway customer IDs and OAuth identity tokens at rest. Unset → plaintext + a boot warning. Generate with `spree encryption init --print` or `bin/rails db:encryption:init`; a separate set per environment, backed up; **never change them once data is encrypted**. Workers need the same values as web. See `spree-security` |
| `RAILS_HOST` | Public host (no protocol) for email links, webhook payloads, and attachment URLs in API responses. Unset → URLs point at `localhost`. On Render, falls back to `RENDER_EXTERNAL_HOSTNAME` |
| `CDN_HOST` | Optional separate host for assets and images (sets `config.asset_host` and `Spree.cdn_host`) |
| `SOLID_QUEUE_IN_PUMA` | `true` (default) runs jobs in the web process; `false` when a `bin/jobs` worker runs |
| `JOB_THREADS` / `JOB_CONCURRENCY` | Worker threads (default 3) / worker processes (default 1) |
| `SPREE_IMPORT_JOB_CONCURRENCY` | Cap on concurrent CSV import group jobs (default 75% of `JOB_THREADS`, min 1; `0` = no cap) |
| `MISSION_CONTROL_USER` / `MISSION_CONTROL_PASSWORD` | HTTP Basic auth for `/jobs`. Unset in production → dashboard locked |
| `SMTP_HOST` (+ `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_FROM_ADDRESS`) | Without `SMTP_HOST`, production sends no email. Any SMTP provider works, with nothing to install. STARTTLS is always attempted, so use port 587, not an implicit-TLS 465. Auth is `plain`, sent only when `SMTP_USERNAME` is set. Merchants override From/Reply-To per store in Settings → Emails |
| `AWS_*` or `CLOUDFLARE_*` | Object storage for uploads — required on ephemeral filesystems |
| `RAILS_FORCE_SSL` / `RAILS_ASSUME_SSL` | Both default `true` (behind a TLS-terminating proxy). Set both `false` only when there is no TLS anywhere |
| `SENTRY_DSN`, `OTEL_*`, `MEILISEARCH_URL` | Optional integrations (below) |

Puma: `PORT` (3000), `RAILS_MAX_THREADS` (3), `WEB_CONCURRENCY` (1; `auto` = one per core, ~1 GB RAM each).

## Database

- **PostgreSQL** recommended; **MySQL/MariaDB** and **SQLite** are supported in production too (SQLite: single host only, small stores).
- Pool size must cover web threads **plus** in-process job threads: the template's `database.yml` uses `RAILS_MAX_THREADS + JOB_THREADS + 3`. If you hand-roll `database.yml`, keep that formula or jobs in Puma will exhaust the pool.
- Solid Queue, Solid Cache and Solid Cable tables live in the same database — back it up as one unit.

## Migrations, seeds, and upgrades

- The image entrypoint (`bin/docker-entrypoint`) runs `bin/rails db:prepare` **only when the container command is the Rails server** — creates + seeds on first boot, migrates on later boots. `bin/jobs` workers don't migrate.
- **First boot:** run it once before scaling out — a release/init job running `bin/rails db:prepare`, or a single web replica. Rails' migration advisory lock (PostgreSQL/MySQL) serializes migrations only, not database creation, schema load or seeding, so replicas racing on an empty database can collide or double-seed.
- **Later boots:** several web replicas migrating at once is fine on PostgreSQL/MySQL (the advisory lock). If your platform has a release/pre-deploy phase and you want failed migrations to block the rollout, run `bin/rails db:migrate` there instead.
- After upgrading Spree gems, run the data backfills once per environment: `bin/rails spree:upgrade` (idempotent; `DRY_RUN=1` to preview). The entrypoint does **not** run it — use a release command or one-off task. See the `spree-upgrade` skill.
- No default admin exists. Seeding prints a one-time setup link; print it again with `bin/rails spree:setup:token`.

## Background jobs (Solid Queue)

- `config/puma.rb` loads `plugin :solid_queue` when `SOLID_QUEUE_IN_PUMA` is `true`.
- `config/queue.yml` defines worker queues in polling order (checkout-critical first, bulk catalog next, Active Storage housekeeping last) with a trailing `"*"` so any unlisted queue still runs.
- Spree jobs pick their queue from `Spree.queues.<name>` (every entry defaults to `:default`); the template's `config/initializers/spree.rb` maps them to `spree_*` names. See `spree-performance` for tuning.
- `config/recurring.yml` is Solid Queue's cron. The template schedules (production only):
  - `Spree::StockReservations::ExpireJob` — every minute (releases expired checkout holds)
  - `Spree::Orders::FinalizeStaleDraftsJob` — every 5 minutes (finishes orders whose payment succeeded but whose completion never committed; never refunds)
  - `Spree::Carts::ReapExpiredJob` — hourly (deletes abandoned carts past expiry; carts with a live payment are kept)
  - `Spree::Collections::RegenerateTimeBasedJob` — hourly (automatic collections with time-based rules)
  - `spree:price_history:prune` rake task (via a `command:` entry) — daily (EU Omnibus retention, per store)
  - `Spree::SellerPayouts::SweepDueJob` — daily (marketplace payouts; run it daily regardless of seller payout intervals — due-ness is decided per seller)
  - `Spree::SellerTransfers::ExecutePendingDueJob` — hourly (retries refused seller transfers)
  - Solid Queue finished-job and Solid Cable message cleanup — hourly

  The marketplace jobs are no-ops on a store without sellers — keep them. If your project predates any entry, copy it from the spree-starter `config/recurring.yml`.
- Split mode: add a service running `bin/jobs` with the same env (`DATABASE_URL`, `SECRET_KEY_BASE`, `RAILS_HOST`), raise `JOB_THREADS` there, scale with `JOB_CONCURRENCY` or more replicas, and set `SOLID_QUEUE_IN_PUMA=false` on web. On a split deployment set `SPREE_IMPORT_JOB_CONCURRENCY` explicitly on **web** — the cap is computed by the process that enqueues the import.

### Mission Control (`/jobs`)

Mounted at `/jobs` in the template's routes. Set `MISSION_CONTROL_USER` and `MISSION_CONTROL_PASSWORD`; in development they default to `spree` / `spree123`. It's Solid Queue-specific.

### Swapping to Sidekiq (optional)

```ruby
# Gemfile
gem "sidekiq"
gem "sidekiq-cron"        # replaces config/recurring.yml

# config/application.rb
config.active_job.queue_adapter = :sidekiq
```

- `config/sidekiq.yml` must list **every** queue you assigned via `Spree.queues` plus `default`, `mailers`, and the `active_storage_*` queues — Sidekiq has no `"*"` catch-all, so an unlisted queue never runs.
- Move `recurring.yml` schedules to `config/schedule.yml` (sidekiq-cron). sidekiq-cron schedules jobs, not commands, so wrap the `spree:price_history:prune` task in a small job (`Rails.application.load_tasks` unless defined, then `Rake::Task[...].tap(&:reenable).invoke`).
- Mount `Sidekiq::Web` behind auth instead of Mission Control; run `bundle exec sidekiq` as its own service with `RAILS_MAX_THREADS >= SIDEKIQ_CONCURRENCY`; drop `SOLID_QUEUE_IN_PUMA`.

## Cache

Solid Cache (`config.cache_store = :solid_cache_store`) is the default — nothing to provision. For an in-memory cache: add the `redis` gem and set `config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }` in `config/environments/production.rb`. Works with Valkey.

## The admin dashboard

- **Single node (default):** the `spree_dashboard` gem serves the built dashboard at `/dashboard` (and an optional marketplace seller panel at `/sellers`) with SPA fallback. It serves the directory from `Spree::Dashboard.dist_path` or `SPREE_DASHBOARD_DIST_PATH` (seller panel: `SPREE_SELLER_PANEL_DIST_PATH`); unset → 404. The image build sets this up — same origin, no CORS, no API keys.
- **Static host / CDN:** `cd apps/dashboard && VITE_SPREE_API_URL=https://api.example.com pnpm build`, upload `dist/`, rewrite `/* → /index.html`, HTTPS on both sides (the refresh cookie is `SameSite=None; Secure`), and add the dashboard origin under **Settings → Allowed Origins**. `VITE_*` values are baked into the bundle — never put secrets there; one build per environment.
- API-only deployments can drop the `spree_dashboard` gem.

## File storage and CDN

- Uploads go through Active Storage. Local disk is the default and is lost on ephemeral platforms (Render, Heroku, Fargate, most K8s). Set `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` (+ `AWS_REGION`, `AWS_BUCKET`) or `CLOUDFLARE_ENDPOINT` + `CLOUDFLARE_ACCESS_KEY_ID`/`CLOUDFLARE_SECRET_ACCESS_KEY` (+ `CLOUDFLARE_BUCKET`); the template auto-detects the service. Other backends: standard `config/storage.yml`.
- Put a CDN in front of `/rails/active_storage/representations/` and `/assets`. With a separate CDN hostname, set `CDN_HOST`.

## Search

Default search is SQL (`Spree::SearchProvider::Database`). For large catalogs add Meilisearch:

```ruby
# Gemfile
gem "spree_meilisearch"
# config/initializers/spree.rb
Spree.search_provider = 'SpreeMeilisearch::SearchProvider'
```

Env: `MEILISEARCH_URL` (default `http://localhost:7700`), `MEILISEARCH_API_KEY`. Build the index after the first deploy and after provider config changes: `bin/rails spree:search:reindex` (`spree task search:reindex` locally).

## Observability

- **Errors:** set `SENTRY_DSN` (template ships `sentry-rails`).
- **Tracing:** add `gem 'spree_opentelemetry'` and set standard OTel vars — `OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT` (or `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`), optional `OTEL_TRACES_SAMPLER=parentbased_traceidratio` + `OTEL_TRACES_SAMPLER_ARG`. Dormant until an exporter var is set; `OTEL_SDK_DISABLED=true` always wins. Spans cover HTTP, SQL, jobs, every `Spree::Workflow` run/step/hook, event dispatch, webhook deliveries (W3C trace context propagated), and gateway calls. Span attributes carry no PII.
- **Sentry + OTel:** keep Sentry for errors and don't also set Sentry's `traces_sample_rate` (double instrumentation). To use Sentry as the trace backend, see the Sentry section of the observability doc (`sentry-opentelemetry`, `SpreeOpenTelemetry.install!` before `Sentry.init`, `OTEL_TRACES_EXPORTER=none`).
- **Health check:** `/up` (Rails built-in; it does not touch the DB).

## Platform notes

- **Render:** `create-spree-app` moves the starter's Blueprint to the project root as `render.yaml` and points every service's `dockerfilePath` (including the commented worker) at `./server/Dockerfile`, with the repo root as `dockerContext` — one web service + Postgres. The Blueprint generates `SECRET_KEY_BASE`, the three `ACTIVE_RECORD_ENCRYPTION_*` keys (copy them from the Environment tab into your secret manager) and `MISSION_CONTROL_PASSWORD` (user `jobs`). Uncomment the worker block for split mode. Filesystem is ephemeral — configure S3/R2.
- **AWS:** single EC2 + RDS, or ECS Fargate (web and `bin/jobs` as separate services from one image).
- **Kubernetes:** one Deployment for web, optionally one for `bin/jobs`; Secrets for `SECRET_KEY_BASE`/`DATABASE_URL`/storage creds; liveness on `/up`; migrations either via the entrypoint (server command) or a Job/init container running `db:migrate`.
- **VPS:** `docker compose` with `web` + `postgres` is a complete deployment; add Caddy/nginx/Traefik for TLS.

## Common problems

| Symptom | Cause / fix |
|---|---|
| Image/attachment URLs point at `https://localhost/...` | `RAILS_HOST` (or `CDN_HOST`) unset |
| `/dashboard` returns 404 | `spree_dashboard` gem missing or `SPREE_DASHBOARD_DIST_PATH`/`Spree::Dashboard.dist_path` unset (custom image built without the dashboard stage) |
| Static-host dashboard can't log in / CORS errors | Origin not in **Settings → Allowed Origins**, or not HTTPS on both sides |
| `/jobs` always 401 | `MISSION_CONTROL_USER`/`PASSWORD` unset in production |
| Jobs never run after splitting | Worker not running `bin/jobs`, or `SOLID_QUEUE_IN_PUMA=false` set on web with no worker |
| Jobs run on Solid Queue but not on Sidekiq | Queue missing from `sidekiq.yml` (no catch-all) |
| `ActiveRecord::ConnectionTimeoutError` under load | Pool smaller than `RAILS_MAX_THREADS + JOB_THREADS` |
| Uploads vanish after redeploy | Local disk storage on an ephemeral filesystem |
| No emails in production | `SMTP_HOST` unset |
| Search returns nothing on Meilisearch | Index never built — run `spree:search:reindex` |
| Checkout stock held forever / sellers never paid | `recurring.yml` entries missing or not in the `production:` key, or you moved to Sidekiq without porting them |
| Store data looks half-migrated after a gem bump | `spree:upgrade` not run |
| Boot log: `[Spree] Active Record encryption is not fully configured` | `ACTIVE_RECORD_ENCRYPTION_*` unset (or not read into `config.active_record.encryption`) — secrets are being stored in plaintext |
| Webhook secrets / gateway customers unreadable after a deploy | Encryption keys changed or missing on this environment, or encryption enabled without first encrypting existing rows (see `spree-security`) |

## Where to read further

- `node_modules/@spree/docs/dist/developer/deployment/` — `quickstart.md`, `docker.md`, `environment_variables.md`, `background_jobs.md`, `caching.md`, `database.md`, `assets.md`, `cdn.md`, `emails.md`, `render.md`, `aws.md`, `aws_ecs.md`
- `node_modules/@spree/docs/dist/developer/dashboard/deployment.md`
- `node_modules/@spree/docs/dist/developer/providers/observability.md`
- https://spreecommerce.org/docs/developer/deployment/quickstart
- Related skills: `spree-performance` (queue and worker tuning), `spree-upgrade` (release-phase upgrades), `spree-security` (secrets, encryption keys), `spree-multi-tenant` (root domain, cookies, hosts)
