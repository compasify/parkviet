#!/usr/bin/env bash
# Restores a ParkViet backup. Run on the server, from deploy/.
#
#   scripts/restore.sh --drill backups/parkviet-20261111-023000.dump
#       Restores into a scratch database, checks it, and drops it. The live
#       database is untouched. Do this every quarter.
#   scripts/restore.sh --replace backups/parkviet-20261111-023000.dump
#       Replaces the live database: stops the app, takes a safety dump of the
#       current data, restores the file, starts the app again.
set -Eeuo pipefail
umask 077

cd "$(dirname "$0")/.."
COMPOSE=(docker compose -f docker-compose.prod.yml --env-file .env.prod)
DB=parkviet_production
DRILL_DB=parkviet_restore_drill

usage() {
  echo "usage: $0 --drill|--replace <backups/parkviet-....dump>" >&2
  exit 2
}

[ $# -eq 2 ] || usage
mode="$1"
file="$2"
[ -f "$file" ] || { echo "No such file: $file" >&2; exit 1; }

psql() {
  "${COMPOSE[@]}" exec -T postgres psql -v ON_ERROR_STOP=1 -U parkviet -d "$1" -tA -c "$2"
}

# pg_restore runs inside the postgres container and reads the dump on stdin.
restore_into() {
  "${COMPOSE[@]}" exec -T postgres pg_restore --no-owner --exit-on-error -U parkviet -d "$1" <"${2:-$file}"
}

# A restored database is usable when its schema version and core tables are there.
check() {
  local version stores orders
  version=$(psql "$1" "SELECT max(version) FROM schema_migrations")
  stores=$(psql "$1" "SELECT count(*) FROM spree_stores")
  orders=$(psql "$1" "SELECT count(*) FROM spree_orders")
  echo "schema ${version}, ${stores} store(s), ${orders} order(s)"
  [ -n "$version" ] && [ "$stores" -gt 0 ]
}

case "$mode" in
  --drill)
    psql postgres "DROP DATABASE IF EXISTS ${DRILL_DB}" >/dev/null
    psql postgres "CREATE DATABASE ${DRILL_DB}" >/dev/null
    trap 'psql postgres "DROP DATABASE IF EXISTS ${DRILL_DB}" >/dev/null' EXIT
    started=$(date +%s)
    restore_into "$DRILL_DB"
    if check "$DRILL_DB"; then
      echo "Restore drill passed in $(( $(date +%s) - started ))s: $(basename "$file")"
    else
      echo "Restore drill FAILED: the restored database is missing data." >&2
      exit 1
    fi
    ;;
  --replace)
    read -r -p "Replace the live database with $(basename "$file")? Type RESTORE: " answer
    [ "$answer" = "RESTORE" ] || { echo "Cancelled."; exit 1; }
    # Restore from a private copy: nothing that touches backups/ while this
    # runs can take the source away once the live database is gone.
    work=$(mktemp)
    trap 'rm -f "$work"' EXIT
    cp "$file" "$work"
    "${COMPOSE[@]}" exec -T postgres pg_restore --list <"$work" >/dev/null ||
      { echo "Not a readable pg_dump archive: $file" >&2; exit 1; }
    "${COMPOSE[@]}" stop web
    # --no-prune: the safety dump must not delete older dumps, the source included.
    out=$("${COMPOSE[@]}" run --rm -T --no-deps --entrypoint /bin/sh backup /scripts/backup.sh once --no-prune) || out=""
    echo "$out"
    safety=$(printf '%s\n' "$out" | sed -n 's/.*wrote \(parkviet-[0-9-]*\.dump\).*/\1/p' | tail -n 1)
    if [ -z "$safety" ]; then
      echo "The safety dump failed. The live database is untouched; starting the app again." >&2
      "${COMPOSE[@]}" start web
      exit 1
    fi
    on_failure() {
      trap - ERR
      echo "Restore FAILED after the live database was dropped. The app is stopped." >&2
      echo "The previous data is in backups/${safety}. To put it back:" >&2
      echo "  scripts/restore.sh --replace backups/${safety}" >&2
    }
    trap on_failure ERR
    psql postgres "DROP DATABASE IF EXISTS ${DB} WITH (FORCE)" >/dev/null
    psql postgres "CREATE DATABASE ${DB}" >/dev/null
    restore_into "$DB" "$work"
    check "$DB"
    trap - ERR
    "${COMPOSE[@]}" start web
    echo "Restored $(basename "$file"). The previous data is in backups/${safety}."
    ;;
  *)
    usage
    ;;
esac
