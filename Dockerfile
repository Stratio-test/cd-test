FROM ubuntu:22.04

RUN apt-get update && apt-get install wget -y

RUN wget -c http://archive.ubuntu.com/ubuntu/pool/main/m/make-dfsg/make_4.3-4.1build1_amd64.deb

RUN apt-get update && apt-get install ./make_4.3-4.1build1_amd64.deb -y
