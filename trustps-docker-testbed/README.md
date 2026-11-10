# Trust-PS Docker testbed (bootstrap scaffold)

This scaffold starts three independent Eclipse Mosquitto 2.0 brokers and three
MP-SPDZ party containers on one Docker bridge network. It is a development
testbed, not a secure deployment and not yet the complete Trust-PS system.

## Prerequisites

- Docker Engine and Docker Compose v2 (`docker compose version`)
- At least 8 GB RAM recommended; MP-SPDZ compilation can be CPU/RAM intensive
- `git`, `bash`, `awk`, and `timeout` on the host

On Arch Linux, install Docker and the Compose plugin using your normal package
manager, enable/start the Docker service, and add your account to the `docker`
group if appropriate. Log out/in after changing group membership.

## Start

```bash
docker compose build mosquitto-b1 mpc0
docker compose up -d
docker compose ps
./scripts/status.sh
```

The first MP-SPDZ image build clones the repository and compiles
`malicious-rep-ring-party.x`; allow time for this. For reproducible experiments,
do not leave `MP_SPDZ_REF=master`: set it to a reviewed commit hash in `.env`,
rebuild, and record the commit in the experiment metadata.

Broker host ports:
- B1: `localhost:1883`
- B2: `localhost:1884`
- B3: `localhost:1885`

Inside the Docker network, broker DNS names are `mosquitto-b1`, `mosquitto-b2`,
`mosquitto-b3`, each on port 1883. MP-SPDZ party DNS names are `mpc0`, `mpc1`,
`mpc2`.

## Basic MQTT smoke test

Install the Mosquitto CLI on the host, or use a temporary client container:

```bash
docker run --rm --network trustps-net eclipse-mosquitto:2.0 \
  mosquitto_sub -h mosquitto-b1 -t 'trustps/#' -v
```

In another terminal:

```bash
docker run --rm --network trustps-net eclipse-mosquitto:2.0 \
  mosquitto_pub -h mosquitto-b1 -t 'trustps/smoke' -m 'hello-trustps'
```

Repeat against B2 and B3 by changing the host name.

## RTT emulation

```bash
./scripts/set-rtt.sh 0
./scripts/set-rtt.sh 25
./scripts/set-rtt.sh 50
./scripts/set-rtt.sh 100
./scripts/set-rtt.sh 200
./scripts/clear-rtt.sh
```

The script applies half the requested RTT as egress delay to each endpoint.
This approximates a symmetric pairwise RTT between containers. Verify the
actual RTT with `ping`/TCP measurements and record the observed value, not just
the configured value. This one-host Docker topology models controlled delay;
it does not reproduce independent cloud-provider paths, WAN jitter, loss, or
contention.

## MP-SPDZ status

The image builds the malicious replicated ring VM. Before running a real
computation, configure the MP-SPDZ player host list, certificates, program,
and per-party input files. The three volumes are deliberately separate.
Generate certificates inside the MP-SPDZ checkout with:

```bash
docker compose exec mpc0 ./Scripts/setup-ssl.sh 3 Player-Data
```

Copy the generated party-specific certificate/key material into each party's
Player-Data volume using a controlled setup script; do not share private keys
between parties. Configure the same trusted CA material on each party.

The executable uses the three-party replicated ring protocol modulo 2^k.
Compile a program with `./compile.py -R 64 PROGRAM`. The actual party launch
and host-file configuration must be validated against the pinned MP-SPDZ
revision before benchmark runs. See the official MP-SPDZ getting-started
documentation.

## Current limitations — important

1. The Python starter is a protocol unit-test prototype. Its HMAC-SHA256 and
   AES-GCM backends are placeholders, not the ASCON suite specified by the paper.
2. The Paho adapter publishes packets; it does not implement the Mosquitto C
   plugin. Broker authentication, decryption, durable share writes, replay
   protection, batch consistency checks, refresh, and recovery remain to be
   implemented and tested.
3. The Python broker-store model must not be treated as persistent broker
   storage or as evidence of broker-side protocol execution.
4. MP-SPDZ's native replicated shares are not interchangeable with arbitrary
   `(x_k, x_{k+1})` byte pairs. An explicit, reviewed input/output adapter is
   required. Until that exists, do not claim the optimized share-ingestion path
   is integrated.
5. `allow_anonymous true` is intentionally limited to an isolated local smoke
   test. Do not expose these ports to a LAN or the Internet.
6. The paper's own recovery discussion identifies a malicious-survivor attack
   that can make corrupted recovery state appear consistent. Do not claim
   maliciously secure recovery without resolving this limitation in the
   protocol and evaluation.

## Stop and clean up

```bash
docker compose down
# Destructive: also removes broker persistence and MP-SPDZ party volumes:
docker compose down -v
```

## Reproducibility record

For every run, record:
- host CPU, RAM, kernel, Docker version
- image tags/digests and MP-SPDZ git commit
- broker/plugin commit and configuration
- workload dataset checksum and workload parameters
- configured and measured RTT, loss, jitter
- repetitions, warm-up policy, raw per-run JSONL
