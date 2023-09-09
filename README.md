# Supported tags and respective `Dockerfile` links

- `arm`
- `amd` `latest`

**Current Version: 2.4.3**

# What is RethinkDB?

RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports table joins, groupings, aggregations, and functions.

# How to use this image
Keeping in mind that this image is syntactically compatible with the main [RethinkDB](https://www.rethinkdb.com) image, it is largely the same and follows the compiling instructions for RaspberryPi. In addition to the RethinkDB server, it also includes the pyton based tools for backing up database, exporting and importing data. It is built on Ubuntu 22.04 LTS. I had to move away from Alpine due to shifting priorities on dependent packages needed to compile the code.

I have used most of the README and all of the instructions from [RethinkDB's DockerHub](https://hub.docker.com/_/rethinkdb) page. ARM support is still considered experimental - so use at your own discretion.  

**One addition to this image is the inclusion of the python libraries not present in the official images so you can do backup and restores of databases.**  

## Start an instance with data mounted in the working directory

The default CMD of the image is  `rethinkdb --bind all`, so the RethinkDB daemon will bind to all network interfaces available to the container (by default, RethinkDB only accepts connections from  `localhost`).

```
docker run --name some-rethink -v "$PWD:/data" -d mbagnall/rethinkdb
```

## Connect the instance to an application

```
docker run --name some-app --link some-rethink:rdb -d application-that-uses-rdb
```

## Connecting to the web admin interface on the same host

```
$BROWSER "http://$(docker inspect --format \
  '{{ .NetworkSettings.IPAddress }}' some-rethink):8080"
```

# Connecting to the web admin interface on a remote / virtual host via SSH

Where  `remote`  is an alias for the remote user@hostname:

```
# start port forwarding
ssh -fNTL localhost:8080:$(ssh remote "docker inspect --format \
  '{{ .NetworkSettings.IPAddress }}' some-rethink"):8080 remote

# open interface in browser
xdg-open http://localhost:8080

# stop port forwarding
kill $(lsof -t -i @localhost:8080 -sTCP:listen)
```

## Configuration

See the  [official docs](http://www.rethinkdb.com/docs/)  for infomation on using and configuring a RethinkDB cluster.

# License

View  [license information](https://raw.githubusercontent.com/rethinkdb/rethinkdb/next/LICENSE)  for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in  [the  `repo-info`  repository's  `rethinkdb/`  directory](https://github.com/docker-library/repo-info/tree/master/repos/rethinkdb).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
