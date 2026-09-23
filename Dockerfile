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

RUN apk add --no-cache \
  python3 py3-pip clang pipx \
  libprotobuf protobuf-dev \
  ncurses-dev jemalloc-dev wget m4 g++ libssl3 \
  build-base wget curl curl-dev bash

RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj && \
  cd jemalloc-5.2.1 && \
  ./configure --enable-shared --enable-static && \
  make && \
  make install



# Install Python Library for backup processes
RUN pipx install rethinkdb

RUN wget https://mbagnall.s3.amazonaws.com/rethinkdb-2.4.4.tgz && \
  tar -xzf rethinkdb-2.4.4.tgz && \
  cd rethinkdb-2.4.4 && \
  ./configure --prefix=/opt --allow-fetch --fetch protoc --fetch jemalloc CXX=clang++ && \
  make -j4 && \
  make install && \
  cd /root && \
  rm -rf rethinkdb-2.4.4 && \
  rm -rf rethinkdb-2.4.4.tgz

VOLUME ["/data"]

WORKDIR /data
EXPOSE 28015 29015 8080

CMD ["/opt/bin/rethinkdb", "--bind", "all"]

