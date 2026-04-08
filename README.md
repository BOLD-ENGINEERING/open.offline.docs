# Open Offline Docs

Docker-based offline documentation system for open-source frameworks and languages.

[![Docker](https://img.shields.io/badge/Docker-required-blue)](https://docker.com)
[![Bun](https://img.shields.io/badge/Bun-required-yellow)](https://bun.sh)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
  - [System Dependencies](#system-dependencies)
  - [Project Setup](#project-setup)
- [Usage](#usage)
  - [Commands](#commands)
  - [Terminal UI](#terminal-ui)
  - [HTTP API](#http-api)
- [Configuration](#configuration)
- [Testing](#testing)
- [Documentation](#documentation)
- [License](#license)

## Overview

Run documentation servers for popular frameworks and languages entirely offline. Each documentation site runs in an isolated Docker container, managed via a Terminal UI or HTTP API.

**Docs included:** FastAPI, Alpine.js, Astro, PHP, Python, SlimPHP

## Quick Start

```bash
# Check dependencies
bash ood doctor

# Build Docker images
bash ood build

# Start services
bash ood up

# Open Terminal UI
bash ood tui
```

## Installation

### System Dependencies

Before using Open Offline Docs, ensure these are installed on your system:

| Dependency | Required | Purpose |
|-----------|----------|---------|
| Docker | Yes | Container runtime |
| docker-compose | Yes | Multi-container orchestration |
| Python 3 | Yes | Manager service (container control) |
| curl | Yes | HTTP API testing |
| Bun | Optional | Terminal UI runtime |

Verify all dependencies:

```bash
bash ood doctor
```

### Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/BOLD-ENGINEERING/open.offline.docs.git
   cd open.offline.docs
   ```

2. (Optional) Configure base directory:
   ```bash
   cp .env.example .env
   # Edit .env and set BASE_DIR to your absolute path
   ```

3. Build Docker images:
   ```bash
   bash ood build
   ```

4. Start services:
   ```bash
   bash ood up
   ```

## Usage

### Commands

All commands use the `ood` script:

```bash
# System
bash ood doctor          # Check system dependencies
bash ood build         # Build Docker images

# Services
bash ood up            # Start all services
bash ood up --only api  # Start only API
bash ood down          # Stop all services
bash ood status        # Show container status
bash ood clean         # Stop and prune containers

# Info
bash ood list           # List available docs
bash ood help          # Show help
bash ood tui           # Open Terminal UI
```

### Terminal UI

Launch the interactive TUI:

```bash
bash ood tui
```

Navigate with vim keys:

| Key | Action |
|-----|--------|
| `j` / `↓` | Navigate down |
| `k` / `↑` | Navigate up |
| `Enter` | Execute |
| `q` / `Esc` | Quit |

### HTTP API

Start the API service, then use:

```bash
# List all docs
curl http://127.0.0.1:8080/docs

# Start a doc
curl -X POST http://127.0.0.1:8080/docs/fastapi/start

# Stop a doc
curl -X POST http://127.0.0.1:8080/docs/fastapi/stop

# Get doc status
curl http://127.0.0.1:8080/docs/fastapi/status
```

## Configuration

Environment variables (optional):

| Variable | Used By | Description |
|----------|---------|-------------|
| `BASE_DIR` | ood, TUI | Absolute path to project root |
| `OOD_DOCS_PATH` | manager | Path to docs directory |

## Testing

See [tests/README.md](tests/README.md) for test documentation.

```bash
# Verify dependencies
bash ood test --dep

# Test API endpoints (requires API running)
bash ood test --api
```

## Documentation

See [AGENTS.md](AGENTS.md) for developer guidelines and architecture details.

## License

GPL v3. See [LICENSE](LICENSE).