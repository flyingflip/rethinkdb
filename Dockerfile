FROM alpine:3.22

# Set our our meta data for this container.
LABEL name="RethinkDB Container with Tools"
LABEL author="Michael R. Bagnall <hello@flyingflip.com>"
LABEL vendor="FlyingFlip Studios, LLC."

# Install dependencies for compiling RethinkDB
# RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt upgrade -y && \
#   apt install -y build-essential protobuf-compiler \
#   python3 python-is-python3 pip clang wget \
#   libprotobuf-dev libcurl4-openssl-dev \
#   libncurses5-dev libjemalloc-dev wget m4 g++ libssl-dev


RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk upgrade

# jemalloc-static provides /usr/lib/libjemalloc.a, which RethinkDB's configure
# looks for (it links jemalloc statically). Alpine's jemalloc headers carry a
# musl patch that clang++ needs; the upstream 5.2.1 headers do not, so we do
# not build jemalloc from source here.
RUN apk add --no-cache \
  python3 py3-pip clang pipx \
  libprotobuf protobuf-dev \
  ncurses-dev jemalloc-dev jemalloc-static wget m4 g++ libssl3 \
  build-base wget curl curl-dev bash

# Install Python Library for backup processes
RUN pipx install rethinkdb

# configure.default in the tarball force-adds "--fetch jemalloc"; strip it so
# the system jemalloc is used. -U_FORTIFY_SOURCE: Alpine's fortify headers
# break on RethinkDB's global send() templates. -DRDB_NO_BACKTRACE: musl has
# no execinfo.h (crash logs lose stack traces, nothing else changes).
RUN wget https://mbagnall.s3.amazonaws.com/rethinkdb-2.4.4.tgz && \
  tar -xzf rethinkdb-2.4.4.tgz && \
  cd rethinkdb-2.4.4 && \
  sed -i 's/--fetch jemalloc //' configure.default && \
  ./configure --prefix=/opt --allow-fetch --fetch protoc CXX=clang++ \
    CXXFLAGS="-U_FORTIFY_SOURCE -DRDB_NO_BACKTRACE" && \
  make -j4 && \
  make install && \
  cd /root && \
  rm -rf rethinkdb-2.4.4 && \
  rm -rf rethinkdb-2.4.4.tgz

VOLUME ["/data"]

WORKDIR /data
EXPOSE 28015 29015 8080

CMD ["/opt/bin/rethinkdb", "--bind", "all"]

