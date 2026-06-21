#!/bin/bash

echo "Configurando respostas automáticas para a instalação do Postfix..."
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
debconf-set-selections <<< "postfix postfix/mailname string tapingando.com.br"

echo "Instalando Postfix, Dovecot e utilitários..."
apt update && apt install -y postfix dovecot-imapd dovecot-pop3d mailutils telnet

echo "Configurando o arquivo /etc/mailname..."
echo "tapingando.com.br" > /etc/mailname

echo "Fazendo backup e configurando o Postfix (/etc/postfix/main.cf)..."
cp /etc/postfix/main.cf /etc/postfix/main.cf.bkp

cat << 'EOF' > /etc/postfix/main.cf
myhostname = mail.tapingando.com.br
mydomain = tapingando.com.br
myorigin = /etc/mailname
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 127.0.0.0/8, 172.16.0.0/24, 192.168.0.0/24, 10.0.0.0/24
home_mailbox = Maildir/
smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination
EOF

echo "Reiniciando e habilitando o Postfix..."
systemctl restart postfix
systemctl start postfix

echo "Configurando o Dovecot (POP3/IMAP)..."
# Configura o local das caixas de correio
sed -i 's|#mail_location =|mail_location = maildir:~/Maildir|g' /etc/dovecot/conf.d/10-mail.conf

# Garante que os protocolos imap e pop3 estão ativos
echo "protocols = imap pop3" >> /etc/dovecot/dovecot.conf

echo "Reiniciando e habilitando o Dovecot..."
systemctl restart dovecot
systemctl start dovecot

echo "Criando usuários de teste (ana, bruno, carla, diego)..."
# A senha padrão para todos os usuários de teste será '123456'
for USUARIO in ana bruno carla diego; do
    if id "$USUARIO" &>/dev/null; then
        echo "Usuário $USUARIO já existe. Pulando criação."
    else
        useradd -m -s /bin/bash "$USUARIO"
        echo "$USUARIO:123456" | chpasswd
        echo "Usuário $USUARIO criado com sucesso."
    fi
    
    # Cria a estrutura de diretórios do Maildir para o usuário
    su - "$USUARIO" -c "maildirmake.dovecot ~/Maildir"
done

echo "Enviando e-mail de teste local de 'ana' para 'bruno'..."
echo "Teste de e-mail interno da intranet via script automatizado" | mail -s "Teste SMTP" bruno@tapingando.com.br

echo "========================================="
echo "Configuração concluída com sucesso!"
echo "Status do Postfix:"
systemctl status postfix --no-pager | head -n 3
echo "Status do Dovecot:"
systemctl status dovecot --no-pager | head -n 3
echo "========================================="
echo "Para testar a leitura do e-mail recebido pelo bruno, use:"
echo "telnet mail.tapingando.com.br 110"
echo "(USER bruno / PASS 123456 / LIST / RETR 1 / QUIT)"