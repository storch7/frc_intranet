#!/bin/bash
# r1_conectividade.sh — Configuração básica de rede em R1

# Interface para a LAN #1 (172.16.0.0/16)
ip addr flush dev enxd03745ca6106
ip addr add 172.16.0.1/16 dev enxd03745ca6106
ip link set enxd03745ca6106 up

# Interface para a rede do Laboratório
ip addr flush dev enp0s31f6
ip addr add 10.10.31.197/24 dev enp0s31f6
ip link set enp0s31f6 up

# Enlace PPP serial R1 <-> R2 (RS-232 + pppd)
cat <<EOF > /etc/ppp/peers/r2
/dev/ttyS0 115200
noauth
local
10.0.0.1:10.0.0.2
persist
EOF

pon r2

echo "Aguardando enlace PPP subir..."
for i in $(seq 1 20); do
  if ip link show ppp0 up &>/dev/null; then
    echo "ppp0 está up."
    break
  fi
  sleep 1
done

# Rota estática para a LAN #2, via o enlace PPP
ip route replace 192.168.0.0/24 via 10.0.0.2 dev ppp0

sysctl -w net.ipv4.ip_forward=1