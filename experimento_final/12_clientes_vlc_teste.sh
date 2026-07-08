#!/bin/bash
# clientes_vlc_teste.sh — Recebe stream multicast de teste

# Perfil LAN (Z, W) — canal em alta qualidade
cvlc udp://@239.10.4.1:5004

# Perfil WAN115K (X, Y) — canal em baixa qualidade (após configurar o tc na Etapa 5)
# cvlc udp://@239.20.4.1:5004