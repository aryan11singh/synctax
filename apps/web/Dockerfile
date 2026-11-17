# Build from the repository root: docker build -f apps/web/Dockerfile .
FROM node:22-slim AS build
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
WORKDIR /repo
RUN corepack enable
COPY . .
RUN pnpm install --frozen-lockfile --filter '@synctax/web...'
RUN pnpm --filter @synctax/shared build
RUN pnpm --filter @synctax/collab-client build
RUN pnpm --filter @synctax/web build

FROM nginx:1.29-alpine AS runtime
RUN rm /etc/nginx/conf.d/default.conf
COPY infra/nginx/nginx.conf /etc/nginx/nginx.conf
COPY infra/nginx/synctax.conf.template /etc/nginx/templates/synctax.conf.template
COPY --from=build /repo/apps/web/dist /usr/share/nginx/html
EXPOSE 80 443
