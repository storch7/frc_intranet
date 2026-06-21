#!/bin/bash

echo "Instalando o Kea DHCP Server..."
apt update && apt install -y kea-dhcp4-server

echo "Fazendo backup da configuração original..."
cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bkp

echo "Gerando nova configuração do Kea (Cenário com Relay)..."
cat << 'EOF' > /etc/kea/kea-dhcp4.conf
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "eth0" ],
      "dhcp-socket-type": "udp"
    },
    "lease-database": {
      "type": "memfile",
      "persist": true,
      "name": "/var/lib/kea/kea-leases4.csv"
    },
    "valid-lifetime": 3600,
    "renew-timer": 900,
    "rebind-timer": 1800,
    "subnet4": [
      {
        "id": 1,
        "subnet": "192.168.0.0/24",
        "pools": [ { "pool": "192.168.0.100 - 192.168.0.200" } ],
        "option-data": [
          { "name": "routers", "data": "192.168.0.1" },
          { "name": "domain-name-servers", "data": "172.16.0.2" },
          { "name": "domain-name", "data": "tapingando.com.br" }
        ]
      }
    ],
    "loggers": [
      {
        "name": "kea-dhcp4",
        "output_options": [ { "output": "/var/log/kea-dhcp4.log" } ],
        "severity": "INFO"
      }
    ]
  }
}
EOF

echo "Testando a sintaxe da configuração..."
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

echo "Reiniciando o serviço Kea DHCP..."
systemctl restart kea-dhcp4-server
systemctl start kea-dhcp4-server
systemctl status kea-dhcp4-server --no-pager | head -n 10