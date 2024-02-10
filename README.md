# Quick reference
Maintained by: [FlyingFlip Studios, LLC](https:www.flyingflip.com)  

Official Web Site: [RethinkDB](https://www.rethinkdb.com)


# Supported tags and respective `Dockerfile` links

- `2.4.1-arm`, `2.4.2-arm`, `2.4.3-arm`, `2.4.4-arm`
- `2.4.1-amd`, `2.4.2-amd`, `2.4.3-amd`, `2.4.4-amd`
- `latest` - The latest version on AMD processor

**Current Version: 2.4.4**

# What is RethinkDB?

RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports table joins, groupings, aggregations, and functions.

# How to use this image
Keeping in mind that this image is syntactically compatible with the main [RethinkDB](https://www.rethinkdb.com) image, it is largely the same and follows the compiling instructions for RaspberryPi. In addition to the RethinkDB server, it also includes the pyton based tools for backing up database, exporting and importing data. It is built on Ubuntu. I had to move away from Alpine due to shifting priorities on dependent packages needed to compile the code.

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

# License

View  [license information](https://raw.githubusercontent.com/rethinkdb/rethinkdb/next/LICENSE)  for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in  [the  `repo-info`  repository's  `rethinkdb/`  directory](https://github.com/docker-library/repo-info/tree/master/repos/rethinkdb).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
