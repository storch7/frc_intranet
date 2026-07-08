# Scripts de Configuração — Projeto Mini-IPTV Multicast com Controle de Banda WAN
### FRC — Fundamentos de Redes de Computadores

> **Premissas assumidas:**
> - R1, R2 e S são máquinas Linux (Debian/Ubuntu). Ajuste os nomes de pacotes se usarem outra distro (ex. Alpine no pendrive de boot).
> - Interfaces de exemplo: `eth0` (LAN), `eth1` (segunda LAN/laboratório), `ppp0` (enlace serial PPP). Troque pelos nomes reais (`ip a` para conferir).
> - Endereçamento: LAN#1 `172.16.0.0/16`, LAN#2 `192.168.0.0/24`, link PPP `10.0.0.0/30`.
> - Grupo de exemplo: **Grupo 4** (ajustem o terceiro octeto multicast para o ID real do grupo).
> - Todos os comandos são para teste/desenvolvimento em laboratório. Persistam as configs em arquivos (`/etc/network/interfaces`, `netplan`, etc.) conforme a distro, não apenas via `ip`/`iptables` em runtime — isso é só o "esqueleto" e deve virar parte dos roteiros de instalação do relatório.

---

## ETAPA 1 — Conectividade IP básica (sem multicast)

### 1.1 — Equipamento: R1

**O que o script faz:** configura as duas interfaces locais de R1 (LAN#1 e rede do Laboratório), sobe o enlace PPP com R2 a 115200 bps e cadastra rota estática para a LAN#2 (via R2).

```bash
#!/bin/bash
# r1_conectividade.sh — Configuração básica de rede em R1

# Interface para a LAN #1 (172.16.0.0/16)
ip addr add 172.16.0.1/16 dev eth0
ip link set eth0 up

# Interface para a rede do Laboratório (endereço definido pelo laboratório)
# Ex.: 10.20.0.1/24 — ajustar conforme a rede real do Lab
ip addr add <IP_LAB>/24 dev eth1
ip link set eth1 up

# Enlace PPP serial R1 <-> R2 (RS-232 + pppd)
# /etc/ppp/peers/r2 deve conter as opções abaixo:
cat <<EOF > /etc/ppp/peers/r2
/dev/ttyS0 115200
noauth
local
10.0.0.1:10.0.0.2
persist
EOF

pon r2   # sobe o enlace PPP usando o arquivo de peer acima

# Rota estática para a LAN #2, via o enlace PPP
ip route add 192.168.0.0/24 via 10.0.0.2 dev ppp0

# Habilita encaminhamento de pacotes IP (roteador)
sysctl -w net.ipv4.ip_forward=1
```

---

### 1.2 — Equipamento: R2

**O que o script faz:** configura a interface de R2 voltada para a LAN#2, sobe o lado servidor do enlace PPP e cadastra rota estática de volta para a LAN#1 e para a rede do Laboratório.

```bash
#!/bin/bash
# r2_conectividade.sh — Configuração básica de rede em R2

# Interface para a LAN #2 (192.168.0.0/24)
ip addr add 192.168.0.1/24 dev eth0
ip link set eth0 up

# Enlace PPP serial R2 <-> R1
cat <<EOF > /etc/ppp/peers/r1
/dev/ttyS0 115200
noauth
local
10.0.0.2:10.0.0.1
persist
EOF

pon r1

# Rotas estáticas: LAN#1 e rede do Laboratório, via o enlace PPP
ip route add 172.16.0.0/16 via 10.0.0.1 dev ppp0
ip route add <REDE_LAB>/24 via 10.0.0.1 dev ppp0

sysctl -w net.ipv4.ip_forward=1
```

---

### 1.3 — Equipamento: S (servidor multimídia)

**O que o script faz:** atribui IP estático a S na LAN#1 e define R1 como gateway padrão.

```bash
#!/bin/bash
# s_conectividade.sh — Configuração básica de rede em S

ip addr add 172.16.0.2/16 dev eth0
ip link set eth0 up
ip route add default via 172.16.0.1 dev eth0
```

---

### 1.4 — Equipamento: X e Y (clientes WAN115K)

**O que o script faz:** nada a configurar manualmente — X e Y recebem IP dinâmico via DHCP (servido por R2, ver Etapa 2). Este script serve apenas para forçar a renovação/teste do lease.

```bash
#!/bin/bash
# x_y_conectividade.sh — Solicita/renova endereço via DHCP

dhclient -r eth0   # libera lease anterior, se houver
dhclient eth0      # solicita novo endereço a R2
ip a show eth0
ip route show
```

---

### 1.5 — Equipamento: Z e W (clientes LAN, no Laboratório)

**O que o script faz:** atribui IP estático dentro da rede do Laboratório e define R1 como gateway (Z e W enxergam R1 diretamente, pois estão na mesma rede física que a segunda interface de R1).

```bash
#!/bin/bash
# z_w_conectividade.sh — Configuração básica de rede em Z e W

ip addr add <IP_LAB_Z_OU_W>/24 dev eth0
ip link set eth0 up
ip route add default via <IP_LAB>  dev eth0   # IP de R1 na rede do Lab
```

---

## ETAPA 2 — Serviços de intranet

### 2.1 — Equipamento: S — DNS Server (bind9)

**O que o script faz:** instala o BIND9 e cria uma zona direta simples mapeando os nomes de domínio de S, R1 e R2 para seus IPs estáticos.

```bash
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
```

---

### 2.2 — Equipamento: S — SMTP Server (Postfix)

**O que o script faz:** instala o Postfix em modo "Internet Site" e configura o domínio local do grupo, permitindo envio/recebimento de e-mail dentro da intranet (a versão com TLS/STARTTLS entra na Etapa 3).

```bash
#!/bin/bash
# s_smtp.sh — Configura servidor SMTP (Postfix) em S

DEBIAN_FRONTEND=noninteractive apt install -y postfix

postconf -e 'myhostname = s.grupo4.lan'
postconf -e 'mydomain = grupo4.lan'
postconf -e 'myorigin = /etc/mailname'
echo "grupo4.lan" > /etc/mailname
postconf -e 'inet_interfaces = all'
postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
postconf -e 'mynetworks = 172.16.0.0/16, 192.168.0.0/24, 127.0.0.0/8'

systemctl restart postfix
systemctl enable postfix
```

---

### 2.3 — Equipamento: R2 — DHCP Server (isc-dhcp-server)

**O que o script faz:** instala e configura o servidor DHCP em R2, oferecendo IPs dinâmicos, gateway e DNS para X e Y na LAN#2.

```bash
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
```

---

### 2.4 — Equipamento: R1 — Web Server / API Gateway (Apache, proxy reverso)

**O que o script faz:** instala o Apache, publica a página HTML estática da intranet do grupo e habilita `mod_proxy`/`mod_proxy_http` para repassar as requisições de API para o backend em S (a rota `/api/` completa é detalhada na Etapa 7, depois que o backend existir).

```bash
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
```

---

## ETAPA 3 — NAT e segurança de borda

### 3.1 — Equipamento: R1 — Source NAT (Internet compartilhada)

**O que o script faz:** habilita mascaramento de endereço (SNAT/MASQUERADE) na interface de R1 conectada ao Laboratório, permitindo que S, R2, X e Y (que não têm rota direta à Internet) saiam através de R1.

```bash
#!/bin/bash
# r1_snat.sh — Habilita Source NAT em R1

sysctl -w net.ipv4.ip_forward=1

# eth1 = interface de R1 conectada à rede do Laboratório (com saída à Internet)
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Permite o tráfego de retorno das conexões NATeadas
iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# Persistir regras (Debian/Ubuntu)
apt install -y iptables-persistent
netfilter-persistent save
```

---

### 3.2 — Equipamento: R1 — iptables (filtragem básica)

**O que o script faz:** aplica uma política básica de firewall em R1: bloqueia por padrão tráfego não solicitado vindo da Internet/Laboratório para dentro da intranet, liberando apenas os serviços necessários (web/API, DNS, SMTP).

```bash
#!/bin/bash
# r1_iptables.sh — Regras de filtragem em R1

# Política padrão: bloquear entrada não solicitada vinda de fora
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Libera loopback e conexões já estabelecidas
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Libera SSH para administração (ajustar interface/rede de origem)
iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/16 -j ACCEPT

# Libera HTTP/HTTPS (API Gateway) vindos da LAN#2 (X, Y) e do enlace PPP
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT

# Libera repasse de DNS e SMTP para S
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 25 -j ACCEPT
iptables -A FORWARD -p tcp --dport 587 -j ACCEPT   # submission/STARTTLS

netfilter-persistent save
```

---

### 3.3 — Equipamento: S — E-mail seguro (Postfix + TLS/STARTTLS)

**O que o script faz:** gera um certificado autoassinado e habilita STARTTLS no Postfix, permitindo conexão segura a partir de um cliente como o Thunderbird.

```bash
#!/bin/bash
# s_smtp_tls.sh — Habilita STARTTLS no Postfix (S)

mkdir -p /etc/ssl/postfix
openssl req -new -x509 -days 365 -nodes \
  -out /etc/ssl/postfix/smtp.crt \
  -keyout /etc/ssl/postfix/smtp.key \
  -subj "/CN=s.grupo4.lan"

postconf -e 'smtpd_tls_cert_file = /etc/ssl/postfix/smtp.crt'
postconf -e 'smtpd_tls_key_file = /etc/ssl/postfix/smtp.key'
postconf -e 'smtpd_use_tls = yes'
postconf -e 'smtpd_tls_auth_only = yes'
postconf -e 'smtpd_tls_security_level = may'
postconf -e 'smtp_tls_security_level = may'

# Habilita autenticação SASL (necessária para envio autenticado pelo Thunderbird)
apt install -y libsasl2-modules sasl2-bin
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_sasl_type = dovecot'
postconf -e 'smtpd_sasl_path = private/auth'

# Habilita a porta de submission (587) com STARTTLS
sed -i '/^#submission/,/^$/ s/^#//' /etc/postfix/master.cf

systemctl restart postfix
```

> No cliente Thunderbird: configurar servidor de saída (SMTP) `s.grupo4.lan`, porta `587`, segurança `STARTTLS`, autenticação normal (usuário/senha).

---

## ETAPA 4 — Roteamento multicast

### 4.1 — Equipamento: R1 e R2 — PIM Dense Mode (pimd)

**O que o script faz:** instala e habilita o daemon PIM-DM nas interfaces relevantes de cada roteador, permitindo que tráfego multicast (grupos 239.10.x.x e 239.20.x.x) seja encaminhado entre a LAN#1, o enlace PPP e a LAN#2.

```bash
#!/bin/bash
# r1_r2_pim.sh — Habilita roteamento multicast (PIM-DM) — rodar em R1 e em R2

apt update && apt install -y pimd

sysctl -w net.ipv4.conf.all.mc_forwarding=1

# Exemplo de /etc/pimd.conf — listar TODAS as interfaces do roteador
cat <<EOF > /etc/pimd.conf
phyint eth0 enable
phyint eth1 enable
phyint ppp0 enable
EOF

systemctl restart pimd
systemctl enable pimd
```

> **Observação:** ajustar a lista de `phyint` conforme as interfaces reais de cada roteador (R1: eth0/eth1/ppp0; R2: eth0/ppp0). Após subir o `pimd`, validar com `pimd -c` ou logs em `/var/log/syslog`.

---

### 4.2 — Equipamento: S — Iniciar transmissão multicast de teste (VLC)

**O que o script faz:** inicia, via linha de comando, uma transmissão VLC de um vídeo de teste para um endereço multicast do Grupo 4, perfil LAN (canal 1).

```bash
#!/bin/bash
# s_vlc_stream_teste.sh — Testa transmissão multicast a partir de S

cvlc -vvv v_original.mp4 \
  --sout '#duplicate{dst=udp{dst=239.10.4.1:5004}}' \
  --loop
```

---

### 4.3 — Equipamento: Z, W, X, Y — Cliente VLC recebendo multicast

**O que o script faz:** abre o VLC como cliente, apontando para o grupo multicast do canal de teste, para validar a recepção em cada perfil de rede.

```bash
#!/bin/bash
# clientes_vlc_teste.sh — Recebe stream multicast de teste

# Perfil LAN (Z, W) — canal em alta qualidade
cvlc udp://@239.10.4.1:5004

# Perfil WAN115K (X, Y) — canal em baixa qualidade (após configurar o tc na Etapa 5)
# cvlc udp://@239.20.4.1:5004
```

---

## ETAPA 5 — Controle de banda no enlace WAN (tc)

### 5.1 — Equipamento: R1 e R2 — Limitação de banda no enlace PPP

**O que o script faz:** aplica uma disciplina de fila (`tc`) na interface do enlace PPP, garantindo que o tráfego que passa por ele respeite o limite de 115200 bps — simulando/reforçando a característica do enlace WAN mesmo que o hardware/serial já limite a taxa fisicamente.

```bash
#!/bin/bash
# r1_r2_tc.sh — Aplica controle de banda no enlace PPP (rodar em R1 e R2)

IFACE=ppp0
RATE=115kbit    # ~115200 bps

# Remove configuração anterior, se houver
tc qdisc del dev $IFACE root 2>/dev/null

# Cria uma fila HTB com limite de banda total
tc qdisc add dev $IFACE root handle 1: htb default 10
tc class add dev $IFACE parent 1: classid 1:10 htb rate $RATE ceil $RATE

# (Opcional) Classe dedicada para o tráfego multicast do perfil WAN115K,
# priorizando-o dentro do limite total
tc class add dev $IFACE parent 1: classid 1:20 htb rate $RATE ceil $RATE
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 \
  match ip dst 239.20.0.0/16 flowid 1:20

tc qdisc show dev $IFACE
tc class show dev $IFACE
```

**Para verificar a ocupação da WAN (usado depois no painel administrativo):**

```bash
tc -s class show dev ppp0
```

---

## ETAPA 6 — Backend da aplicação Mini-IPTV

### 6.1 — Equipamento: S — Ambiente do backend (Node.js + Express, exemplo)

**O que o script faz:** instala o runtime e as dependências básicas do backend (API REST, autenticação, controle de canais/vídeos) e cria a estrutura mínima do projeto.

```bash
#!/bin/bash
# s_backend_setup.sh — Prepara ambiente do backend em S

apt update && apt install -y nodejs npm ffmpeg

mkdir -p /opt/miniiptv-backend && cd /opt/miniiptv-backend
npm init -y
npm install express jsonwebtoken bcrypt sqlite3 dotenv openid-client

mkdir -p src/{routes,models,controllers}
touch src/server.js
```

> O conteúdo de `server.js`, rotas de canais/vídeos, integração OAuth2/OIDC e controle do processo VLC (start/stop via `child_process`) é código de aplicação — posso gerar esses arquivos também, se vocês definirem a stack (Node/Express, Python/Flask, etc.) e o modelo de dados que pretendem usar.

---

### 6.2 — Equipamento: S — Conversão de vídeos (ffmpeg) — script de cadastro

**O que o script faz:** automatiza a geração da versão de baixa qualidade de um vídeo (perfil WAN115K) a partir do original, conforme o comando de referência do enunciado (Obs.1).

```bash
#!/bin/bash
# s_ffmpeg_convert.sh — Gera versão de baixa qualidade de um vídeo
# Uso: ./s_ffmpeg_convert.sh v_original.mp4 v_wan.mp4

ORIGINAL=$1
SAIDA=$2

ffmpeg -i "$ORIGINAL" -c:v libx264 -b:v 80k -r 10 -s 320x240 \
  -c:a aac -b:a 16k -ac 1 -ar 22050 "$SAIDA"
```

---

### 6.3 — Equipamento: S — Extração de metadados (ffprobe)

**O que o script faz:** extrai duração, resolução, bitrate e codecs de um vídeo, para uso no cadastro administrativo.

```bash
#!/bin/bash
# s_ffprobe_metadata.sh — Extrai metadados de um vídeo
# Uso: ./s_ffprobe_metadata.sh v_original.mp4

ffprobe -v quiet -print_format json -show_format -show_streams "$1"
```

---

## ETAPA 7 — Integração Backend + VLC Server + API Gateway

### 7.1 — Equipamento: R1 — Ajuste fino do proxy reverso (rotas completas da API)

**O que o script faz:** refina o bloco de proxy do Apache (criado na Etapa 2) para repassar corretamente todas as rotas da API (autenticação, canais, admin) ao backend em S, mantendo cabeçalhos de origem.

```bash
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
```

---

## ETAPA 8 — Frontend + VLC Client

### 8.1 — Equipamento: X, Y, Z, W — Ativação do VLC Client via playlist m3u

**O que o script faz:** simula o comportamento do frontend: busca a playlist do canal (servida pelo backend, via API Gateway) e abre o VLC Client automaticamente.

```bash
#!/bin/bash
# cliente_playlist.sh — Busca playlist do canal e abre no VLC Client

# Endpoint da API Gateway (via R1) que devolve a playlist do canal escolhido
curl -s https://r1.grupo4.lan/api/canais/1/playlist -o canal1.m3u

cvlc canal1.m3u
```

---

## Resumo — o que rodar em cada equipamento, em ordem

| Ordem | Equipamento | Scripts |
|---|---|---|
| 1 | R1 | `r1_conectividade.sh` | ok
| 2 | R2 | `r2_conectividade.sh` |
| 3 | S | `s_conectividade.sh` |
| 4 | Z, W | `z_w_conectividade.sh` |
| 5 | X, Y | `x_y_conectividade.sh` (após DHCP no R2) |
| 6 | S | `s_dns.sh`, `s_smtp.sh` |
| 7 | R2 | `r2_dhcp.sh` |
| 8 | R1 | `r1_apache.sh` |
| 9 | R1 | `r1_snat.sh`, `r1_iptables.sh` |
| 10 | S | `s_smtp_tls.sh` |
| 11 | R1, R2 | `r1_r2_pim.sh` |
| 12 | S / clientes | `s_vlc_stream_teste.sh`, `clientes_vlc_teste.sh` |
| 13 | R1, R2 | `r1_r2_tc.sh` |
| 14 | S | `s_backend_setup.sh`, `s_ffmpeg_convert.sh`, `s_ffprobe_metadata.sh` |
| 15 | R1 | `r1_apache_proxy_final.sh` |
| 16 | X, Y, Z, W | `cliente_playlist.sh` |

