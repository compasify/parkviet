#!/usr/bin/env bash
# Installs or updates ParkViet on a shop's mini PC (Ubuntu/Debian with Docker
# Engine 28.0.1+ and the compose plugin). Run from a checkout of the
# repository, as a user in the `docker` group:
#
#   deploy/scripts/install-lan.sh                       # first install: asks for the address
#   deploy/scripts/install-lan.sh http://192.168.1.10   # or pass it
#   deploy/scripts/install-lan.sh --update              # rebuild and restart after `git pull`
#
# It never prints secrets. On first install it writes deploy/.env.prod with
# fresh ones; keep a copy of that file off the machine.
set -euo pipefail

cd "$(dirname "$0")/.."
ENV_FILE=.env.prod
COMPOSE=(docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE")

die() { echo "error: $*" >&2; exit 1; }

command -v docker >/dev/null || die "Docker is not installed. See https://docs.docker.com/engine/install/."
docker compose version >/dev/null 2>&1 || die "The docker compose plugin is missing."
command -v openssl >/dev/null || die "openssl is needed to generate secrets."

# Sets KEY=value in the env file without echoing the value.
set_env() {
  local key="$1" value="$2"
  if grep -q "^${key}=" "$ENV_FILE"; then
    # `|` is not in any value written here (hex, base64 without `|`, URLs).
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >>"$ENV_FILE"
  fi
}

first_install() {
  local url="${1:-}"
  if [ -z "$url" ]; then
    local guess
    guess=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -E '^(10|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\.' | head -n1 || true)
    read -r -p "Address devices will use [http://${guess:-192.168.1.10}]: " url
    url="${url:-http://${guess:-192.168.1.10}}"
  fi
  local hostport="${url#*://}"
  hostport="${hostport%%/*}"
  local host="${hostport%%:*}"
  case "$url" in
    http://*) mode=none; site="http://" ;;
    https://*)
      # A private address or .local name gets Caddy's own CA; a domain gets Let's Encrypt.
      if [[ "$host" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.) || "$host" == *.local ]]; then
        mode=internal; site="$url"
      else
        # Caddy takes "host" or "host:port"; a non-443 port stays in the site.
        mode=public; site="$hostport"
      fi
      ;;
    *) die "The address must start with http:// or https://" ;;
  esac

  cp .env.prod.example "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  set_env POS_PUBLIC_BASE_URL "$url"
  set_env POS_TLS_MODE "$mode"
  set_env POS_CADDY_SITE "$site"
  set_env SECRET_KEY_BASE "$(openssl rand -hex 64)"
  set_env POSTGRES_PASSWORD "$(openssl rand -hex 24)"
  set_env ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY "$(openssl rand -base64 32 | tr -d '\n')"
  set_env ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY "$(openssl rand -base64 32 | tr -d '\n')"
  set_env ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT "$(openssl rand -base64 32 | tr -d '\n')"
  set_env MISSION_CONTROL_PASSWORD "$(openssl rand -hex 16)"
  echo "Wrote $ENV_FILE (mode 600). Copy it somewhere safe: without its encryption keys, encrypted data in a restored backup cannot be read."
}

if [ "${1:-}" = "--update" ]; then
  [ -f "$ENV_FILE" ] || die "$ENV_FILE is missing; run without --update first."
elif [ ! -f "$ENV_FILE" ]; then
  first_install "${1:-}"
else
  echo "$ENV_FILE exists; keeping it. Edit it by hand to change settings."
fi

mkdir -p backups
version=$(git describe --tags --always --dirty 2>/dev/null || echo development)
set_env PARKVIET_VERSION "$version"

echo "Building ParkViet ${version} (the first build takes a while)..."
"${COMPOSE[@]}" build web
"${COMPOSE[@]}" up -d postgres web caddy backup

echo "Waiting for the app to answer /up..."
for _ in $(seq 1 60); do
  if "${COMPOSE[@]}" exec -T web curl -fsS http://localhost:3000/up >/dev/null 2>&1; then
    url=$(grep '^POS_PUBLIC_BASE_URL=' "$ENV_FILE" | cut -d= -f2-)
    echo "ParkViet is running at ${url}"
    echo "  counter:            ${url}/pos/"
    echo "  POS administration: ${url}/pos-admin/"
    echo "  Spree dashboard:    ${url}/dashboard"
    echo "First install: get the one-time admin setup link with"
    echo "  docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env.prod exec web bin/rails spree:setup:token"
    exit 0
  fi
  sleep 5
done
die "The app did not become healthy. Check: docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env.prod logs web"
