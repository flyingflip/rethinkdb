FROM ubuntu:22.04

# Set our our meta data for this container.
LABEL name="RethinkDB Container with Tools"
LABEL author="Michael R. Bagnall <hello@flyingflip.com>"
LABEL vendor="FlyingFlip Studios, LLC."

# Install dependencies for compiling RethinkDB
RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt upgrade -y && \
  apt install -y build-essential protobuf-compiler \
  python3 python-is-python3 pip clang wget \
  libprotobuf-dev libcurl4-openssl-dev \
  libncurses5-dev libjemalloc-dev wget m4 g++ libssl-dev

# Install Python Library for backup processes
RUN pip install rethinkdb

RUN wget https://mbagnall.s3.amazonaws.com/rethinkdb-2.4.2.tgz && \
  tar -xzf rethinkdb-2.4.2.tgz && \
  cd rethinkdb-2.4.2 && \
  ./configure --prefix=/opt --allow-fetch CXX=clang++ && \
  make -j4 && \
  make install && \
  cd /root && \
  rm -rf rethinkdb-2.4.2 && \
  rm -rf rethinkdb-2.4.2.tgz

VOLUME ["/data"]

WORKDIR /data
EXPOSE 28015 29015 8080

CMD ["/opt/bin/rethinkdb", "--bind", "all"]

