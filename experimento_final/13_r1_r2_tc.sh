#!/bin/bash
# r1_r2_tc.sh — Aplica controle de banda no enlace PPP (rodar em R1 e R2)

IFACE=ppp0
RATE=115kbit    # ~115200 bps

# Remove configuração anterior, se houver
tc qdisc del dev $IFACE root 2>/dev/null

# Cria uma fila HTB com limite de banda total
tc qdisc add dev $IFACE root handle 1: htb default 10
tc class add dev $IFACE parent 1: classid 1:10 htb rate $RATE ceil $RATE

# (Opcional) Classe dedicada para o tráfego multicast do perfil WAN115K,
# priorizando-o dentro do limite total
tc class add dev $IFACE parent 1: classid 1:20 htb rate $RATE ceil $RATE
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 \
  match ip dst 239.20.0.0/16 flowid 1:20

tc qdisc show dev $IFACE
tc class show dev $IFACE