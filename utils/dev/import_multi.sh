#!/usr/bin/env bash
set -euo pipefail
. ./.env.nominatim
. "$VENV/bin/activate"

mkdir -p "$PROJ"
cd "$PROJ"

files=()
for url in $PBF_URLS; do
  f="$(basename "$url" .osm.pbf).pbf"
  wget -O "$f" "$url"
  files+=("$PWD/$f")
done

cmd=(nominatim import --project-dir "$PROJ" -j "$JOBS")
for f in "${files[@]}"; do
  cmd+=(--osm-file "$f")
done
"${cmd[@]}"

echo "import done"