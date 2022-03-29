#!/bin/bash

set -x


#mkdir /etc/wireguard
#touch /etc/wireguard/server_public.key
#echo "test_numbers" >> /etc/wireguard/server_public.key 

SYSCTL="/etc/sysctl.conf"

if [  $(grep -c "net.ipv4.ip_forward = 1" $SYSCTL) -eq 0 ]
then echo "net.ipv4.ip_forward = 1" >> $SYSCTL
fi
if [  $(grep -c "net.ipv6.conf.default.forwarding = 1" $SYSCTL) -eq 0 ]
then echo "net.ipv6.conf.default.forwarding = 1" >> $SYSCTL
fi
if [  $(grep -c "net.ipv6.conf.all.forwarding = 1" $SYSCTL) -eq 0 ]
then echo "net.ipv6.conf.all.forwarding = 1" >> $SYSCTL
fi
if [  $(grep -c "net.ipv4.conf.all.rp_filter = 1" $SYSCTL) -eq 0 ]
then echo "net.ipv4.conf.all.rp_filter = 1" >> $SYSCTL
fi
if [  $(grep -c "net.ipv4.conf.default.proxy_arp = 0" $SYSCTL) -eq 0 ]
then echo "net.ipv4.conf.default.proxy_arp = 0" >> $SYSCTL
fi
if [  $(grep -c "net.ipv4.conf.default.send_redirects = 1" $SYSCTL) -eq 0 ]
then echo "net.ipv4.conf.default.send_redirects = 1" >> $SYSCTL
fi
if [  $(grep -c "net.ipv4.conf.all.send_redirects = 0" $SYSCTL) -eq 0 ]
then echo "net.ipv4.conf.all.send_redirects = 0" >> $SYSCTL
fi
sysctl -p

wg genkey | tee /etc/wireguard/server_private.key | wg pubkey |  tee /etc/wireguard/server_public.key

PUBKEY=$( < /etc/wireguard/server_public.key )
PRIKEY=$( < /etc/wireguard/server_private.key )

touch /etc/wireguard/client.conf

echo -e "[Interface]
PrivateKey = \n
Address = 10.66.66.2/24,fd42:42:42::2/64 \n
DNS = 8.8.8.8,8.8.4.4 \n
[Peer] \n 
PublicKey = \n
Endpoint = 192.168.1.1:63665 \n
AllowedIPs = 0.0.0.0/0,::/0" > /etc/wireguard/client.conf

sed -i 's/^PublicKey =.*/PublicKey = '${PUBKEY}'/g' /etc/wireguard/client.conf
sed -i 's/^PrivateKey =.*/PrivateKey = '${PRIKEY}'/g' /etc/wireguard/client.conf

#ufw allow 63665/udp
#wg-quick up wg0