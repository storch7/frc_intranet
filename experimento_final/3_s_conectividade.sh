#!/bin/bash
# s_conectividade.sh — Configuração básica de rede em S

ip addr add 172.16.0.2/16 dev eth0
ip link set eth0 up
ip route add default via 172.16.0.1 dev eth0