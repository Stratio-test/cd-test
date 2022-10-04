# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:latest
MAINTAINER CD "cd@stratio.com"

ARG VERSION
CMD ["/usr/bin/tail", "-f", "/dev/null"]
