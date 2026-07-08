#!/bin/bash
# r1_conectividade.sh — Configuração básica de rede em R1

# Interface para a LAN #1 (172.16.0.0/16)
ip addr add 172.16.0.1/16 dev eth0
ip link set eth0 up

# Interface para a rede do Laboratório (endereço definido pelo laboratório)
# Ex.: 10.20.0.1/24 — ajustar conforme a rede real do Lab
ip addr add <IP_LAB>/24 dev eth1
ip link set eth1 up

# Enlace PPP serial R1 <-> R2 (RS-232 + pppd)
# /etc/ppp/peers/r2 deve conter as opções abaixo:
cat <<EOF > /etc/ppp/peers/r2
/dev/ttyS0 115200
noauth
local
10.0.0.1:10.0.0.2
persist
EOF

pon r2   # sobe o enlace PPP usando o arquivo de peer acima

# Rota estática para a LAN #2, via o enlace PPP
ip route add 192.168.0.0/24 via 10.0.0.2 dev ppp0

# Habilita encaminhamento de pacotes IP (roteador)
sysctl -w net.ipv4.ip_forward=1