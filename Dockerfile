FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl

USER root

RUN curl https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

RUN curl https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
