#!/bin/bash

# Update & install software
apt-get update
apt-get install -y hostapd dnsmasq iptables-persistent

# Configure dnsmasq
cp dnsmasq.conf /etc/dnsmasq.conf

# Set up interfaces file for wlan0
cp interfaces /etc/interfaces.d/tornado

# Configure hostapd.conf
cp hostapd.conf /etc/hostapd/hostapd.conf

sed -i '/#DAEMON_CONF=""/c\
DAEMON_CONF="/etc/hostapd/hostapd.conf"' /etc/default/hostapd

sed -i '/DAEMON_CONF=/c\
DAEMON_CONF=/etc/hostapd/hostapd.conf' /etc/init.d/hostapd

# Enable ipv4 forwarding
sed -i '/#net.ipv4.ip_forward=1/c\
net.ipv4.ip_forward=1' /etc/sysctl.conf

echo 1 > /proc/sys/net/ipv4/ip_forward

# Update iptables rules
iptables -t nat -A PREROUTING -i wlan0 -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i wlan0 -p udp -m udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i wlan0 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
iptables-save > /etc/iptables/rules.v4

# Start hostapd and dnsmasq and enable them on boot
service hostapd start
service dnsmasq start

update-rc.d hostapd enable
update-rc.d dnsmasq enable
