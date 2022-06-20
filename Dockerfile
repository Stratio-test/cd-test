# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04
MAINTAINER CD "cd@stratio.com"

ARG VERSION
RUN apt-get update && apt-get -y install git && rm -rf /var/lib/apt/lists/*

COPY target/cd-test-${VERSION}.jar /
RUN mkdir -m 700 /root/.ssh; touch -m 600 /root/.ssh/known_hosts; ssh-keyscan github.com > /root/.ssh/known_hosts
RUN --mount=type=ssh,id=default git clone git@github.com:Stratio/continuous-delivery-tng.git
RUN ls
CMD ["/usr/bin/tail", "-f", "/dev/null"]
