#!/bin/bash
# s_smtp.sh — Configura servidor SMTP (Postfix) em S

DEBIAN_FRONTEND=noninteractive apt install -y postfix

postconf -e 'myhostname = s.grupo4.lan'
postconf -e 'mydomain = grupo4.lan'
postconf -e 'myorigin = /etc/mailname'
echo "grupo4.lan" > /etc/mailname
postconf -e 'inet_interfaces = all'
postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
postconf -e 'mynetworks = 172.16.0.0/16, 192.168.0.0/24, 127.0.0.0/8'

systemctl restart postfix
systemctl enable postfix