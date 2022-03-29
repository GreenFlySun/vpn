FROM ubuntu:latest

COPY startup.sh /docker-entrypoint.d/

RUN apt update \
  && apt install -y wireguard \
  && apt-get clean