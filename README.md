# open.docs

Monolithic repository of forked open-source frameworks and programming language documentation for offline development.

## Overview

This repository aggregates documentation from various open-source frameworks and programming languages into a single monolithic structure. It's designed for offline development environments where you need quick access to comprehensive documentation without relying on internet connectivity.

The documentation covers:
- **Astro** - Modern web framework for content-focused websites
- **FastAPI** - Modern, fast web framework for building APIs with Python 3.7+
- **Alpine.js** - Rugged, minimal framework for composing JavaScript behavior in markup
- **Python** - Full Python programming language documentation
- **PHP** - Complete PHP language documentation

## Getting Started

### Prerequisites

- **Node.js** and **pnpm** (for Astro docs)
- **Python 3.7+** (for MkDocs-based sites)
- **git**

### Quick Start

The recommended way to run all documentation servers is using the `ood` (Open Offline Docs) script:

```bash
# Clone the repository
git clone <repository-url>
cd open.offline.docs

# Run all documentation servers
bash ood --all
```

This will:
- Create a shared Python virtual environment in `.venv/`
- Install all required Python packages from `requirements.txt`
- Start all documentation servers on their respective ports:
  - FastAPI: http://127.0.0.1:8000
  - Alpine.js: http://127.0.0.1:8004
  - Astro: http://127.0.0.1:8003
  - PHP: http://127.0.0.1:8002
  - Python: http://127.0.0.1:8001

### Individual Services

Run specific documentation sites:

```bash
# Run only FastAPI and Alpine docs (Python services)
bash ood --only fastapi,alpine

# Run only Astro docs
bash ood --only astro

# Run with custom ports
bash ood --only fastapi --port fastapi=9000
```

### Stop All Services

```bash
bash ood stop
```

### Manual Setup

If you prefer to run services individually:

#### Astro Docs

```bash
cd astro.docs
pnpm install
pnpm dev  # Starts on port 3000 by default
```

#### FastAPI/Alpine Docs

```bash
# From project root
source .venv/bin/activate

# FastAPI
cd fastapi.docs
mkdocs serve

# Alpine.js
cd ../alpine.docs
mkdocs serve
```

## Project Structure

```
open.offline.docs/
├── .venv/                    # Shared Python virtual environment (auto-created)
├── astro.docs/               # Astro framework documentation
│   ├── src/                  # Source files
│   └── package.json          # Node.js dependencies
├── fastapi.docs/             # FastAPI documentation
│   ├── docs_src/             # Source code examples
│   └── mkdocs.yml            # MkDocs configuration
├── alpine.docs/              # Alpine.js documentation
│   ├── docs/                 # Documentation source
│   └── mkdocs.yml            # MkDocs configuration
├── python.docs/              # Python language docs (read-only, generated)
├── php.docs/                 # PHP language docs (read-only, generated)
├── requirements.txt          # Python dependencies (shared for MkDocs sites)
└── ood                       # Unified documentation server script
```

## Building for Production

### Astro Docs

```bash
cd astro.docs
pnpm build
pnpm preview
```

### MkDocs Sites (FastAPI, Alpine)

```bash
source .venv/bin/activate
cd fastapi.docs  # or alpine.docs
mkdocs build
```

## Development

### Code Style

For code style guidelines and contributing guidelines, see [AGENTS.md](AGENTS.md).

### Running Tests

```bash
# FastAPI tests
cd fastapi.docs
source ../.venv/bin/activate
pytest docs_src/app_testing/app_a_py310/test_main.py

# Astro linting
cd astro.docs
pnpm lint:eslint
pnpm check
```

## AI Training and Crawling Policy

**This repository is intended for offline development and educational purposes only.**

To prevent unauthorized AI training and web crawling:

1. **For AI Companies**: This repository contains documentation from various open-source projects. The original maintainers of these frameworks have their own licensing terms. Please respect those terms and do not use this aggregated content for training AI models without proper authorization.

2. **For Crawlers**: If you're building a search index or crawler, note that:
   - The documentation in this repository is already indexed by the respective official projects
   - Crawling this monolithic repository provides no additional value
   - Respect `robots.txt` files in individual documentation sites

3. **For Researchers**: This repository is for offline access convenience. For research purposes, please:
   - Cite the original sources/frameworks
   - Follow the original projects' attribution requirements
   - Don't create derivative works that misrepresent the original documentation

## License

This repository aggregates documentation from various open-source projects with their own licenses:
- **Astro**: MIT License
- **FastAPI**: MIT License
- **Alpine.js**: MIT License
- **Python**: PSF License
- **PHP**: various licenses

See individual project directories and their LICENSE files for specific license information.

## Contributing

This repository primarily serves as an offline documentation aggregator. For contributions to the actual documentation:

- **Astro**: https://github.com/withastro/astro
- **FastAPI**: https://github.com/fastapi/fastapi
- **Alpine.js**: https://github.com/alpinejs/alpine
- **Python**: https://github.com/python/cpython
- **PHP**: https://github.com/php/doc-en

For maintainers of this repository, see [AGENTS.md](AGENTS.md) for development guidelines.

## Credits and Attribution

This repository aggregates and hosts documentation from the following open-source projects:

- [Astro](https://astro.build) - The Astro web framework team
- [FastAPI](https://fastapi.tiangolo.com) - Sebastián Ramírez and contributors
- [Alpine.js](https://alpinejs.dev) - Caleb Porzio and contributors
- [Python](https://www.python.org) - Python Software Foundation
- [PHP](https://www.php.net) - The PHP Group and contributors

All documentation remains property of their respective owners. This repository simply provides a centralized, offline-accessible format for development convenience.

---

**Used by BOLD Engineering** for offline development environments.
