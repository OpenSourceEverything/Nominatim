#!/usr/bin/env bash
set -euo pipefail

# verbose, clear logs
say() { printf '%s %s\n' "==>" "$*"; }
on_err() { echo "error on line $1"; exit 1; }
trap 'on_err $LINENO' ERR

say "load env"
. ./.env.nominatim

say "env vars"
printf 'REPO=%s\nPROJ=%s\nVENV=%s\n' "$REPO" "$PROJ" "$VENV"

say "apt update"
sudo apt update -y -qq

say "apt install core deps"
sudo apt install -y postgresql postgresql-postgis osm2pgsql \
  python3-venv python3-pip git wget

say "ensure postgres role for user $USER"
if ! sudo -u postgres psql -tAc \
  "select 1 from pg_roles where rolname='$USER'" | grep -q 1
then
  sudo -u postgres createuser -s "$USER"
else
  say "role exists, ok"
fi

say "ensure repo dir parent"
mkdir -p "$(dirname "$REPO")"

say "clone repo if missing"
if [ ! -d "$REPO/.git" ]; then
  git clone "https://github.com/<your-fork>/Nominatim.git" "$REPO"
else
  say "repo exists, pulling"
  git -C "$REPO" pull --ff-only || true
fi

say "create venv if missing"
if [ ! -f "$VENV/bin/activate" ]; then
  python3 -m venv "$VENV"
fi

say "activate venv"
. "$VENV/bin/activate"
python -V
pip -V

say "pip install deps"
pip install -U pip osmium psutil 'psycopg[binary]' PyICU

say "write shim $VENV/bin/nominatim"
cat > "$VENV/bin/nominatim" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
: "${VENV:=$HOME/nominatim-dev-venv}"
: "${REPO:=$HOME/repos/Nominatim}"
. "$VENV/bin/activate"
exec python3 "$REPO/nominatim-cli.py" "$@"
EOF
chmod +x "$VENV/bin/nominatim"

say "ensure project dir and db env"
mkdir -p "$PROJ"
printf "DB_NAME=%s\n" "$DB_NAME" > "$PROJ/.env"

say "report versions and paths"
printf 'python=%s\n' "$(python -V 2>&1)"
printf 'pip=%s\n' "$(pip -V)"
printf 'nominatim shim=%s\n' "$VENV/bin/nominatim"
printf 'repo head=%s\n' "$(git -C "$REPO" rev-parse --short HEAD || true)"

say "setup done"