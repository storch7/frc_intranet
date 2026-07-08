#!/bin/bash
# x_y_conectividade.sh — Solicita/renova endereço via DHCP

dhclient -r eth0   # libera lease anterior, se houver
dhclient eth0      # solicita novo endereço a R2
ip a show eth0
ip route show