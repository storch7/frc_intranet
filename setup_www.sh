#!/bin/bash

echo "Instalando o servidor web Nginx..."
apt update && apt install -y nginx

echo "Criando o diretório da intranet..."
mkdir -p /var/www/intranet

echo "Gerando a página principal (index.html)..."
cat << 'EOF' > /var/www/intranet/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Intranet da Empresa Tapingando</title>
</head>
<body>
    <h1>Intranet da Empresa Tapingando</h1>
    <h2>Serviços configurados</h2>
    <ul>
        <li>DHCP: distribuição automática de IP para clientes da LAN #2</li>
        <li>DNS: resolução do domínio tapingando.com.br</li>
        <li>SMTP/POP3: serviço de e-mail interno</li>
        <li>WWW: página principal da intranet</li>
    </ul>

    <h2>Mapa da rede</h2>
    <pre>
    Servidor S: 172.16.0.2
    R1 LAN:    172.16.0.1
    R1 PPP:    10.0.0.1
    R2 PPP:    10.0.0.2
    R2 LAN:    192.168.0.1
    Cliente X: 192.168.0.2
    Cliente Y: 192.168.0.3
    </pre>
</body>
</html>
EOF

echo "Criando o arquivo de configuração do site no Nginx..."
cat << 'EOF' > /etc/nginx/sites-available/intranet
server {
    listen 80;
    server_name www.tapingando.com.br intranet.tapingando.com.br tapingando.com.br;

    root /var/www/intranet;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

echo "Ativando o site da intranet e removendo a configuração padrão..."
# Cria o link simbólico para ativar o site
ln -sf /etc/nginx/sites-available/intranet /etc/nginx/sites-enabled/intranet
# Remove o site padrão para evitar conflitos na porta 80
rm -f /etc/nginx/sites-enabled/default

echo "Testando a sintaxe da configuração do Nginx..."
nginx -t

echo "Reiniciando e habilitando o serviço Nginx..."
systemctl restart nginx
systemctl start nginx

echo "========================================="
echo "Configuração do WWW concluída com sucesso!"
echo "Status do Nginx:"
systemctl status nginx --no-pager | head -n 5
echo "========================================="