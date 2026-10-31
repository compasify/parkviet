# Spree 6 deployment environment variables

Read by the project template (`server/config/*`) and Spree gems. Verify against your own `server/config` — generated projects can drift.

## Core

| Variable | Default | Notes |
|---|---|---|
| `DATABASE_URL` | — | Required. `postgres://`, `mysql2://`, or `sqlite3:` URL |
| `SECRET_KEY_BASE` | — | Required. `openssl rand -hex 64`. Stable per environment |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY` | — | **Required in every environment** (all three). Active Record encryption (non-deterministic attributes — OAuth identity tokens). Starter `config/application.rb` reads it, falling back to credentials `active_record_encryption.primary_key` |
| `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY` | — | Deterministic attributes Spree looks up by (webhook signing secrets, gateway customer IDs). Can't be rotated by Rails |
| `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` | — | Set all three together (`spree encryption init --print` / `bin/rails db:encryption:init`). Unset → plaintext + boot warning. Never change once data is encrypted |
| `RAILS_ENV` | `production` | |
| `RAILS_LOG_LEVEL` | `info` | Logs go to STDOUT (lograge single-line request logs) |
| `RAILS_HOST` | — | Public host, no protocol, optional port. Used for `default_url_options`, email links, webhook payloads, attachment URLs. Render fallback: `RENDER_EXTERNAL_HOSTNAME` |
| `CDN_HOST` | — | Sets `config.asset_host` and `Spree.cdn_host`. Host only |
| `RAILS_FORCE_SSL` | `true` | Redirect to HTTPS, secure cookies |
| `RAILS_ASSUME_SSL` | `true` | Trust TLS-terminating proxy. Generated URLs use `http` only when both SSL vars are `false` |

## Web server (Puma)

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `3000` | |
| `RAILS_MAX_THREADS` | `3` | Request threads per process |
| `WEB_CONCURRENCY` | `1` | Processes; `auto` = one per core (~1 GB RAM each) |

## Background jobs

| Variable | Default | Notes |
|---|---|---|
| `SOLID_QUEUE_IN_PUMA` | `true` | `false` on web when a `bin/jobs` worker runs |
| `JOB_THREADS` | `3` | Solid Queue worker threads (also feeds DB pool size) |
| `JOB_CONCURRENCY` | `1` | Solid Queue worker processes |
| `SPREE_IMPORT_JOB_CONCURRENCY` | 75% of `JOB_THREADS` (min 1) | Concurrent import group jobs per import; `0` disables. Read by the enqueuing process (set on web when split). Solid Queue only |
| `MISSION_CONTROL_USER` / `MISSION_CONTROL_PASSWORD` | dev: `spree` / `spree123` | Required in production for `/jobs` |
| `REDIS_URL` | — | Only when you swap to Sidekiq or Redis cache |
| `SIDEKIQ_CONCURRENCY` | `10` | Only with the Sidekiq swap (value from your `sidekiq.yml`) |

## Email

| Variable | Default | Notes |
|---|---|---|
| `SMTP_HOST` | — | Enables SMTP; unset in production = no delivery. Dev compose sets `SMTP_HOST=mailpit`, `SMTP_PORT=1025` (Mailpit's SMTP port); read captured mail in its web UI at `http://localhost:8025` |
| `SMTP_PORT` | `587` | |
| `SMTP_USERNAME` / `SMTP_PASSWORD` | — | SMTP auth only requested when username is set |
| `SMTP_FROM_ADDRESS` | — | Default sender |

## File storage

| Variable | Default | Notes |
|---|---|---|
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | — | Presence switches Active Storage to S3 |
| `AWS_REGION` | — | |
| `AWS_BUCKET` | `spree-production` | |
| `CLOUDFLARE_ENDPOINT` | — | R2, needs the two keys below too |
| `CLOUDFLARE_ACCESS_KEY_ID` / `CLOUDFLARE_SECRET_ACCESS_KEY` | — | |
| `CLOUDFLARE_BUCKET` | `spree-production` | |

## Dashboard (spree_dashboard gem)

| Variable | Default | Notes |
|---|---|---|
| `SPREE_DASHBOARD_DIST_PATH` | set by image build | Directory served at `/dashboard`; unset → 404. Alternative: `Spree::Dashboard.dist_path =` |
| `SPREE_SELLER_PANEL_DIST_PATH` | — | Marketplace seller panel at `/sellers` |
| `VITE_SPREE_API_URL` | unset (same origin) | Build-time, static-host dashboards only |
| `VITE_BASE_PATH` | `/dashboard/` in the image | Build-time |

## Search

| Variable | Default | Notes |
|---|---|---|
| `MEILISEARCH_URL` | `http://localhost:7700` | `spree_meilisearch` gem |
| `MEILISEARCH_API_KEY` | — | Needed when Meilisearch runs with a master key |

## Observability

| Variable | Default | Notes |
|---|---|---|
| `SENTRY_DSN` | — | Enables Sentry error reporting |
| `OTEL_EXPORTER_OTLP_ENDPOINT` / `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` | — | Presence activates `spree_opentelemetry` |
| `OTEL_TRACES_EXPORTER` | `otlp` | Non-`none` value also activates; `none` when Sentry provides the exporter |
| `OTEL_SERVICE_NAME` | — | e.g. `spree` |
| `OTEL_TRACES_SAMPLER` / `OTEL_TRACES_SAMPLER_ARG` | — | e.g. `parentbased_traceidratio` / `0.1` |
| `OTEL_SDK_DISABLED` | — | `true` = kill switch, always wins |
