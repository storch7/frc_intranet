#!/bin/bash
# r1_apache.sh — Configura Apache como servidor web + API Gateway em R1

apt update && apt install -y apache2

a2enmod proxy proxy_http ssl headers

# Página estática da intranet
mkdir -p /var/www/html
cat <<EOF > /var/www/html/index.html
<html><body><h1>Intranet Grupo 4 — Mini-IPTV</h1></body></html>
EOF

# Bloco de proxy reverso (repassa /api para o backend em S)
cat <<EOF > /etc/apache2/conf-available/miniiptv-proxy.conf
ProxyPreserveHost On
ProxyPass "/api/" "http://s.grupo4.lan:8080/api/"
ProxyPassReverse "/api/" "http://s.grupo4.lan:8080/api/"
EOF

a2enconf miniiptv-proxy
systemctl restart apache2
systemctl enable apache2