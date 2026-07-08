#!/bin/bash
# s_ffmpeg_convert.sh — Gera versão de baixa qualidade de um vídeo
# Uso: ./s_ffmpeg_convert.sh v_original.mp4 v_wan.mp4

ORIGINAL=$1
SAIDA=$2

ffmpeg -i "$ORIGINAL" -c:v libx264 -b:v 80k -r 10 -s 320x240 \
  -c:a aac -b:a 16k -ac 1 -ar 22050 "$SAIDA"