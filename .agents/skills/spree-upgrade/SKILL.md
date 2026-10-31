---
name: spree-upgrade
description: Use when the user wants to upgrade Spree to a newer version, or asks how the upgrade machinery works. Common phrasings include "upgrade Spree", "bump Spree", "how do I upgrade", "what's the upgrade process", "run the Spree upgrade", "spree upgrade --plan", "rake spree:upgrade", "re-run one upgrade step", "upgrade in production / release phase". Covers the version-agnostic flow for Spree 6 projects — the `spree upgrade` CLI, the `rake spree:upgrade` task and its manifests, retrying single steps, and running backfills in production. For the Spree 5.x → 6.0 major hop, also load spree-upgrade-5-to-6.
---

# Upgrading Spree

Every Spree upgrade is the same three stages:

1. **Bump the gems** — `bundle update` the `spree*` gems.
2. **Migrate the schema** — copy new migrations out of the gems (`spree:install:migrations`) and run `db:migrate`.
3. **Backfill data** — `rake spree:upgrade` runs the version-specific data tasks listed in the upgrade manifests shipped inside `spree_core`.

Then a fourth, manual stage: **review the upgrade guide** for your hop (behavior changes, config moves, code that needs editing). The rake-runnable part never covers everything.

> **Going from 5.x to 6.0?** That's a major, breaking hop with preconditions (you must be on 5.6 first, Rails 8.1, Gemfile swaps, roles-as-data). Read the **spree-upgrade-5-to-6** skill before starting.

## Pick your flavor

| Project | How you run it |
|---|---|
| `create-spree-app` (Docker + `@spree/cli`, Rails app in `server/` — older projects: `backend/`) | `spree upgrade` |
| Classic Rails app with Spree gems at the repo root (no Docker/CLI) | the native commands below |
| Production (either flavor) | your deploy pipeline + `bundle exec rake spree:upgrade` |

### CLI (create-spree-app)

```bash
spree upgrade --plan            # list the backfill steps a run would execute; runs nothing
spree upgrade                   # bundle update spree* → install migrations + db:migrate → rake spree:upgrade
```

`spree upgrade` prompts before `bundle update` and before migrations (answer No to skip one). `--yes` skips the prompts for non-interactive use. The rake backfills always run.

It needs the **ejected** dev stack. Fresh projects run the prebuilt `ghcr.io/spree/spree` image with no source bind mount, so `bundle update` inside it can't touch your `server/Gemfile.lock` and copied migrations never land in `server/db/migrate/`. Run `spree eject` first (switches to the build-from-source compose), then upgrade.

The CLI refuses to run in a monorepo edge project (`SPREE_PATH` set in `.env`) — use the `pnpm server:*` scripts from the monorepo root there.

### Native (classic Rails app, or no CLI)

```bash
bundle update spree spree_core spree_api spree_emails   # + spree_dashboard and any spree_* extensions you use
bin/rails spree:install:migrations db:migrate
DRY_RUN=1 bundle exec rake spree:upgrade                  # plan
bundle exec rake spree:upgrade                            # run the backfills
```

CLI flags map 1:1 to env vars on the rake task: `--plan` → `DRY_RUN=1`, `--step <id>` → `STEP=<id>`, `--to <x.y>` → `TO=<x.y>`.

## How `rake spree:upgrade` works

- Manifests live in the gem at `spree_core/lib/spree/upgrades/<from>_to_<to>/manifest.yml` (dots become underscores: `5_6_to_6_0`). Each lists ordered steps: `id`, `name`, `task` (a rake task), `notes`, and optionally `optional: true` (skipped when the task isn't defined, e.g. a provider gem you don't have).
- A normal run walks **every manifest whose `to` is ≤ the installed minor version**, oldest first. An app that skipped a backfill two versions ago catches up automatically.
- Every step must be **idempotent** — re-running the whole task on an already-upgraded app is a safe no-op. This is what makes it safe as a release-phase command.
- Manifests only contain data backfills. `bundle update`, migrations, cron/recurring jobs and code changes are never in them.

List what the installed gem ships:

```bash
spree exec sh -c 'ls "$(bundle info spree_core --path)/lib/spree/upgrades/"'
# classic: ls "$(bundle info spree_core --path)/lib/spree/upgrades/"
```

## Plan first

```bash
spree upgrade --plan                   # or: DRY_RUN=1 bundle exec rake spree:upgrade
```

Prints every step (id, rake task, notes) that a real run would execute, in order — plan mode uses the same manifest selection as a real run (every manifest whose `to` ≤ the installed minor, or ≤ `--to` when given). Nothing is executed and the bundle/migrate pre-steps are skipped.

The plan reads manifests **from the installed gem**, so bump the gems first — a 5.6 bundle doesn't contain the 5.6 → 6.0 manifest.

## Retry one step

After a partial failure, fix the cause and re-run only that step (skips bundle + migrate):

```bash
spree upgrade --step migrate_returns        # or: STEP=migrate_returns bundle exec rake spree:upgrade
```

Step ids come from the plan output. If the same id exists in two manifests the task aborts and asks for `TO=` to disambiguate. Some tasks take their own env knobs (`BATCH_SIZE`, `SKIP_INVALID_ROWS=true`, …) — they're documented in each step's `notes`; pass them the same way (`spree rake spree:upgrade STEP=… BATCH_SIZE=200`, or `spree exec env BATCH_SIZE=200 bin/rake …`).

You can also invoke the underlying task directly — `spree rake <task>` / `bundle exec rake <task>` — which is handy for tasks that aren't in any manifest.

## Cap the version

```bash
spree upgrade --to 5.6
```

Eligible manifests become those whose `to` ≤ the cap. Useful when you're landing on an intermediate minor before the next hop (5.x apps must land on 5.6 before going to 6.0).

## What it does not do

- **Extension upgrades.** `spree upgrade` bumps every installed `spree*` gem (it lists them with `bundle list --name-only` inside the container), but each extension's own migrations, install generators and breaking changes are yours to run — check its CHANGELOG. Extensions must have a release compatible with the target Spree version or `bundle update` won't resolve.
- **Recurring jobs / config.** New scheduled jobs (Solid Queue `config/recurring.yml`, or your Sidekiq/cron setup), moved settings and new env vars are listed in the upgrade guide, not the manifest.
- **Your code.** Decorators, subscribers, workflow hooks, dashboard plugins and storefront code referencing renamed or removed APIs have to be audited by hand. The `/spree:audit-upgrade` command in this plugin does a read-only readiness pass.
- **SDKs.** Frontend packages (`@spree/sdk`, `@spree/admin-sdk`, `@spree/dashboard`) are bumped through your own package manager — the CLI prints the `apps/storefront` `@spree/sdk` version in its "Next steps" panel as a reminder.

## In production

Don't run `spree upgrade` against production — it's a dev CLI. Your deploy already does `bundle install` and `db:migrate` (the starter's Docker entrypoint runs `bin/rails db:prepare` on boot). Add the backfills as one more command:

```bash
bundle exec rake spree:upgrade
```

Wire it as a release-phase command (Heroku), pre-deploy command (Render), init container / Job (Kubernetes) or post-deploy hook (Kamal, Capistrano). Because every step is idempotent, running it on every deploy is safe and cheap once the data is migrated.

Order matters: **migrate → backfill → serve new code**. Some steps are safety nets for the migration and some must run before later migrations (they say so in their notes). For big hops, run the backfills in a maintenance window or against a restored copy first to measure duration — several tasks honor `BATCH_SIZE`.

## Checklist

1. Back up the database.
2. Read the upgrade guide for the hop: `node_modules/@spree/docs/dist/developer/upgrades/<from>-to-<to>.md` or https://spreecommerce.org/docs/developer/upgrades.
3. Bump gems (and extensions), run migrations.
4. `spree upgrade --plan` → read every step's notes.
5. Run the backfills; re-run failed steps with `--step`.
6. Do the manual items from the guide; run your test suite; bump SDKs.
7. Ship with `bundle exec rake spree:upgrade` in the release phase.

## Gotchas

- **`--plan` printing nothing (or only old manifests)** means the gems aren't bumped yet — the plan comes from the installed `spree_core`.
- **`bundle update` fails in the container** → you're on the prebuilt image; `spree eject` first, or the bundle is out of sync (`spree bundle install`).
- **A step aborts on purpose.** Several 6.0 tasks refuse to continue on data they can't convert faithfully (e.g. `migrate_users_to_customers`, `migrate_returns`) and print the offending ids plus the env var that overrides. Read the message; don't blindly re-run.
- **Never skip ahead.** Manifests assume their `from` version's schema. Jumping minors is fine (the walk catches up); skipping a required landing version (5.6 before 6.0) is not.

## Where to read further

- `node_modules/@spree/docs/dist/developer/upgrades/` — per-hop upgrade guides
- `node_modules/@spree/docs/dist/developer/cli/quickstart.md` — `spree upgrade` reference
- https://spreecommerce.org/docs/developer/upgrades
- Related skills: **spree-upgrade-5-to-6**, **spree-cli**, **spree-deployment**, **spree-extensions**
