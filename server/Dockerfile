FROM ubuntu:latest

COPY startup.sh /docker-entrypoint.d/

RUN apt update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:wireguard/wireguard
RUN apt install wireguard
RUN apt-get clean