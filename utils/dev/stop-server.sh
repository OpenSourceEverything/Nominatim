  #!/usr/bin/env bash
  set -euo pipefail
  . ./.env.nominatim
  PIDFILE="$PROJ/.nominatim.pid"
  port_kill()
  {
    # kill whatever listens on $PORT (best effort)
    for p in $(lsof -t -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true)
    do kill "$p" 2>/dev/null || true; done
  }
  if [ ! -f "$PIDFILE" ]; then
    port_kill; echo "stopped (no pidfile)"; exit 0
  fi
  PID="$(cat "$PIDFILE")" || true
  if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    PGID="$(ps -o pgid= -p "$PID" | tr -d ' ')"
    if [ -n "$PGID" ]; then kill -TERM -"$PGID" 2>/dev/null || true; fi
    for i in $(seq 1 10); do
      kill -0 "$PID" 2>/dev/null || { rm -f "$PIDFILE"; break; }
      sleep 1
    done
    kill -9 -"$PGID" 2>/dev/null || true
    rm -f "$PIDFILE" 2>/dev/null || true
  fi
  port_kill
  echo "stopped"