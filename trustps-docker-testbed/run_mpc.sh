#!/usr/bin/env bash
set -u

mkdir -p logs

docker compose exec -T mpc0 bash -lc \
  'cd /opt/MP-SPDZ && timeout 90s ./malicious-rep-ring-party.x --ip-file-name Player-Data/hosts 0 trustps_add' \
  >logs/mpc0.log 2>&1 </dev/null &
p0=$!

docker compose exec -T mpc1 bash -lc \
  'cd /opt/MP-SPDZ && timeout 90s ./malicious-rep-ring-party.x --ip-file-name Player-Data/hosts 1 trustps_add' \
  >logs/mpc1.log 2>&1 </dev/null &
p1=$!

docker compose exec -T mpc2 bash -lc \
  'cd /opt/MP-SPDZ && timeout 90s ./malicious-rep-ring-party.x --ip-file-name Player-Data/hosts 2 trustps_add' \
  >logs/mpc2.log 2>&1 </dev/null &
p2=$!

wait "$p0"
r0=$?
wait "$p1"
r1=$?
wait "$p2"
r2=$?

echo "Exit codes: mpc0=$r0 mpc1=$r1 mpc2=$r2"

for p in mpc0 mpc1 mpc2; do
  echo "========== $p =========="
  cat "logs/$p.log"
done
