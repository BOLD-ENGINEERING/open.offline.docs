# Tests

## Running Tests

### 1. Dependency Tests

Verify system dependencies are installed:

```bash
bash tests/deps.sh
```

This checks:
- Docker (required)
- docker-compose (required)
- Python 3 (required)
- curl (required)
- Bun (optional, for TUI)

### 2. API Tests

Start the API first, then run endpoint tests:

```bash
# Start API
bash ood up --only api

# Run API tests
bash tests/api.sh
```

Tests all endpoints:
- `GET /` — Health check
- `GET /docs` — List all docs
- `POST /docs/{name}/start` — Start a doc
- `GET /docs/{name}/status` — Get doc status
- `POST /docs/{name}/stop` — Stop a doc

### 3. Full Test Suite

Run both:

```bash
bash tests/deps.sh && bash tests/api.sh
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `http://127.0.0.1:8080` | API base URL |
