#!/bin/sh
# Nightly PostgreSQL dumps for the ParkViet stack. Runs inside the `backup`
# service (postgres:18-alpine) of deploy/docker-compose.prod.yml.
#
#   backup.sh once            one dump now
#   backup.sh once --no-prune one dump now, nothing removed (restore safety dump)
#   backup.sh loop            one dump per day after BACKUP_AT (HHMM, local to TZ)
#
# Connection comes from PGHOST, PGUSER, PGPASSWORD, PGDATABASE. Dumps are
# custom-format (`pg_dump -Fc`), named parkviet-<YYYYmmdd>-<HHMMSS>.dump, and
# only the newest BACKUP_KEEP are kept. The system status page reads the
# newest file's time from the same folder.
set -eu
# Dumps hold every customer and payment record: owner-only files.
umask 077

BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_KEEP="${BACKUP_KEEP:-14}"
BACKUP_AT="${BACKUP_AT:-0230}"

log() {
  echo "[backup] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

dump_once() {
  mkdir -p "$BACKUP_DIR"
  name="parkviet-$(date +%Y%m%d-%H%M%S).dump"
  partial="$BACKUP_DIR/.$name.partial"
  # Written beside the target, checked, then renamed: a dump cut off by a
  # power loss never looks like a good backup.
  # Explicit checks: `set -e` does not apply inside `dump_once || ...`.
  if ! pg_dump --format=custom --no-owner --file="$partial" || ! pg_restore --list "$partial" >/dev/null; then
    rm -f "$partial"
    log "dump failed"
    return 1
  fi
  mv "$partial" "$BACKUP_DIR/$name" || return 1
  log "wrote $name ($(du -h "$BACKUP_DIR/$name" | cut -f1))"
  [ "${NO_PRUNE:-}" = 1 ] || prune
}

prune() {
  # Newest first; everything after the first BACKUP_KEEP goes.
  ls -1t "$BACKUP_DIR"/parkviet-*.dump 2>/dev/null | tail -n +"$((BACKUP_KEEP + 1))" | while read -r old; do
    rm -f "$old"
    log "removed $(basename "$old")"
  done
}

done_today() {
  ls "$BACKUP_DIR"/parkviet-"$(date +%Y%m%d)"-*.dump >/dev/null 2>&1
}

case "${1:-once}" in
  once)
    case "${2:-}" in
      "") ;;
      --no-prune) NO_PRUNE=1 ;;
      *) echo "usage: $0 once [--no-prune]" >&2; exit 2 ;;
    esac
    dump_once
    ;;
  loop)
    log "nightly after $BACKUP_AT, keeping $BACKUP_KEEP, in $BACKUP_DIR"
    while true; do
      if [ "$(date +%H%M)" -ge "$BACKUP_AT" ] && ! done_today; then
        # A failed dump is logged and retried on the next pass.
        dump_once || log "retrying in 5 minutes"
      fi
      sleep 300
    done
    ;;
  *)
    echo "usage: $0 [once|loop]" >&2
    exit 2
    ;;
esac
