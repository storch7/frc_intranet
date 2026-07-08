#!/bin/bash
# s_ffprobe_metadata.sh — Extrai metadados de um vídeo
# Uso: ./s_ffprobe_metadata.sh v_original.mp4

ffprobe -v quiet -print_format json -show_format -show_streams "$1"