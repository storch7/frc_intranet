#!/bin/bash
# preparar_ambiente.sh
# Para (sem desinstalar) serviços do Ubuntu que costumam interferir em
# roteamento, NAT/iptables, DNS e multicast durante o experimento Mini-IPTV.
#
# Uso: sudo ./preparar_ambiente.sh
# Rodar em CADA host (S, R1, R2, X, Y, Z, W) antes dos testes/apresentação.

set -e

echo "== Parando serviços que podem interferir na rede =="

servicos=(
  docker
  containerd
  NetworkManager
  systemd-resolved
  ModemManager
  avahi-daemon
  cups-browsed
  ufw
  firewalld
  libvirtd
)

for s in "${servicos[@]}"; do
  if systemctl list-unit-files | grep -q "^${s}.service"; then
    echo "-> Parando $s"
    sudo systemctl stop "$s" 2>/dev/null || true
    sudo systemctl disable "$s" 2>/dev/null || true
  fi
done

# systemd-resolved deixa /etc/resolv.conf apontando para 127.0.0.53
# Trocar para resolução direta (necessário para o bind9 assumir a porta 53)
if [ -L /etc/resolv.conf ]; then
  echo "-> Ajustando /etc/resolv.conf (tirando o stub do systemd-resolved)"
  sudo rm -f /etc/resolv.conf
  echo "nameserver 172.16.0.2" | sudo tee /etc/resolv.conf
fi

# Limpar bridges/regras deixadas pelo Docker, se ele tiver rodado antes
if command -v docker &>/dev/null; then
  echo "-> Removendo interface docker0 (se existir)"
  sudo ip link set docker0 down 2>/dev/null || true
  sudo ip link delete docker0 2>/dev/null || true
fi

echo ""
echo "== Estado atual das regras iptables (revisar manualmente) =="
sudo iptables -L -n -v
echo ""
sudo iptables -t nat -L -n -v

echo ""
echo "== Serviços de rede ainda ativos (conferir se sobrou algo indesejado) =="
systemctl list-units --type=service --state=running | grep -Ei \
  'network|dns|dhcp|resolv|firewall|proxy|docker|virt' || true

echo ""
echo "Ambiente preparado. Lembre de rodar restaurar_ambiente.sh ao final dos testes."