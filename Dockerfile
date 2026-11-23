# Multi-stage Docker build for Synctax Unified Backend
FROM node:22-slim AS build
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
WORKDIR /repo

RUN corepack enable
COPY . .

RUN pnpm install --frozen-lockfile
RUN pnpm --filter @synctax/shared build
RUN pnpm --filter @synctax/db build
RUN pnpm --filter @synctax/api build
RUN pnpm --filter @synctax/collab build
RUN pnpm --filter @synctax/api deploy --prod /app/api
RUN pnpm --filter @synctax/collab deploy --prod /app/collab
RUN cp -r packages/db/prisma /app/api/prisma

FROM node:22-slim AS runtime
ENV NODE_ENV=production
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server \
    nginx \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/api /app/api
COPY --from=build /app/collab /app/collab

RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf
RUN mkdir -p /etc/nginx/templates
COPY infra/render/synctax.conf.template /etc/nginx/templates/synctax.conf.template
COPY infra/render/start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 10000

CMD ["/app/start.sh"]
