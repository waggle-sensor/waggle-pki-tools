FROM ubuntu:20.04

WORKDIR /workdir
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y openssh-client openssl sshpass
