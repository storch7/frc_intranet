#!/bin/bash
# z_w_conectividade.sh — Configuração básica de rede em Z e W

ip addr add <IP_LAB_Z_OU_W>/24 dev eth0
ip link set eth0 up
ip route add default via <IP_LAB>  dev eth0   # IP de R1 na rede do Lab