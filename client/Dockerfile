FROM ubuntu:latest

RUN apt update \
&& apt install -y wireguard \
&& apt-get clean

RUN apt update \
&& apt-get install -y iptables curl iproute2 ifupdown iputils-ping \
&& apt-get clean

#RUN apt update \
#&& apt install -y linux-headers-$(uname -r) \
#&& apt-get clean

COPY startup.sh /docker-entrypoint.d/

RUN ["chmod", "+x", "/docker-entrypoint.d/startup.sh"]
ENTRYPOINT ["/docker-entrypoint.d/startup.sh"]
