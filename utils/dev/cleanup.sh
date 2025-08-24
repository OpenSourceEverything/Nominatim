#!/usr/bin/env bash
set -euo pipefail
. ./.env.nominatim
dropdb "$DB_NAME" || true
rm -rf "$PROJ"
echo "cleaned $DB_NAME and $PROJ"