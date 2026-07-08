#!/bin/bash
# r1_apache_proxy_final.sh — Ajusta proxy reverso final em R1

cat <<EOF > /etc/apache2/conf-available/miniiptv-proxy.conf
ProxyPreserveHost On
ProxyRequests Off

# Autenticação / OAuth2
ProxyPass "/auth/" "http://s.grupo4.lan:8080/auth/"
ProxyPassReverse "/auth/" "http://s.grupo4.lan:8080/auth/"

# API de canais e vídeos
ProxyPass "/api/" "http://s.grupo4.lan:8080/api/"
ProxyPassReverse "/api/" "http://s.grupo4.lan:8080/api/"

RequestHeader set X-Forwarded-Proto "https"
EOF

a2enconf miniiptv-proxy
systemctl reload apache2