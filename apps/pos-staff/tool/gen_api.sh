#!/usr/bin/env bash
# Regenerates packages/pos_api from server/openapi/pos-staff.yaml.
# Needs Node (npx), Java 11+ and the Flutter SDK on PATH.
# CI runs this and fails when the committed client differs.
set -euo pipefail

cd "$(dirname "$0")/.."

CLI_VERSION=2.42.1
OUT=packages/pos_api

# Keep the files that are ours, drop everything the generator owns, so a
# schema removed from the contract also disappears from the client.
find "$OUT" -mindepth 1 -maxdepth 1 \
  ! -name '.openapi-generator-ignore' \
  ! -name '.gitignore' \
  ! -name 'pubspec.lock' \
  -exec rm -rf {} +

npx --yes "@openapitools/openapi-generator-cli@${CLI_VERSION}" generate \
  -i ../../server/openapi/pos-staff.yaml \
  -c tool/openapi-config.yaml \
  -o "$OUT"

(
  cd "$OUT"
  # A schema mapped to JsonObject still counts as a model to the generator,
  # which merges it into a nested builder. JsonObject has no builder, so the
  # value is assigned. No template flag tells the two apart.
  perl -0pi -e 's/(as JsonObject\??;\n(?:\s*if \(valueDes == null\) continue;\n)?\s*result\.\w+)\.replace\(valueDes\);/$1 = valueDes;/g' lib/src/model/*.dart
  if [ -f pubspec.lock ]; then dart pub get --enforce-lockfile; else dart pub get; fi
  dart run build_runner build
  dart format lib >/dev/null
)
