FROM ubuntu:20.04

# Set our our meta data for this container.
LABEL name="RethinkDB Container for ARM Systems"
LABEL author="Michael R. Bagnall <michael@bagnall.io>"
LABEL vendor="FlyingFlip Studios, LLC."

# Install dependencies for compiling RethinkDB
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  g++ \
  protobuf-compiler \
  libprotobuf-dev \
  libboost-dev \
  curl \
  m4 \
  wget \
  libssl-dev \
  clang \
  python \
  python3-pip \
  make \
  patch

# Install Python Library for backup processes
RUN pip install rethinkdb

COPY rethinkdb-2.4.2.tgz /rethinkdb.tgz
RUN cd / && tar xf rethinkdb.tgz && \
  cd rethinkdb-2.4.2 && \
  ./configure --allow-fetch CXX=clang++ && \
  make install

# Clean up our source code
RUN cd / && rm -rf rethinkdb-2.4.2
RUN cd / && rm rethinkdb.tgz

VOLUME ["/data"]

WORKDIR /data

CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080