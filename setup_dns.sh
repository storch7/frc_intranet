#!/bin/bash

echo "Atualizando pacotes e instalando BIND9 e dnsutils..."
apt update && apt install -y bind9 dnsutils

echo "Configurando /etc/bind/named.conf.options..."
cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { 127.0.0.1; 172.16.0.0/24; 192.168.0.0/24; 10.0.0.0/24; };
    forwarders { 1.1.1.1; 8.8.8.8; };
    dnssec-validation auto;
    listen-on { 127.0.0.1; 172.16.0.2; };
    listen-on-v6 { none; };
};
EOF

echo "Declarando as zonas em /etc/bind/named.conf.local..."
cat << 'EOF' > /etc/bind/named.conf.local
zone "tapingando.com.br" {
    type master;
    file "/etc/bind/db.tapingando.com.br";
};

zone "16.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.172.16";
};

zone "168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168";
};
EOF

echo "Criando zona direta (tapingando.com.br)..."
cat << 'EOF' > /etc/bind/db.tapingando.com.br
$TTL 604800
@   IN  SOA ns.tapingando.com.br. admin.tapingando.com.br. (
            2026061801
            604800
            86400
            2419200
            604800 )
@   IN  NS  ns.tapingando.com.br.
@   IN  MX  10 mail.tapingando.com.br.
ns        IN  A   172.16.0.2
mail      IN  A   172.16.0.2
www       IN  A   172.16.0.2
intranet  IN  A   172.16.0.2
servidor  IN  A   172.16.0.2
r1        IN  A   172.16.0.1
r2        IN  A   192.168.0.1
cliente-x IN  A   192.168.0.2
cliente-y IN  A   192.168.0.3
EOF

echo "Criando zona reversa (172.16)..."
cat << 'EOF' > /etc/bind/db.172.16
$TTL 604800
@   IN  SOA ns.tapingando.com.br. admin.tapingando.com.br. (
            2026061801
            604800
            86400
            2419200
            604800 )
@   IN  NS  ns.tapingando.com.br.
2.0 IN  PTR ns.tapingando.com.br.
2.0 IN  PTR servidor.tapingando.com.br.
2.0 IN  PTR www.tapingando.com.br.
2.0 IN  PTR mail.tapingando.com.br.
1.0 IN  PTR r1.tapingando.com.br.
EOF

echo "Criando zona reversa (192.168)..."
cat << 'EOF' > /etc/bind/db.192.168
$TTL 604800
@   IN  SOA ns.tapingando.com.br. admin.tapingando.com.br. (
            2026061801
            604800
            86400
            2419200
            604800 )
@   IN  NS  ns.tapingando.com.br.
1.0   IN  PTR r2.tapingando.com.br.
2.0   IN  PTR cliente-x.tapingando.com.br.
3.0   IN  PTR cliente-y.tapingando.com.br.
EOF

echo "Verificando as configurações do BIND9..."
named-checkconf
named-checkzone tapingando.com.br /etc/bind/db.tapingando.com.br
named-checkzone 16.172.in-addr.arpa /etc/bind/db.172.16
named-checkzone 168.192.in-addr.arpa /etc/bind/db.192.168

echo "Reiniciando e habilitando o serviço BIND9..."
systemctl restart bind9
systemctl start bind9

echo "Status final do BIND9:"
systemctl status bind9 --no-pager | head -n 10
echo "Configuração concluída com sucesso!"