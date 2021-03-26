
# docker build -t waggle-sensor/waggle-pki-tools .

# docker run -ti -v `pwd`:/workdir waggle-sensor/waggle-pki-tools bash


FROM ubuntu:20.04

WORKDIR /workdir
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y openssh-client openssl


