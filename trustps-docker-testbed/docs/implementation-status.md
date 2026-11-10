# Implementation status

| Component | Status |
|---|---|
| Ring encoding and share arithmetic | Python prototype exists; verify overflow and negative-value semantics |
| PRF / AEAD | Placeholder HMAC/AES-GCM only; replace with paper-specified primitives |
| MQTT publisher | Basic Paho publishing adapter exists |
| Three Mosquitto brokers | Docker scaffold provided; not yet run/validated in this environment |
| Mosquitto 2.0 C plugin | Not implemented |
| Durable broker share store | Not implemented |
| MP-SPDZ VM | Docker build recipe provided; not yet built |
| MP-SPDZ program and party config | Not implemented/validated |
| Share-format adapter | Not implemented |
| DRCF six datasets | Not present in supplied Overleaf archive |
| E1-E7 measurements | Not run; no results should be reported yet |
