FROM golang:1.19 as build
WORKDIR /src
RUN git clone https://github.com/bitly/little_bigtable
RUN cd little_bigtable && make && ls -lh build
FROM google/cloud-sdk as gcs
FROM ubuntu:22.04
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
  libssl-dev \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/little_bigtable/build/little_bigtable /usr/bin/little_bigtable
COPY --from=gcs /usr/bin/cbt /usr/bin/cbt
