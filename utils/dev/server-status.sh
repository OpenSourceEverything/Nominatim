  #!/usr/bin/env bash
  set -euo pipefail
  . ./.env.nominatim
  PIDFILE="$PROJ/.nominatim.pid"
  want=""
  if [ -f "$PIDFILE" ]; then want="$(cat "$PIDFILE")"; fi
  have="$(lsof -t -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true)"
  if [ -n "$have" ]; then
    echo "listening on 127.0.0.1:$PORT pid(s): $have"
    if [ -n "$want" ]; then echo "pidfile: $want"; fi
    echo "log: $PROJ/nominatim.log"; exit 0
  fi
  echo "not running"; exit 1