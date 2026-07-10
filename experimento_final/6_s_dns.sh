#!/bin/bash
# s_dns.sh — Configura servidor DNS (bind9) em S

apt update && apt install -y bind9 bind9utils

cat <<EOF >> /etc/bind/named.conf.local
zone "lab.tapingando.com.br" {
    type master;
    file "/etc/bind/db.lab.tapingando.com.br";
};
EOF

cat <<EOF > /etc/bind/db.lab.tapingando.com.br
\$TTL    604800
@       IN      SOA     s.lab.tapingando.com.br. admin.lab.tapingando.com.br. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      s.lab.tapingando.com.br.
s       IN      A       172.16.0.2
r1      IN      A       172.16.0.1
r2      IN      A       192.168.0.1
EOF

systemctl restart bind9
systemctl enable bind9