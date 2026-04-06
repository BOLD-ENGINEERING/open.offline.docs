# Open Offline Docs

Monolithic repository of open-source framework and programming language documentation for offline development.

## Overview

A Docker-based system for running documentation servers offline. Each documentation site runs in its own container, managed by a central API or the standalone Terminal UI.

**Docs included:**
- **FastAPI** — MkDocs (port 8000)
- **Alpine.js** — MkDocs (port 8002)
- **Astro** — Node.js (port 8001)
- **PHP** — Static (port 8003)
- **Python** — Static (port 8004)
- **SlimPHP** — Jekyll (port 8005)

## Quick Start

```bash
bash ood doctor    # Check dependencies
bash ood build     # Build images
bash ood up        # Start all services
bash ood tui       # Terminal UI (standalone, no build needed)
```

## Commands

```
bash ood doctor              Check system dependencies
bash ood build               Build Docker images
bash ood up                  Start all services
bash ood up --only api       Start only API
bash ood down                Stop all services
bash ood status              Show container status
bash ood clean               Stop + prune containers
bash ood list                List available docs
bash ood tui                 Start Terminal UI
bash ood help                Show help
bash ood --port=api=9000 up  Custom port
```

## Architecture

```
ood (bash) ──┬── docker compose ── api (PHP Slim 4, port 8080)
│            │                     └── manager (Python + docker-py)
│            │
│            └── doc-base image ── mkdocs / astro / jekyll / static
│
└── TUI (bun/@opentui/core) ── execSync("bash ood ...")
```

| Component | Stack | Purpose |
|-----------|-------|---------|
| `ood` | Bash | Single CLI entrypoint |
| `api/` | PHP Slim 4 + PSR-7 | HTTP management API |
| `manager/` | Python + docker-py | Docker container lifecycle |
| `tui/` | Bun + @opentui/core | Standalone terminal UI |
| `docker/` | Docker compose | Dev + prod images |
| `docs/` | Read-only | Aggregated documentation |

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
├── ood                      # Main CLI entrypoint
├── scripts/                 # Modular bash scripts
│   ├── vars.sh              # Configuration and port defaults
│   ├── flags.sh             # Argument parsing
│   ├── docker.sh            # Docker operations
│   └── functions.sh         # User-facing commands
├── api/                     # PHP Slim 4 API service
│   ├── public/index.php     # Entry point
│   ├── src/Application.php  # Route definitions
│   └── src/DocsController.php  # Request handlers
├── manager/                 # Python Docker manager
│   ├── manager.py           # Container lifecycle CLI
│   └── requirements.txt     # docker-py dependency
├── tui/                     # Terminal UI
│   └── index.ts             # Bun + @opentui/core
├── docker/
│   ├── Dockerfile           # API image (dev)
│   ├── Dockerfile.prod      # API image (production)
│   ├── Dockerfile.doc       # Doc base image (all deps)
│   ├── docker-compose.yml   # Dev compose (mounts volumes)
│   ├── docker-compose.prod.yml  # Prod compose (bakes content)
│   ├── entrypoint.sh        # Doc container startup script
│   └── requirements.txt     # Python deps for doc containers
├── docs/                    # Read-only documentation
│   ├── fastapi.docs/        # MkDocs
│   ├── alpine.docs/         # MkDocs
│   ├── astro.docs/          # Astro (has package.json)
│   ├── php.docs/            # Static
│   ├── python.docs/         # Static
│   └── slim.php.docs/       # Jekyll
├── AGENTS.md                # Guidelines for coding assistants
└── LICENSE                  # GPL v3
```

## Prerequisites

- Docker + docker-compose
- Bun (for TUI)

## Configuration

Copy `.env.example` to `.env` and set your project path:

```bash
cp .env.example .env
# Edit .env and set BASE_DIR to your repo's absolute path
```

The `.env` file is gitignored. `ood`, the TUI, and the manager all read `BASE_DIR` from it with sensible fallbacks.

## License

GPL v3. Aggregated docs retain their original licenses (MIT, PSF, etc.).

---

Used by BOLD Engineering for offline development.
