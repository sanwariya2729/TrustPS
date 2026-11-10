#!/usr/bin/env bash
set -euo pipefail
docker compose ps
for port in 1883 1884 1885; do
  if timeout 2 bash -c "</dev/tcp/127.0.0.1/$port" 2>/dev/null; then
    echo "MQTT port $port: reachable"
  else
    echo "MQTT port $port: NOT reachable"
  fi
done
