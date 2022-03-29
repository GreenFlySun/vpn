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

touch /etc/wireguard/wg0.conf

echo -e "[Interface] \n
Address = 10.66.66.1/24,fd42:42:42::1/64 \n
ListenPort = 63665 \n
PrivateKey = ${PRIKEY} \n
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE \n
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s8 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o enp0s8 -j MASQUERADE \n
[Peer] \n
PublicKey = ${PUBKEY} \n 
AllowedIPs = 10.66.66.2/32,fd42:42:42::2/128" > /etc/wireguard/wg0.conf

#sed -i 's/^PublicKey =.*/PublicKey = '${PUBKEY}'/g' /etc/wireguard/wg0.conf
#sed -i 's/^PrivateKey =.*/PrivateKey = '${PRIKEY}'/g' /etc/wireguard/wg0.conf

#systemctl start wg-quick@wg0
#systemctl enable wg-quick@wg0
#ufw allow 63665/udp
interfaces=$(find /etc/wireguard -type f -name '*.conf')
if [[ -z $interfaces ]]; then
    echo "$(date): Interface not found in /etc/wireguard" >&2
    exit 1
fi

interface=$( basename  $(echo $interfaces | head -n 1 ) .conf)

echo "$(date): Starting Wireguard"
wg-quick up $interface 
finish () {
    echo "$(date): Shutting down Wireguard"
    wg-quick down $interface
    exit 0
}

trap finish SIGTERM SIGINT SIGQUIT

sleep infinity &
wait $!
