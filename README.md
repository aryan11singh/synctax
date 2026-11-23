# Synctax

[![CI](https://github.com/aryan11singh/synctax/actions/workflows/ci.yml/badge.svg)](https://github.com/aryan11singh/synctax/actions/workflows/ci.yml)
[![Integration](https://github.com/aryan11singh/synctax/actions/workflows/integration.yml/badge.svg)](https://github.com/aryan11singh/synctax/actions/workflows/integration.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-22.12+-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Fastify](https://img.shields.io/badge/Fastify-5-000000?logo=fastify&logoColor=white)](https://fastify.dev/)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://neon.tech/)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)](https://redis.io/)

A production-ready, real-time collaborative code editor where an entire room types in the same project simultaneously with conflict-free CRDT synchronization (Yjs), live Monaco cursors, room chat, inline comments, snapshot version history, AI code reviews, and sandboxed code execution.

---

## Live Deployments

- **Frontend (Vercel):** [apps/web](https://synctax.vercel.app) *(or your custom Vercel domain)*
- **Unified Backend (Render):** [`https://synctax-ldez.onrender.com`](https://synctax-ldez.onrender.com)
- **Backend Health Check:** [`https://synctax-ldez.onrender.com/healthz`](https://synctax-ldez.onrender.com/healthz)
- **WebSocket Collaboration:** `wss://synctax-ldez.onrender.com/collab`
- **Database (Neon):** Serverless PostgreSQL 16 with automatic connection pooling

---

## Overview

Synctax enables distributed engineering teams to edit complex multi-file projects together in real-time right inside the browser. Edits merge deterministically through Conflict-free Replicated Data Types (**Yjs**), ensuring zero lock contention and seamless offline reconnection.

Surrounding the editor is a full developer suite:

- **Real-Time Presence:** Remote multi-cursor tracking, user focus states, and one-click "follow user across files".
- **Room Chat & Threads:** Markdown messaging, user mentions (`@user`), typing indicators, and inline code comments pinned with Yjs relative positions.
- **Snapshot Version History:** Automatic timeline checkpoints, manual named snapshots, side-by-side diffing, and one-click rollback.
- **Zero-Trust Security:** Hostile client protection, post-apply document repair, and strict token-based authorization.
- **Sandboxed Execution:** Multi-language compilation (Python, C++, Java, JS) in isolated containers with live terminal output.

---

## Architecture

Synctax uses a decoupled, hybrid-cloud production architecture:

```mermaid
graph TD
    subgraph "Client Layer (Vercel)"
        A[React 18 + Vite] --> B[Monaco Editor]
        B --> C[Yjs CRDT Document]
    end

    subgraph "Edge & Reverse Proxy (Render Container)"
        D[Nginx Reverse Proxy]
    end

    subgraph "Backend Services (Render Container)"
        E[Fastify 5 REST API :3000]
        F[Yjs Collab WebSocket :4000]
        G[(Redis 7 Daemon :6379)]
    end

    subgraph "Database & Workers"
        H[(Neon Serverless PostgreSQL 16)]
        I[BullMQ Worker Fleet / Sandboxes]
    end

    A -->|HTTPS /api/v1/*| D
    C -->|WSS /collab| D
    D -->|Internal Proxy| E
    D -->|WebSocket Upgrade| F
    E --> H
    F --> H
    E --> G
    F --> G
    G --> I
    I --> E
```

### Production Service Allocation

1. **Frontend (Vercel):** Single Page Application deployed via `@synctax/web`. Rewrites `/api/v1/:path*` to the Render backend so all auth cookies remain same-origin.
2. **Unified Backend Container (Render):** Single multi-stage Docker container hosting:
   - **Nginx (Port 10000):** Terminates SSL, injects CORS headers for `*.vercel.app`, proxies `/api` to Fastify, and upgrades `/collab` to WebSockets.
   - **Fastify API (Port 3000):** Authentication, room management, snapshots, file tree, and job queues.
   - **Collab WebSocket Server (Port 4000):** Real-time Yjs document synchronization and awareness states.
   - **In-Container Redis (Port 6379):** High-speed document log, locks, and cross-process Pub/Sub.
3. **Database (Neon):** Managed PostgreSQL 16 storing users, rooms, permissions, and snapshot trees.

---

## Key Features

| Feature | Description |
| :--- | :--- |
| **Real-Time Editing** | Monaco Editor powered by Yjs. Concurrent edits merge smoothly with zero data loss. |
| **Live Presence** | Remote colored cursors, line selections, online roster, and user following. |
| **Workspace & File Tree** | Drag-and-drop file organization, multi-tab navigation, split-view, and resizable panes. |
| **Inline Code Comments** | Threads pinned to lines with Yjs relative positions so they stay attached as lines shift. |
| **Snapshots & Restore** | Snapshots recorded every 5 minutes and on successful runs, with side-by-side visual diffs. |
| **Room Access Control** | Owner, Editor, and Viewer permissions with secure room invite tokens. |
| **Sandboxed Code Execution** | Python, C++, Java, and JavaScript run in one-use isolated execution environments. |
| **AI Code Review** | Static code analysis (ESLint, Ruff, lizard) combined with Claude for automated PR feedback. |
| **Blame View** | Per-line authorship indicators traced directly from Yjs client identifiers. |

---

## Tech Stack

- **Frontend:** React 18, TypeScript, Vite, Tailwind CSS, Monaco Editor (`y-monaco`), Zustand, React Query.
- **Backend & Real-Time:** Node.js 22, Fastify 5, Yjs (`y-protocols`), WebSockets (`ws`), BullMQ, Zod.
- **Database & Storage:** PostgreSQL 16 (Prisma 7 ORM), Redis 7 (`ioredis`).
- **Security & Auth:** Argon2id password hashing, HTTP-only JWTs with rotating refresh tokens, CSRF tokens.
- **DevOps & Infrastructure:** Docker (Multi-stage build), Nginx, GitHub Actions (CI/CD), Vercel, Render, Neon.

---

## Local Development Setup

### Prerequisites

- [Node.js 22.12+](https://nodejs.org/)
- [pnpm 10+](https://pnpm.io/) (`corepack enable`)
- [Docker & Docker Compose](https://www.docker.com/)

### Step-by-Step

1. **Clone the repository:**

   ```bash
   git clone https://github.com/aryan11singh/synctax.git
   cd synctax
   ```

2. **Install dependencies:**

   ```bash
   corepack enable
   pnpm install
   ```

3. **Start local infrastructure (PostgreSQL & Redis):**

   ```bash
   docker compose -f infra/compose/docker-compose.dev.yml up -d
   ```

4. **Configure Environment Variables:**

   ```bash
   cp apps/api/.env.example apps/api/.env
   cp apps/collab/.env.example apps/collab/.env
   ```

5. **Deploy Database Migrations & Generate Prisma Client:**

   ```bash
   DATABASE_URL="postgresql://synctax:synctax@localhost:5432/synctax" pnpm --filter @synctax/db migrate:deploy
   pnpm --filter @synctax/db generate
   ```

6. **Build Packages & Start Development Servers:**

   ```bash
   pnpm build
   ```

   In separate terminals:

   ```bash
   # Terminal 1: REST API (Port 3000)
   pnpm --filter @synctax/api dev
   ```

   ```bash
   # Terminal 2: Collab WebSocket Server (Port 4000)
   pnpm --filter @synctax/collab dev
   ```

   ```bash
   # Terminal 3: Web Application (Port 5173)
   pnpm --filter @synctax/web dev
   ```

7. **Open App:** Navigate to `http://localhost:5173`. Emails (signup verification) are captured locally by Mailpit at `http://localhost:8025`.

---

## Testing & Quality Assurance

Synctax maintains an automated CI test suite covering unit, lint, integration, and full browser E2E workflows:

```bash
# Typecheck across the entire monorepo
pnpm run typecheck

# Fast Oxlint code analysis
pnpm run lint

# Unit tests (API, Collab, Web, Prisma)
pnpm test

# Playwright End-to-End tests (Simulates multiple browsers collaborating in real-time)
pnpm --filter @synctax/web test:e2e
```

---

## Cloud Deployment Guide

### 1. Database (Neon)

1. Create a serverless PostgreSQL database on [Neon](https://neon.tech/).
2. Run database migrations directly:

   ```bash
   DATABASE_URL="postgresql://<user>:<password>@<host>/<db>?sslmode=require" npx prisma migrate deploy --schema packages/db/prisma/schema.prisma
   ```

### 2. Backend (Render)

1. In the [Render Dashboard](https://dashboard.render.com), create a new **Web Service** pointing to this repository.
2. Select **Docker** as the runtime.
3. Configure Environment Variables:
   - `DATABASE_URL`: Your Neon PostgreSQL connection string.
   - `PORT`: `10000`
   - `PUBLIC_WEB_URL`: `https://your-app.vercel.app`
   - `ALLOWED_ORIGINS`: `https://your-app.vercel.app`
   - `COOKIE_SECURE`: `true`
4. The service will build via `Dockerfile` and start Nginx, Redis, Fastify, and Collab via `infra/render/start.sh`.

### 3. Frontend (Vercel)

1. Import the repository on [Vercel](https://vercel.com).
2. Set the Root Directory to `.` (or `apps/web`).
3. Set the Build Command to:

   ```bash
   node scripts/build-vercel.mjs
   ```

4. Output Directory: `dist`
5. The included `vercel.json` automatically proxies `/api/v1/:path*` to `https://synctax-ldez.onrender.com/api/v1/:path*`, ensuring seamless authentication and zero CORS issues.

---

## Environment Variables Reference

| Variable | Target Service | Default / Fallback | Purpose |
| :--- | :--- | :--- | :--- |
| `DATABASE_URL` | API, Collab | *Neon DB URI* | PostgreSQL connection string |
| `REDIS_URL` | API, Collab | `redis://127.0.0.1:6379` | Redis instance connection |
| `PORT` | Container | `10000` | Public Nginx listening port on Render |
| `ACCESS_TOKEN_SECRET` | API | *Generated SHA-256* | Secret for signing user JWT access tokens |
| `COLLAB_TOKEN_SECRET` | API, Collab | *Shared Secret* | Token secret shared between API & Collab |
| `PUBLIC_WEB_URL` | API | `https://synctax.vercel.app` | Base web URL for email links and CORS |
| `PUBLIC_API_URL` | API | `https://synctax-ldez.onrender.com` | Public API base URL for OAuth callbacks |
| `COOKIE_SECURE` | API | `true` | Requires HTTPS cookies in production |
| `AUTO_VERIFY_SIGNUP` | API | `true` | Auto-activates accounts upon registration |
| `ALLOWED_ORIGINS` | Collab | `https://*.vercel.app` | Allowed WebSocket origin list |

---

## Author & License

Developed with ❤️ by **Aryan Singh** ([@aryan11singh](https://github.com/aryan11singh)).

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.
