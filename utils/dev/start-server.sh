#!/usr/bin/env bash
set -euo pipefail
. ./.env.nominatim
. "$VENV/bin/activate"
PIDFILE="$PROJ/.nominatim.pid"
LOGFILE="$PROJ/nominatim.log"
mkdir -p "$PROJ"
# block if port busy
if ss -ltn '( sport = :'"$PORT"' )' | grep -q LISTEN; then
  echo "port $PORT busy"
  ss -ltnp 'sport = :'"$PORT"''
  exit 1
fi
# skip if pidfile alive
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "already running pid $(cat "$PIDFILE")"
  exit 0
fi
cmd=(nominatim serve --project-dir "$PROJ" --server "127.0.0.1:$PORT")
nohup "${cmd[@]}" >>"$LOGFILE" 2>&1 &
PID="$!"; echo "$PID" >"$PIDFILE"
echo "started pid $PID, log $LOGFILE"
# wait ready (quiet)
for i in $(seq 1 60); do
  if { exec 3<>"/dev/tcp/127.0.0.1/$PORT"; } 2>/dev/null; then
    exec 3>&-
    echo "up on 127.0.0.1:$PORT"
    exit 0
  fi
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "server died. last log:"; tail -n 60 "$LOGFILE"
    exit 1
  fi
  sleep 1
done
echo "warning: port not seen yet"
exit 0
