#!/bin/sh
# Cloady entrypoint: generate sing-box config from $PORT, then run sing-box.
# VLESS + WebSocket (path /vless), no TLS inside the container
# (Cloady terminates TLS at its own domain).
set -e

PORT="${PORT:-8080}"
UUID="de9313dc-50f5-4c81-ac47-f5c0902a00cb"

mkdir -p /etc/sing-box

cat > /etc/sing-box/config.json <<EOF
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "0.0.0.0",
      "listen_port": ${PORT},
      "users": [
        {
          "uuid": "${UUID}"
        }
      ],
      "transport": {
        "type": "ws",
        "path": "/vless"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

echo "Generated /etc/sing-box/config.json: VLESS+WS on 0.0.0.0:${PORT}, path /vless"
exec /usr/local/bin/sing-box -c /etc/sing-box/config.json run
