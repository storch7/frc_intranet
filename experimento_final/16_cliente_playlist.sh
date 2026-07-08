#!/bin/bash
# cliente_playlist.sh — Busca playlist do canal e abre no VLC Client

# Endpoint da API Gateway (via R1) que devolve a playlist do canal escolhido
curl -s https://r1.grupo4.lan/api/canais/1/playlist -o canal1.m3u

cvlc canal1.m3u