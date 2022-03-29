FROM ubuntu:latest

COPY startup.sh /docker-entrypoint.d/

RUN apt update \
&& apt-get install -y software-properties-common \
&& add-apt-repository ppa:wireguard/wireguard \
&& apt install -y wireguard \
&& apt-get clean