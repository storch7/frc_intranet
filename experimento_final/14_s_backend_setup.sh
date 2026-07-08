#!/bin/bash
# s_backend_setup.sh — Prepara ambiente do backend em S

apt update && apt install -y nodejs npm ffmpeg

mkdir -p /opt/miniiptv-backend && cd /opt/miniiptv-backend
npm init -y
npm install express jsonwebtoken bcrypt sqlite3 dotenv openid-client

mkdir -p src/{routes,models,controllers}
touch src/server.js