# FROM ubuntu:22.04

# RUN apt-get update && apt-get install -y \
#     curl

# USER root

# RUN curl https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# RUN curl https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

FROM maven:3.8.6-openjdk-11

ARG UNAME=jenkins
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME

RUN chown -R $UNAME:$UNAME /home/$UNAME

RUN apt-get update && apt-get install -y fakeroot rpm

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
