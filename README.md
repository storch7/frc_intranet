# INTRANET - Fundamentos de Redes de Computadores (FRC)

Este repositório contém os scripts de automação de instalação e configuração dos serviços de rede da intranet para a empresa fictícia **Tapingando** (`tapingando.com.br`). Este projeto foi desenvolvido como atividade prática para a disciplina de **Fundamentos de Redes de Computadores (FRC)** na **Universidade de Brasília (UnB)**.

---

## Membros da Equipe

<div align="center">
  <table>
    <tr>
      <td align="center" width="180">
        <a href="https://github.com/BrzGab">
          <img src="https://github.com/BrzGab.png" width="100" height="100" style="border-radius: 50%;" alt="Gabriel Lopes"/><br />
          <b>Gabriel Lopes</b>
        </a><br />
        Matrícula: 231012129
      </td>
      <td align="center" width="180">
        <a href="https://github.com/storch7">
          <img src="https://github.com/storch7.png" width="100" height="100" style="border-radius: 50%;" alt="Guilherme Storch"/><br />
          <b>Guilherme Storch</b>
        </a><br />
        Matrícula: 211030765
      </td>
      <td align="center" width="180">
        <a href="https://github.com/rodrigoFAmaral">
          <img src="https://github.com/rodrigoFAmaral.png" width="100" height="100" style="border-radius: 50%;" alt="Rodrigo Amaral"/><br />
          <b>Rodrigo Amaral</b>
        </a><br />
        Matrícula: 231011810
      </td>
      <td align="center" width="180">
        <a href="https://github.com/FelipeNunesdM">
          <img src="https://github.com/FelipeNunesdM.png" width="100" height="100" style="border-radius: 50%;" alt="Felipe Nunes"/><br />
          <b>Felipe Nunes</b>
        </a><br />
        Matrícula: 202023627
      </td>
    </tr>
  </table>
</div>

---

## Mapa de Endereçamento e Topologia

A arquitetura lógica da rede é dividida entre redes locais e interconexão de roteadores:

| Dispositivo / Interface | Endereço IP | Papel na Rede |
| :--- | :--- | :--- |
| **Servidor S** | `172.16.0.2` | Servidor Central (DNS, DHCP, E-mail, WWW) |
| **Roteador R1 (LAN)** | `172.16.0.1` | Gateway da Rede Interna (LAN #1) |
| **Roteador R1 (PPP)** | `10.0.0.1` | Interconexão Ponto a Ponto (R1 ↔ R2) |
| **Roteador R2 (PPP)** | `10.0.0.2` | Interconexão Ponto a Ponto (R1 ↔ R2) |
| **Roteador R2 (LAN)** | `192.168.0.1` | Gateway da Rede de Clientes (LAN #2) |
| **Cliente X** | `192.168.0.2` | Host da LAN #2 (Configurado por DHCP) |
| **Cliente Y** | `192.168.0.3` | Host da LAN #2 (Configurado por DHCP) |

---

## Estrutura do Repositório

Aqui estão os scripts disponíveis no repositório para a configuração de cada serviço:

*   **[`setup_dns.sh`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/setup_dns.sh)**: Instala e configura o **BIND9** para gerenciar a zona direta (`tapingando.com.br`) e as zonas reversas (`172.16` e `192.168`).
*   **[`setup_dhcp_local.sh`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/setup_dhcp_local.sh)**: Configura o servidor **Kea DHCP** para alocar IPs diretamente aos clientes da rede local (`192.168.0.0/24`).
*   **[`setup_dhcp_relay.sh`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/setup_dhcp_relay.sh)**: Versão alternativa de configuração do **Kea DHCP** otimizada para cenários onde existe um relay DHCP intermediando a LAN de clientes e o servidor.
*   **[`setup_email.sh`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/setup_email.sh)**: Instala e configura o servidor de envio **Postfix (SMTP)** e o servidor de recebimento **Dovecot (POP3/IMAP)**, além de criar usuários de testes (`ana`, `bruno`, `carla`, `diego`) com caixas Maildir prontas.
*   **[`setup_www.sh`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/setup_www.sh)**: Configura o servidor web **Nginx**, servindo uma página personalizada com informações do projeto e mapa da intranet no diretório `/var/www/intranet`.
*   **[`testes_servicos.txt`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/testes_servicos.txt)**: Documentação completa e centralizada contendo os comandos necessários para validar o funcionamento de cada serviço após o setup.

---

## Como Executar os Scripts de Configuração

> [!IMPORTANT]
> Os scripts devem ser executados com privilégios de superusuário (`sudo`) em um ambiente Debian/Ubuntu compatível com as definições de rede propostas.

1. **Clonar o Repositório**:
   ```bash
   git clone <url-do-repositorio>
   cd scipts_setup
   ```

2. **Tornar os Scripts Executáveis**:
   ```bash
   chmod +x setup_*.sh
   ```

3. **Executar em Ordem**:
   Recomendamos configurar primeiro os serviços de base (DNS/DHCP) e em seguida os de aplicação (E-mail/WWW):
   ```bash
   # 1. Configurar o DNS
   sudo ./setup_dns.sh

   # 2. Configurar o DHCP (Escolher cenário Local ou com Relay)
   sudo ./setup_dhcp_local.sh   # Cenário A: DHCP Local
   # ou
   sudo ./setup_dhcp_relay.sh   # Cenário B: Com DHCP Relay

   # 3. Configurar o E-mail
   sudo ./setup_email.sh

   # 4. Configurar o Web Server
   sudo ./setup_www.sh
   ```

---

## Validação e Testes dos Serviços

Para testar a infraestrutura configurada, você pode consultar o arquivo [`testes_servicos.txt`](file:///c:/Users/gsoliveira/Documents/UNB/Redes/INTRANET/scipts_setup%20%281%29/testes_servicos.txt) que possui uma lista detalhada de testes interativos. Veja abaixo alguns exemplos rápidos:

### Testar DNS (Resolução de Nomes)
```bash
dig @172.16.0.2 www.tapingando.com.br
dig @172.16.0.2 -x 172.16.0.2
```

### Testar Envio de E-mail (SMTP) via Terminal
```bash
telnet mail.tapingando.com.br 25
# Digite os comandos de protocolo:
HELO cliente
MAIL FROM: <ana@tapingando.com.br>
RCPT TO: <bruno@tapingando.com.br>
DATA
Subject: Teste do SMTP
Corpo do e-mail de teste.
.
QUIT
```

### Testar Leitura de E-mail (POP3)
```bash
telnet mail.tapingando.com.br 110
# Digite as credenciais:
USER bruno
PASS 123456
LIST
RETR 1
QUIT
```

### Testar Servidor Web
```bash
curl http://www.tapingando.com.br
```

---

## Tecnologias Utilizadas

*   **DNS**: BIND9
*   **DHCP**: Kea DHCP Server
*   **Web Server**: Nginx
*   **SMTP**: Postfix
*   **POP3/IMAP**: Dovecot
*   **OS**: Debian / Ubuntu LTS
