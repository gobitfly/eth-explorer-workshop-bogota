FROM golang:1.19 as build
WORKDIR /src
RUN git clone https://github.com/bitly/little_bigtable
RUN cd little_bigtable && make && ls -lh build
RUN git clone https://github.com/gobitfly/eth2-beaconchain-explorer
RUN cd eth2-beaconchain-explorer && git checkout workshop && make && ls -lh bin
FROM google/cloud-sdk as gcs
FROM ubuntu:22.04
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
  libssl-dev \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/little_bigtable/build/little_bigtable /usr/bin/little_bigtable
COPY --from=build /src/eth2-beaconchain-explorer/bin/explorer /usr/bin/explorer
COPY --from=build /src/eth2-beaconchain-explorer/bin/eth1indexer /usr/bin/eth1indexer
COPY --from=build /src/eth2-beaconchain-explorer/bin/frontend-data-updater /usr/bin/frontend-data-updater
COPY --from=build /src/eth2-beaconchain-explorer/bin/statitics /usr/bin/statisitcs
COPY --from=gcs /usr/bin/cbt /usr/bin/cbt
