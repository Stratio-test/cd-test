FROM python:slim-buster
MAINTAINER CD "cd@stratio.com"

ARG VERSION

CMD ["/usr/bin/tail", "-f", "/dev/null"]
