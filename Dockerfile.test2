FROM ubuntu:16.04
MAINTAINER CD "cd@stratio.com"

ARG VERSION
COPY target/cd-test-${VERSION}.jar /

CMD ["/usr/bin/tail", "-f", "/dev/null"]
