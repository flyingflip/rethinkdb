# Quick reference
Maintained by: [FlyingFlip Studios, LLC](https://www.flyingflip.com)  

Official Web Site: [RethinkDB](https://www.rethinkdb.com)


# Supported tags and respective `Dockerfile` links

- `2.4.1-arm`, `2.4.2-arm`, `2.4.3-arm`, `2.4.4-arm`
- `2.4.1-amd`, `2.4.2-amd`, `2.4.3-amd`, `2.4.4-amd`
- `2.4.4`, `latest` - multi-architecture tag that pulls the matching `-arm` or `-amd` image for your CPU

**Current Version: 2.4.4**

# What is RethinkDB?

RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports table joins, groupings, aggregations, and functions.

# How to use this image
This image is a drop-in replacement for the official [RethinkDB](https://www.rethinkdb.com) image and accepts the same command line options and volumes. In addition to the RethinkDB server, it also includes the python based tools for backing up database, exporting and importing data. It is built on Alpine Linux 3.22, with RethinkDB compiled from source using clang++ against musl, and is published natively for both `arm64` and `amd64`.

I have used most of the README and all of the instructions from [RethinkDB's DockerHub](https://hub.docker.com/_/rethinkdb) page. Upstream RethinkDB does not publish ARM builds, so treat the `arm64` image as community supported and use it at your own discretion.  

**One addition to this image is the inclusion of the python libraries not present in the official images so you can do backup and restores of databases.**  

## Start an instance with data mounted in the working directory

The default CMD of the image is  `rethinkdb --bind all`, so the RethinkDB daemon will bind to all network interfaces available to the container (by default, RethinkDB only accepts connections from  `localhost`).

```
docker run --name rethinkdb -p 8080:8080 -d -v "$PWD:/data" flyingflip/rethinkdb
```
## docker-compose.yml example using network mode

```yml
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
networks:
  rethinkdb: {}
```

## Configuration

See the  [official docs](http://www.rethinkdb.com/docs/)  for infomation on using and configuring a RethinkDB cluster.

# Building the image

The `Dockerfile` is architecture-neutral, so the same file builds both `arm64` and `amd64`. RethinkDB is compiled from source during the build, which takes around 5 minutes on a modern machine. To build a different RethinkDB release, change the tarball version near the bottom of the `Dockerfile`.

## QEMU emulation does not work

RethinkDB cannot be built or run under QEMU emulation. A cross-platform build such as `docker buildx build --platform linux/amd64,linux/arm64` will complete on a single host, but the RethinkDB binary produced for the emulated architecture does not run. Likewise, the published `amd64` image hangs at startup when run through Docker Desktop's emulation on an Apple Silicon Mac. This is true of the official `rethinkdb` image as well and is not a defect in this build.

Because of this, each architecture has to be built and tested on hardware that matches it. Do not use a single `--platform` list to build both images from one machine.

## Building each architecture natively

Build each architecture on its own machine and push it under a per-architecture tag:

```
# On an arm64 host
docker build -t flyingflip/rethinkdb:2.4.4-arm .
docker push flyingflip/rethinkdb:2.4.4-arm

# On an amd64 host
docker build -t flyingflip/rethinkdb:2.4.4-amd .
docker push flyingflip/rethinkdb:2.4.4-amd
```

Before pushing, confirm the image starts on the machine that built it:

```
docker run --rm -p 8080:8080 flyingflip/rethinkdb:2.4.4-arm
```

RethinkDB should log `Server ready` and the web UI should be reachable on port 8080.

## Combining the architectures into one tag

Once both per-architecture images are on Docker Hub, combine them into a single multi-architecture tag from any machine. Docker publishes the result as a manifest list, and clients automatically pull the image that matches their CPU:

```
docker buildx imagetools create -t flyingflip/rethinkdb:2.4.4 \
  flyingflip/rethinkdb:2.4.4-amd \
  flyingflip/rethinkdb:2.4.4-arm

docker buildx imagetools create -t flyingflip/rethinkdb:latest \
  flyingflip/rethinkdb:2.4.4-amd \
  flyingflip/rethinkdb:2.4.4-arm
```

You can verify the result with `docker buildx imagetools inspect flyingflip/rethinkdb:2.4.4`, which lists both platforms. The per-architecture tags stay available for anyone who wants to pin to one.

## Build notes

The `Dockerfile` makes a few adjustments so RethinkDB compiles with clang++ on Alpine's musl libc:

- jemalloc comes from Alpine's `jemalloc-dev` and `jemalloc-static` packages rather than the copy RethinkDB would normally download, because Alpine's headers carry a musl patch that the upstream headers lack.
- `protoc` is fetched and built from source by RethinkDB's own `configure` script.
- The build is compiled with `-U_FORTIFY_SOURCE` because Alpine's fortify headers conflict with RethinkDB's internal `send()` templates.
- The build is compiled with `-DRDB_NO_BACKTRACE` because musl has no `execinfo.h`. The only effect is that crash logs do not include a stack trace.

# License

View  [license information](https://raw.githubusercontent.com/rethinkdb/rethinkdb/next/LICENSE)  for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in  [the  `repo-info`  repository's  `rethinkdb/`  directory](https://github.com/docker-library/repo-info/tree/master/repos/rethinkdb).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
