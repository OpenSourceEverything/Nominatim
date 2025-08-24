#!/usr/bin/env bash
set -euo pipefail
. ./.env.nominatim
. "$VENV/bin/activate"

url="${1:-}"
if [ -z "$url" ]; then
  echo "usage: add_region.sh <pbf_url>"
  exit 1
fi

cd "$PROJ"
f="$(basename "$url" .osm.pbf).pbf"
wget -O "$f" "$url"

nominatim add-data --project-dir "$PROJ" --file "$PWD/$f"
nominatim index    --project-dir "$PROJ"

echo "added $f"