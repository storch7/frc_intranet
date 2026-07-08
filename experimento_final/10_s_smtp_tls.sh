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