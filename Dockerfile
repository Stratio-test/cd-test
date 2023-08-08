# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:16.04

CMD ["/usr/bin/tail", "-f", "/dev/null"]
