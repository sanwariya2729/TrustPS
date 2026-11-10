#!/usr/bin/env bash
set -euo pipefail
RTT="${1:-0}"
if ! [[ "$RTT" =~ ^[0-9]+$ ]] || (( RTT > 200 )); then
  echo "Usage: $0 <RTT_ms: 0..200>" >&2; exit 2
fi
ONE_WAY="$(awk -v r="$RTT" 'BEGIN { printf "%.3f", r/2 }')"
for svc in mosquitto-b1 mosquitto-b2 mosquitto-b3 mpc0 mpc1 mpc2; do
  docker compose exec -T "$svc" sh -lc \
    "tc qdisc replace dev eth0 root netem delay ${ONE_WAY}ms"
done
echo "Configured ${ONE_WAY}ms egress delay at each endpoint (nominal pairwise RTT ${RTT}ms)."
