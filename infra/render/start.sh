#!/usr/bin/env bash
set -e

# Render provides $PORT (typically 10000). Default to 10000 if not present.
export PORT="${PORT:-10000}"
export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"
export DATABASE_URL="${DATABASE_URL:-postgresql://neondb_owner:npg_adNUvy03oABM@ep-flat-dew-begx9jfz.c-9.us-east-2.aws.neon.tech/neondb?sslmode=require}"

# Fallback secrets and environment variables if not set in Render dashboard
SHARED_SECRET=$(openssl rand -hex 32 2>/dev/null || echo '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
export ACCESS_TOKEN_SECRET="${ACCESS_TOKEN_SECRET:-$SHARED_SECRET}"
export COLLAB_TOKEN_SECRET="${COLLAB_TOKEN_SECRET:-$SHARED_SECRET}"
export INVITE_TOKEN_SECRET="${INVITE_TOKEN_SECRET:-$SHARED_SECRET}"
export OAUTH_STATE_SECRET="${OAUTH_STATE_SECRET:-$SHARED_SECRET}"
export INTERNAL_SERVICE_TOKEN="${INTERNAL_SERVICE_TOKEN:-$SHARED_SECRET}"
export PUBLIC_WEB_URL="${PUBLIC_WEB_URL:-https://synctax.vercel.app}"
export PUBLIC_API_URL="${PUBLIC_API_URL:-https://synctax-ldez.onrender.com}"
export ALLOWED_ORIGINS="${ALLOWED_ORIGINS:-https://synctax.vercel.app}"
export SMTP_URL="${SMTP_URL:-smtp://localhost:25}"
export MAIL_FROM="${MAIL_FROM:-noreply@synctax.dev}"
export COOKIE_SECURE="${COOKIE_SECURE:-true}"
export TRUST_PROXY_HOPS="${TRUST_PROXY_HOPS:-1}"
export EXECUTION_ENABLED="${EXECUTION_ENABLED:-false}"
export AUTO_VERIFY_SIGNUP="${AUTO_VERIFY_SIGNUP:-true}"

echo "Starting in-container Redis server..."
redis-server --daemonize yes --bind 127.0.0.1 --port 6379

echo "Configuring Nginx reverse proxy for port ${PORT}..."
envsubst '${PORT}' < /etc/nginx/templates/synctax.conf.template > /etc/nginx/conf.d/synctax.conf

echo "Starting Nginx daemon..."
nginx

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
