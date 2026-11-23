#!/usr/bin/env bash
set -e

# Render provides $PORT (typically 10000). Default to 10000 if not present.
export PORT="${PORT:-10000}"
export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"

echo "Starting in-container Redis server..."
redis-server --daemonize yes --bind 127.0.0.1 --port 6379

echo "Configuring Nginx reverse proxy for port ${PORT}..."
envsubst '${PORT}' < /etc/nginx/templates/synctax.conf.template > /etc/nginx/conf.d/synctax.conf

echo "Starting Nginx daemon..."
nginx

if [ -n "$DATABASE_URL" ] && [ -d "/app/api/prisma" ]; then
  echo "Applying database migrations..."
  cd /app/api
  npx prisma migrate deploy --schema prisma/schema.prisma || echo "Migration warning: proceeding with startup..."
fi

echo "Starting Synctax REST API (Fastify) on internal port 3000..."
cd /app/api
PORT=3000 node dist/index.js &
API_PID=$!

echo "Starting Synctax Collaboration Server (Yjs WebSocket) on internal port 4000..."
cd /app/collab
PORT=4000 node dist/index.js &
COLLAB_PID=$!

echo "Synctax backend is fully operational on port ${PORT}!"
wait -n $API_PID $COLLAB_PID
