# AGENTS.md

Guidelines for coding assistants working in open.offline.docs.

## What This Is

A Docker-based offline documentation system. The `ood` bash script is the single entrypoint for all operations. The TUI is a standalone terminal interface that wraps `ood` commands via `execSync`.

## Commands

**Always use `bash ood <command>` — never guess Docker commands directly.**

```
bash ood build        # Build Docker images (doc-base + api)
bash ood up           # Start all services via docker compose
bash ood down         # Stop all services
bash ood status       # Show container status
bash ood clean        # Stop + prune containers
bash ood doctor       # Check dependencies (Docker, Bun, curl, Python3)
bash ood list         # List available docs
bash ood tui          # Start Terminal UI (standalone, no API needed)
bash ood --port=api=9000 up   # Custom port
```

## Architecture

```
ood (bash) ──┬── docker compose ── api (PHP Slim 4, port 8080)
│            │                     └── manager (Python + docker-py, via proc_open)
│            │
│            └── doc-base image ── mkdocs / astro / jekyll / static containers
│
└── TUI (bun/@opentui/core) ── execSync("bash ood ...")
```

### Component Details

| Component | Path | Stack | Purpose |
|-----------|------|-------|---------|
| CLI | `ood` + `scripts/*.sh` | Bash | Single entrypoint, modular scripts |
| API | `api/` | PHP Slim 4 + PSR-7 | HTTP management interface (port 8080) |
| Manager | `manager/manager.py` | Python + docker-py | Docker container lifecycle (start/stop/list/status) |
| TUI | `tui/index.ts` | Bun + @opentui/core v0.1.97 | Standalone terminal menu, calls `bash ood` directly |
| Docker | `docker/` | Docker compose | Dev + prod compose files, base images |
| Docs | `docs/` | Read-only | Aggregated documentation (do not edit) |

### Request Flow (API path)

```
HTTP → api/public/index.php → Application.php → DocsController.php
  → proc_open("python3 manager/manager.py <cmd>") → Docker API
```

### Request Flow (TUI path)

```
User keypress → tui/index.ts → execSync("bash ood <cmd>") → scripts/*.sh → docker compose
```

## TUI Quirks

- **No build step**: `bun build` will fail — `@opentui/core` imports `bun:ffi` which only works at runtime
- **Always run with**: `bun run index.ts`
- **Construct API**: `Box(props, ...children)` and `Text(props)` from `@opentui/core` v0.1.97
- **Key handling**: `renderer.keyInput.on("keypress", handler)` — KeyEvent has `.name`, `.ctrl`, `.shift`, `.meta`
- **Re-render pattern**: `renderer.root.remove("app")` then `renderer.root.add(Box({id: "app", ...}, ...children))`
- **Exit**: `renderer.destroy()` then `process.exit(0)`
- **Env var**: `OTUI_USE_CONSOLE=false` set by `bash ood tui` in `scripts/functions.sh`
- **BASE_DIR**: Loaded from `.env` file, falls back to repo root. Copy `.env.example` to `.env` and set your path

## Doc Container Types

| Type | Docs | Server Command | Port |
|------|------|----------------|------|
| mkdocs | fastapi, alpine | `mkdocs serve --dev-addr 0.0.0.0:<port>` | 8000, 8002 |
| astro | astro | `pnpm dev` or `npm run dev` | 8001 |
| jekyll | slimphp | `bundle exec jekyll serve --host 0.0.0.0 --port <port>` | 8005 |
| static | php, python | `python3 -m http.server <port>` | 8003, 8004 |

Container naming: `ood-doc-<name>` (docs), `ood-api` (API)
All containers share `ood-network` Docker network.

## Docker Images

- **`ood-api:latest`** — PHP 8.2 + Python 3 + Node.js + Ruby. Built from `docker/Dockerfile` (dev) or `docker/Dockerfile.prod`
- **`ood-doc-base:latest`** — Python 3.11-slim + Node.js 20 + Ruby + MkDocs + all Python deps. Built from `docker/Dockerfile.doc`
- API mounts Docker socket (`/var/run/docker.sock`) so the manager can control containers
- Dev compose mounts `manager/` and `docs/` as read-only volumes; prod bakes them into the image

## Environment

- **`.env`** — Optional. Set `BASE_DIR` to override the project root path. Copy `.env.example` to `.env` to configure.
- **`.env.example`** — Committed template. `.env` is gitignored.
- `ood` loads `.env` automatically if it exists (before sourcing scripts).
- TUI reads `BASE_DIR` from `.env` at runtime, falls back to `../` relative to `tui/index.ts`.
- Manager uses `OOD_DOCS_PATH` env var, falls back to `../docs` relative to `manager/manager.py`.

## Code Conventions

**Python (manager/)**: Standard lib → third-party → local. Type hints required. All output via `json_output()`/`json_error()` with proper exit codes.

**PHP (api/)**: Slim 4, PSR-7. Routes in `Application.php`. Controller in `DocsController.php`. Uses `proc_open` to call manager, parses JSON responses.

**TypeScript (tui/)**: Bun runtime only, no build. Use `execSync` for shell commands. Async/await for any API calls.

**Bash (scripts/)**: Modular — `vars.sh` (config), `flags.sh` (arg parsing), `docker.sh` (docker ops), `functions.sh` (user-facing commands). All sourced by `ood`.

## Known Issues

- `Dockerfile.doc` may appear as binary in some tools — it's valid UTF-8 text
- No test suite, linter, or typechecker configured

## Port Defaults (scripts/vars.sh)

| Service | Port |
|---------|------|
| API | 8080 |
| FastAPI doc | 8000 |
| Python doc | 8001 |
| PHP doc | 8002 |
| Astro doc | 8003 |
| Alpine doc | 8004 |
| SlimPHP doc | 8005 |
