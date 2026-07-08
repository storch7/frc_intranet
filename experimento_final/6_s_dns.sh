#!/bin/bash
# s_dns.sh — Configura servidor DNS (bind9) em S

apt update && apt install -y bind9 bind9utils

cat <<EOF >> /etc/bind/named.conf.local
zone "grupo4.lan" {
    type master;
    file "/etc/bind/db.grupo4.lan";
};
EOF

cat <<EOF > /etc/bind/db.grupo4.lan
\$TTL    604800
@       IN      SOA     s.grupo4.lan. admin.grupo4.lan. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      s.grupo4.lan.
s       IN      A       172.16.0.2
r1      IN      A       172.16.0.1
r2      IN      A       192.168.0.1
EOF

systemctl restart bind9
systemctl enable bind9