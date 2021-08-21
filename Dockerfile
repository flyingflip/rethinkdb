FROM ubuntu:20.04

# Set our our meta data for this container.
LABEL name="RethinkDB Container for ARM Systems"
LABEL author="Michael R. Bagnall <michael@bagnall.io>"

WORKDIR /root

ENV TERM xterm

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/www/html/vendor/drush/drush:vendor/drush/drush:/var/www/html/drush/drush

# Install dependencies for compiling RethinkDB
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y && \
  apt-get -y install g++ protobuf-compiler libprotobuf-dev libboost-dev curl m4 wget libssl-dev clang python make patch

COPY rethinkdb-2.4.1.tar.gz /rethinkdb.tar.gz
RUN cd / && tar xf rethinkdb.tar.gz && \
  cd rethinkdb-2.4.1 && \
  ./configure --allow-fetch CXX=clang++ && \
  make install

# Clean up our source code
RUN cd / && rm -rf rethinkdb-2.4.1

VOLUME ["/data"]

WORKDIR /data

CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080