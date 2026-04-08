# AGENTS.md

Guidelines for coding assistants working in open.offline.docs.

## Table of Contents

- [Overview](#overview)
- [Commands](#commands)
- [Architecture](#architecture)
- [Components](#components)
- [API](#api)
- [TUI](#tui)
- [Containers](#containers)
- [Docker](#docker)
- [Environment](#environment)
- [Conventions](#conventions)
- [Issues](#issues)
- [Ports](#ports)

## Overview

Docker-based offline documentation system. `ood` is the single entrypoint. TUI is standalone, wraps `ood` via `execSync`.

## Commands

**Always use `bash ood <command>` — never guess Docker commands.**

```bash
# System
bash ood doctor           # Check dependencies
bash ood build           # Build Docker images

# Services
bash ood up              # Start all services
bash ood up --only api    # Start only API
bash ood down            # Stop all services
bash ood status          # Show container status
bash ood clean           # Stop and prune containers

# Info
bash ood list            # List available docs
bash ood help            # Show help
bash ood tui             # Open Terminal UI

# Testing
bash ood test --dep       # Run dependency tests
bash ood test --api      # Run API tests

# Options
bash ood --port=api=9000 up   # Custom port
```

## Architecture

```
ood (bash) ──┬── docker compose ── api (PHP Slim 4, port 8080)
│            │                     └── manager (Python + docker-py, via proc_open)
│            └── doc-base image ── mkdocs / astro / jekyll / static containers

TUI (bun/@opentui/core) ── execSync("bash ood ...")
```

### Request Flow

**API**: HTTP → `index.php` → `Application.php` → `DocsController.php` → `proc_open("python3 manager.py")` → Docker

**TUI**: Keypress → `index.ts` → `execSync("bash ood")` → scripts → docker compose

## Components

| Component | Path | Stack | Purpose |
|-----------|------|-------|---------|
| CLI | `ood` + `scripts/*.sh` | Bash | Entrypoint, modular scripts |
| API | `api/` | PHP Slim 4 + PSR-7 | HTTP interface |
| Manager | `manager/manager.py` | Python + docker-py | Container lifecycle |
| TUI | `tui/index.ts` | Bun + @opentui/core | Terminal UI |
| Docker | `docker/` | Compose | Dev + prod images |
| Docs | `docs/` | Read-only | Documentation |

### Key Files

| File | Purpose |
|------|---------|
| `ood` | CLI entrypoint |
| `scripts/vars.sh` | Config, ports, paths |
| `scripts/flags.sh` | Argument parsing |
| `scripts/docker.sh` | Docker operations |
| `scripts/functions.sh` | User commands |
| `api/public/index.php` | HTTP entry |
| `api/src/Application.php` | Routes |
| `api/src/DocsController.php` | Request handlers |
| `manager/manager.py` | Container CRUD |
| `docker/entrypoint.sh` | Doc startup |

## API

### Endpoints

```
GET  /                      # Health
GET  /docs                  # List docs
POST /docs/{name}/start     # Start doc
POST /docs/{name}/stop     # Stop doc
GET  /docs/{name}/status   # Doc status
```

## TUI

- **No build** — `@opentui/core` uses `bun:ffi`, runtime only
- **Run with**: `bun run index.ts`
- **API**: `Box(props, ...children)`, `Text(props)`
- **Key handling**: `renderer.keyInput.on("keypress", handler)`
- **Re-render**: `renderer.root.remove("app")` then `renderer.root.add(Box(...))`
- **Exit**: `renderer.destroy()` + `process.exit(0)`
- **Layout**: Two-panel — left (commands), right (output)
- **Nav**: `j`/`k` navigate, `Enter` execute, `q` quit

## Containers

| Type | Docs | Command |
|------|------|---------|
| mkdocs | fastapi, alpine | `mkdocs serve --dev-addr 0.0.0.0:<port>` |
| astro | astro | `pnpm dev` or `npm run dev` |
| jekyll | slimphp | `bundle exec jekyll serve --host 0.0.0.0 --port <port>` |
| static | php, python | `python3 -m http.server <port>` |

- Naming: `ood-doc-<name>`, `ood-api`
- Network: `ood-network`

### Lifecycle

1. **Start**: Check exists → running? return already_running : stopped? start : create
2. **Stop**: Stop (10s timeout), then remove `force=True`
3. **Status**: Return status, port, type, short ID
4. **List**: Filter `ood-doc-*`, extract name + ports

## Docker

### Images

- `ood-api:latest` — PHP 8.2 + Python 3 + Node.js + Ruby
- `ood-doc-base:latest` — Python 3.11-slim + Node.js 20 + Ruby + MkDocs

### Dev vs Prod

| Aspect | Dev | Prod |
|--------|-----|------|
| Dockerfile | `docker/Dockerfile` | `docker/Dockerfile.prod` |
| Docs | Mount volume | Baked in |
| Manager | Mount volume | Baked in |

## Environment

- `.env` — Optional. Set `BASE_DIR`. Copy `.env.example` to `.env`.
- `ood` loads `.env` automatically
- TUI reads `BASE_DIR` from `.env`, falls back to repo root
- Manager uses `OOD_DOCS_PATH`, falls back to `../docs`

## Conventions

**Python**: Standard lib → third-party → local. Type hints. `json_output()`/`json_error()`. `argparse` with subparsers.

**PHP**: Slim 4, PSR-7. `declare(strict_types=1)`. Routes in `Application.php`. Controller in `DocsController.php`. `proc_open` to manager. DI via PHP-DI.

**TypeScript**: Bun runtime only, no build. `execSync` for shell. Async/await. ESM (`"type": "module"`).

**Bash**: Modular scripts. `vars.sh` → `flags.sh` → `docker.sh` → `functions.sh`. All sourced by `ood`. `set -e`. Functions use `echo`, no deps.

## Issues

- `Dockerfile.doc` may appear binary — it's valid UTF-8
- No test suite, linter, or typechecker
- `vars.sh` ports don't match manager/controller — they're the source of truth

## Ports

Source of truth: `manager.py` DOCS_CONFIG + `DocsController.php` DOCS_CONFIG (must match).

| Service | Port |
|---------|------|
| API | 8080 |
| FastAPI | 8000 |
| Astro | 8001 |
| Alpine | 8002 |
| PHP | 8003 |
| Python | 8004 |
| SlimPHP | 8005 |