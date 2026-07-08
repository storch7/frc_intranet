#!/bin/bash
# r2_conectividade.sh — Configuração básica de rede em R2

# Interface para a LAN #2 (192.168.0.0/24)
ip addr add 192.168.0.1/24 dev eth0
ip link set eth0 up

# Enlace PPP serial R2 <-> R1
cat <<EOF > /etc/ppp/peers/r1
/dev/ttyS0 115200
noauth
local
10.0.0.2:10.0.0.1
persist
EOF

pon r1

# Rota específica para a LAN #1
ip route add 172.16.0.0/16 via 10.0.0.1 dev ppp0

# Rota padrão: cobre a rede do Laboratório e a Internet, via R1
ip route add default via 10.0.0.1 dev ppp0

sysctl -w net.ipv4.ip_forward=1