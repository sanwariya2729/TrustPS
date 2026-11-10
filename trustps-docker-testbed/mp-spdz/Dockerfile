FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG MP_SPDZ_REF=master
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake build-essential clang cmake git libboost-all-dev libgmp-dev \
    libntl-dev libsodium-dev libssl-dev libtool iproute2 python3 python3-pip \
    ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN git clone https://github.com/data61/MP-SPDZ.git
WORKDIR /opt/MP-SPDZ
RUN git checkout "${MP_SPDZ_REF}" && \
    make -j2 malicious-rep-ring-party.x
RUN mkdir -p Player-Data
CMD ["sleep", "infinity"]
