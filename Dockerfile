FROM ubuntu:22.04

# Set our our meta data for this container.
LABEL name="RethinkDB Container with Tools"
LABEL author="Michael R. Bagnall <michael@bagnall.io>"
LABEL vendor="FlyingFlip Studios, LLC."

# Install dependencies for compiling RethinkDB
RUN apt update && apt upgrade && apt update
RUN apt-get -y install build-essential protobuf-compiler \
  python3 python-is-python3 pip clang wget \
  libprotobuf-dev libcurl4-openssl-dev \
  libncurses5-dev libjemalloc-dev wget m4 g++ libssl-dev

# Install Python Library for backup processes
RUN pip install rethinkdb

RUN wget https://mbagnall.s3.amazonaws.com/rethinkdb-2.4.3.tgz && \
  tar -xzf rethinkdb-2.4.3.tgz && \
  cd rethinkdb-2.4.3 && \
  ./configure --prefix=/opt --allow-fetch CXX=clang++ && \
  make -j4 && \
  make install && \
  cd /root && \
  rm -rf rethinkdb-2.4.3 && \
  rm -rf rethinkdb-2.4.3.tgz

VOLUME ["/data"]

WORKDIR /data
EXPOSE 28015 29015 8080

CMD ["/opt/bin/rethinkdb", "--bind", "all"]

