#!/bin/bash
# restaurar_ambiente.sh
# Reativa os serviços que foram parados/desabilitados por preparar_ambiente.sh,
# devolvendo a máquina ao estado normal de uso (fora do experimento).
#
# Uso: sudo ./restaurar_ambiente.sh

set -e

echo "== Reativando serviços =="

servicos=(
  NetworkManager
  systemd-resolved
  ModemManager
  avahi-daemon
  cups-browsed
  ufw
  docker
  containerd
)

for s in "${servicos[@]}"; do
  if systemctl list-unit-files | grep -q "^${s}.service"; then
    echo "-> Reativando $s"
    sudo systemctl enable "$s" 2>/dev/null || true
    sudo systemctl start "$s" 2>/dev/null || true
  fi
done

# Restaurar resolv.conf gerenciado pelo systemd-resolved
if [ ! -L /etc/resolv.conf ]; then
  echo "-> Restaurando /etc/resolv.conf para o padrão do systemd-resolved"
  sudo rm -f /etc/resolv.conf
  sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

echo ""
echo "Ambiente restaurado. Confira com 'systemctl status NetworkManager docker' se necessário."