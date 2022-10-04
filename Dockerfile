# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04
MAINTAINER CD "cd@stratio.com"

ARG VERSION
CMD ["/usr/bin/tail", "-f", "/dev/null"]
