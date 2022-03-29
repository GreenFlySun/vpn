FROM ubuntu:latest

RUN apt update \
&& apt install -y wireguard \
&& apt-get clean

RUN apt update \
&& apt-get install -y iptables curl iproute2 ifupdown iputils-ping \
&& apt-get clean

# Крч, тут запара, что докер контейнер не создаёт своё ядро линукс, 
# а пробрасывает из хоста. Т.е. одно ядро на все контейнеры.
# и при попытке запустить wg оно пытается взаимодействать с этим ядром
# А докер не даёт, ибо нэбэзопасно, так ещё и хост кхуям сломать может.

#RUN apt update \
#&& apt install -y linux-headers-$(echo "uname -r"| cut -c 1-2) \
#&& apt-get clean

COPY startup.sh /docker-entrypoint.d/

RUN ["chmod", "+x", "/docker-entrypoint.d/startup.sh"]
ENTRYPOINT ["/docker-entrypoint.d/startup.sh"]
