#!/bin/bash
# s_vlc_stream_teste.sh — Testa transmissão multicast a partir de S

cvlc -vvv v_original.mp4 \
  --sout '#duplicate{dst=udp{dst=239.10.4.1:5004}}' \
  --loop