#!/bin/bash
# r1_iptables.sh — Regras de filtragem em R1

# Política padrão: bloquear entrada não solicitada vinda de fora
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Libera loopback e conexões já estabelecidas
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Libera SSH para administração (ajustar interface/rede de origem)
iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/16 -j ACCEPT

# Libera HTTP/HTTPS (API Gateway) vindos da LAN#2 (X, Y) e do enlace PPP
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT

# Libera repasse de DNS e SMTP para S
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 25 -j ACCEPT
iptables -A FORWARD -p tcp --dport 587 -j ACCEPT   # submission/STARTTLS

netfilter-persistent save