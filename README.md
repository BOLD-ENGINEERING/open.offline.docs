# Open Offline Docs

Monolithic repository of open-source framework and programming language documentation for offline development.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Commands](#commands)
  - [System](#system)
  - [Services](#services)
  - [Docs](#docs)
  - [Info](#info)
  - [Options](#options)
- [Terminal UI](#terminal-ui)
- [Configuration](#configuration)
- [Architecture](#architecture)
  - [Component Overview](#component-overview)
  - [Request Flows](#request-flows)
  - [Doc Container Types](#doc-container-types)
  - [Docker Images](#docker-images)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Port Defaults](#port-defaults)
- [License](#license)

## Overview

A Docker-based system for running documentation servers offline. Each documentation site runs in its own container, managed by a central API or the standalone Terminal UI.

**Docs included:**

| Doc | Type | Port |
|-----|------|------|
| FastAPI | MkDocs | 8000 |
| Alpine.js | MkDocs | 8002 |
| Astro | Node.js | 8001 |
| PHP | Static | 8003 |
| Python | Static | 8004 |
| SlimPHP | Jekyll | 8005 |

## Quick Start

```bash
bash ood doctor    # Check dependencies
bash ood build     # Build Docker images
bash ood up        # Start all services
bash ood tui       # Open Terminal UI
```

## Prerequisites

- **Docker** + **docker-compose**
- **Bun** (for TUI)

## Commands

All commands are run via the `ood` script: `bash ood <command>`

### System

| Command | Description |
|---------|-------------|
| `bash ood doctor` | Check system dependencies (Docker, Bun, curl, Python3) |
| `bash ood build` | Build Docker images (doc-base + api) |

### Services

| Command | Description |
|---------|-------------|
| `bash ood up` | Start all services |
| `bash ood up --only api` | Start only the API service |
| `bash ood down` | Stop all services |
| `bash ood stop` | Stop all containers (alias for down) |
| `bash ood status` | Show container status |
| `bash ood clean` | Stop + prune all containers and images |

### Docs

| Command | Description |
|---------|-------------|
| `bash ood list` | List available documentation sites |

### Info

| Command | Description |
|---------|-------------|
| `bash ood help` | Show commands, options, and examples |

### Options

| Flag | Description | Example |
|------|-------------|---------|
| `--only=X` | Start specific service | `bash ood up --only api` |
| `--port=X=Y` | Set custom port | `bash ood --port=api=9000 up` |

## Terminal UI

```bash
bash ood tui
```

Full-screen interface with vim-style navigation:

| Key | Action |
|-----|--------|
| `j` / `↓` | Navigate down |
| `k` / `↑` | Navigate up |
| `Enter` | Execute selected command |
| `q` / `Esc` | Quit |

The TUI is standalone — it does not require the API to be running.

## Configuration

Copy `.env.example` to `.env` and set your project path:

```bash
cp .env.example .env
```

```env
BASE_DIR=/path/to/open.offline.docs
```

| Variable | Used By | Description |
|----------|---------|-------------|
| `BASE_DIR` | `ood`, TUI, scripts | Absolute path to the project root |
| `OOD_DOCS_PATH` | manager | Path to docs directory (default: `$BASE_DIR/docs`) |

The `.env` file is gitignored. All components fall back to auto-detection if not set.

## Architecture

```
ood (bash) ──┬── docker compose ── api (PHP Slim 4, port 8080)
│            │                     └── manager (Python + docker-py)
│            │
│            └── doc-base image ── mkdocs / astro / jekyll / static
│
└── TUI (bun/@opentui/core) ── execSync("bash ood ...")
```

### Component Overview

| Component | Path | Stack | Purpose |
|-----------|------|-------|---------|
| CLI | `ood` + `scripts/` | Bash | Single entrypoint, modular scripts |
| API | `api/` | PHP Slim 4 + PSR-7 | HTTP management interface |
| Manager | `manager/` | Python + docker-py | Docker container lifecycle |
| TUI | `tui/` | Bun + @opentui/core | Standalone terminal UI |
| Docker | `docker/` | Docker compose | Dev + prod images |
| Docs | `docs/` | Read-only | Aggregated documentation |

### Request Flows

**API path:**
```
HTTP → api/public/index.php → Application.php → DocsController.php
  → proc_open("python3 manager/manager.py <cmd>") → Docker API
```

**TUI path:**
```
User keypress → tui/index.ts → execSync("bash ood <cmd>") → scripts → docker compose
```

### Doc Container Types

| Type | Docs | Server Command |
|------|------|----------------|
| mkdocs | fastapi, alpine | `mkdocs serve --dev-addr 0.0.0.0:<port>` |
| astro | astro | `pnpm dev` or `npm run dev` |
| jekyll | slimphp | `bundle exec jekyll serve --host 0.0.0.0 --port <port>` |
| static | php, python | `python3 -m http.server <port>` |

Container naming: `ood-doc-<name>` (docs), `ood-api` (API)
All containers share the `ood-network` Docker network.

### Docker Images

| Image | Base | Contents |
|-------|------|----------|
| `ood-api:latest` | PHP 8.2 | PHP Slim API + Python + Node.js + Ruby + docker-py |
| `ood-doc-base:latest` | Python 3.11-slim | Node.js 20 + Ruby + MkDocs + all Python deps |

- **Dev**: `docker-compose.yml` mounts `manager/` and `docs/` as read-only volumes
- **Prod**: `docker-compose.prod.yml` bakes content into the image

## API Endpoints

```bash
curl http://127.0.0.1:8080/docs                          # List all docs
curl -X POST http://127.0.0.1:8080/docs/fastapi/start    # Start a doc
curl -X POST http://127.0.0.1:8080/docs/fastapi/stop     # Stop a doc
curl http://127.0.0.1:8080/docs/fastapi/status           # Get doc status
```

## Project Structure

```
open.offline.docs/
├── ood                          # Main CLI entrypoint
├── .env.example                 # Environment template
├── AGENTS.md                    # Guidelines for coding assistants
├── scripts/
│   ├── vars.sh                  # Configuration and port defaults
│   ├── flags.sh                 # Argument parsing
│   ├── docker.sh                # Docker operations
│   └── functions.sh             # User-facing commands
├── api/
│   ├── composer.json            # PHP dependencies
│   ├── public/index.php         # Entry point
│   └── src/
│       ├── Application.php      # Route definitions
│       └── DocsController.php   # Request handlers
├── manager/
│   ├── manager.py               # Container lifecycle CLI
│   └── requirements.txt         # docker-py dependency
├── tui/
│   ├── package.json             # Bun dependencies
│   └── index.ts                 # Terminal UI entry point
├── docker/
│   ├── Dockerfile               # API image (dev)
│   ├── Dockerfile.prod          # API image (production)
│   ├── Dockerfile.doc           # Doc base image (all deps)
│   ├── docker-compose.yml       # Dev compose (mounts volumes)
│   ├── docker-compose.prod.yml  # Prod compose (bakes content)
│   ├── entrypoint.sh            # Doc container startup script
│   └── requirements.txt         # Python deps for doc containers
├── docs/                        # Read-only documentation
│   ├── fastapi.docs/            # MkDocs
│   ├── alpine.docs/             # MkDocs
│   ├── astro.docs/              # Astro (has package.json)
│   ├── php.docs/                # Static
│   ├── python.docs/             # Static
│   └── slim.php.docs/           # Jekyll
└── LICENSE                      # GPL v3
```

## Port Defaults

| Service | Port |
|---------|------|
| API | 8080 |
| FastAPI | 8000 |
| Astro | 8001 |
| PHP | 8002 |
| Alpine | 8004 |
| Python | 8003 |
| SlimPHP | 8005 |

## License

GPL v3. Aggregated docs retain their original licenses (MIT, PSF, etc.).

---

Used by BOLD Engineering for offline development.
