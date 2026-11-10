#!/usr/bin/env bash
set -euo pipefail
for svc in mosquitto-b1 mosquitto-b2 mosquitto-b3 mpc0 mpc1 mpc2; do
  docker compose exec -T "$svc" sh -lc 'tc qdisc del dev eth0 root 2>/dev/null || true'
done
echo "Cleared netem qdiscs."
