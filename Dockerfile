# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04
MAINTAINER CD "cd@stratio.com"

ARG VERSION
RUN apt-get update && apt-get -y install git && rm -rf /var/lib/apt/lists/*

COPY target/cd-test-${VERSION}.jar /
RUN ls
CMD ["ls"]
