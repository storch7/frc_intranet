#!/bin/bash
# r1_r2_pim.sh — Habilita roteamento multicast (PIM-DM) — rodar em R1 e em R2

apt update && apt install -y pimd

sysctl -w net.ipv4.conf.all.mc_forwarding=1

# Exemplo de /etc/pimd.conf — listar TODAS as interfaces do roteador
cat <<EOF > /etc/pimd.conf
phyint eth0 enable
phyint eth1 enable
phyint ppp0 enable
EOF

systemctl restart pimd
systemctl enable pimd