# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04
MAINTAINER CD "cd@stratio.com"

ARG VERSION
RUN apt update && apt install git
COPY target/cd-test-${VERSION}.jar /
RUN --mount=type=ssh git clone git@github.com:Stratio/continuous-delivery-tng.git
CMD ["/usr/bin/tail", "-f", "/dev/null"]
