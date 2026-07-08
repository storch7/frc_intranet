#!/bin/bash
# r1_snat.sh — Habilita Source NAT em R1

sysctl -w net.ipv4.ip_forward=1

# eth1 = interface de R1 conectada à rede do Laboratório (com saída à Internet)
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Permite o tráfego de retorno das conexões NATeadas
iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# Persistir regras (Debian/Ubuntu)
apt install -y iptables-persistent
netfilter-persistent save