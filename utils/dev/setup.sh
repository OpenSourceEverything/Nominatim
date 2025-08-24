#!/usr/bin/env bash
set -euo pipefail
. ./.env.nominatim

sudo apt update
sudo apt install -y postgresql postgresql-postgis osm2pgsql \
  python3-venv python3-pip git wget
sudo -u postgres createuser -s "$USER"

mkdir -p "$(dirname "$REPO")"
if [ ! -d "$REPO/.git" ]; then
  git clone https://github.com/<your-fork>/Nominatim.git "$REPO"
fi

python3 -m venv "$VENV"
. "$VENV/bin/activate"
pip install -U pip osmium psutil 'psycopg[binary]' PyICU

# shim: $VENV/bin/nominatim
cat > "$VENV/bin/nominatim" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
VENV="$HOME/nominatim-dev-venv"
REPO="$HOME/repos/Nominatim"
. "$VENV/bin/activate"
exec python3 "$REPO/nominatim-cli.py" "$@"
EOF
chmod +x "$VENV/bin/nominatim"

mkdir -p "$PROJ"
printf "DB_NAME=%s\n" "$DB_NAME" > "$PROJ/.env"

echo "setup done"