# Quick reference
Maintained by: [FlyingFlip Studios, LLC](https://www.flyingflip.com)  

Official Web Site: [RethinkDB](https://www.rethinkdb.com)


# Supported tags and respective `Dockerfile` links

- `2.4.1-arm`, `2.4.2-arm`, `2.4.3-arm`, `2.4.4-arm`
- `2.4.1-amd`, `2.4.2-amd`, `2.4.3-amd`, `2.4.4-amd`
- `latest` - The latest version on AMD processor

**Current Version: 2.4.4**

# What is RethinkDB?

RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports table joins, groupings, aggregations, and functions.

# How to use this image
Keeping in mind that this image is syntactically compatible with the main [RethinkDB](https://www.rethinkdb.com) image, it is largely the same and follows the compiling instructions for RaspberryPi. In addition to the RethinkDB server, it also includes the python based tools for backing up database, exporting and importing data. It is built on Alpine Linux 3.22, with RethinkDB compiled from source using clang++ against musl.

I have used most of the README and all of the instructions from [RethinkDB's DockerHub](https://hub.docker.com/_/rethinkdb) page. ARM support is still considered experimental - so use at your own discretion.  

**One addition to this image is the inclusion of the python libraries not present in the official images so you can do backup and restores of databases.**  

## Start an instance with data mounted in the working directory

The default CMD of the image is  `rethinkdb --bind all`, so the RethinkDB daemon will bind to all network interfaces available to the container (by default, RethinkDB only accepts connections from  `localhost`).

```
docker run --name rethinkdb -p8080:8080 -d -v "$PWD:/data" -d flyingflip/rethinkdb
```
## docker-compose.yml example using network mode

```yml
version: '3'
services:
  rethinkdb:
    image: flyingflip/rethinkdb
    container_name: rethinkdb
    volumes:
      - ./data:/data
    network_mode: host
    restart: unless-stopped
```

## docker-compose.yml example with port mapping
```yml
version: '3'
services:
  rethinkdb:
    image: flyingflip/rethinkdb
    container_name: rethinkdb
    volumes:
      - ./data:/data
    ports:
      - "8080:8080"
    networks:
      - rethinkdb
    restart: unless-stopped
network:
  rethinkdb: null
```

## Configuration

See the  [official docs](http://www.rethinkdb.com/docs/)  for infomation on using and configuring a RethinkDB cluster.

# Building the image

The `Dockerfile` is architecture-neutral, so the same file builds both `arm64` and `amd64`. RethinkDB is compiled from source during the build, so expect it to take a while.

## One tag for both architectures

Use `docker buildx` to build both platforms in a single command and push them under one tag. Docker publishes the result as a manifest list, and clients automatically pull the image that matches their CPU.

```
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t flyingflip/rethinkdb:2.4.4 \
  -t flyingflip/rethinkdb:latest \
  --push .
```

Notes:

- `--push` is required for the multi-platform result. Add `--load` as well if you want a local copy, which needs Docker's containerd image store enabled (on by default in recent Docker Desktop releases). If your builder does not support multi-platform builds, create one first with `docker buildx create --use`.
- Whichever architecture does not match your host is built under QEMU emulation, which is several times slower than a native build. On an Apple Silicon Mac, the `arm64` half takes around 5 minutes and the emulated `amd64` half around 20 minutes.
- RethinkDB's `amd64` binary hangs at startup when run under Docker Desktop's emulation on Apple Silicon. This is true of the official `rethinkdb` image as well and is not a build problem. Test the `amd64` image on a real `amd64` host.

## Building each architecture natively

If emulation is too slow, build each architecture on its own machine, push them as separate tags, and then combine them into a single tag:

```
# On an arm64 host
docker build -t flyingflip/rethinkdb:2.4.4-arm . && docker push flyingflip/rethinkdb:2.4.4-arm

# On an amd64 host
docker build -t flyingflip/rethinkdb:2.4.4-amd . && docker push flyingflip/rethinkdb:2.4.4-amd

# From anywhere, once both are pushed
docker buildx imagetools create -t flyingflip/rethinkdb:2.4.4 \
  flyingflip/rethinkdb:2.4.4-amd \
  flyingflip/rethinkdb:2.4.4-arm
```

This produces the same multi-architecture tag as the single-command build and keeps the per-architecture tags available.

# License

View  [license information](https://raw.githubusercontent.com/rethinkdb/rethinkdb/next/LICENSE)  for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in  [the  `repo-info`  repository's  `rethinkdb/`  directory](https://github.com/docker-library/repo-info/tree/master/repos/rethinkdb).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
