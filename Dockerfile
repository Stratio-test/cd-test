# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04
RUN ls
CMD ["/usr/bin/tail", "-f", "/dev/null"]
