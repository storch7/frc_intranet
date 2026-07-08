#!/bin/bash
# r2_dhcp.sh — Configura servidor DHCP em R2 para a LAN #2

apt update && apt install -y isc-dhcp-server

cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.100 192.168.0.200;
  option routers 192.168.0.1;
  option domain-name-servers 172.16.0.2;
  option domain-name "grupo4.lan";
}
EOF

# Define a interface onde o DHCP deve escutar (a interface da LAN#2)
sed -i 's/INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server