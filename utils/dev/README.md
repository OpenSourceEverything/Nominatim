# Dev Scripts Readme

1) chmod +x *.sh
2) edit .env.nominatim (fork url, ports, urls)
3) ./setup.sh
4) ./import_multi.sh
5) ./start-server.sh
6) ./server-status.sh
7) ./add_region.sh <geofabrik_pbf_url>
8) ./stop-server.sh
9) ./cleanup.sh

## notes

- logs: $PROJ/nominatim.log
- pid:  $PROJ/.nominatim.pid
- start blocks if port busy; status shows live pid(s)
