#!/usr/bin/env bash
# API Endpoint Tests
# Run with: bash tests/api.sh

set -e

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo "Testing: $1"; }

echo "============================================="
echo "  Open Offline Docs - API Tests"
echo "============================================="
echo ""

# Check API is running
info "Health check"
response=$(curl -s "$BASE_URL/" || echo "failed")
if echo "$response" | grep -q "open-offline-docs-api"; then
    pass "API is running"
else
    fail "API not reachable at $BASE_URL"
fi

# Test: GET /docs (list all docs)
info "GET /docs - List all docs"
response=$(curl -s "$BASE_URL/docs")
if echo "$response" | grep -q "fastapi"; then
    pass "List docs returns fastapi"
else
    fail "List docs failed"
fi

# Test: POST /docs/{name}/start (start a doc)
info "POST /docs/fastapi/start - Start doc"
response=$(curl -s -X POST "$BASE_URL/docs/fastapi/start")
if echo "$response" | grep -q "started\|already_running"; then
    pass "Start doc fastapi"
else
    fail "Start doc failed: $response"
fi

# Test: GET /docs/{name}/status (get doc status)
info "GET /docs/fastapi/status - Get status"
response=$(curl -s "$BASE_URL/docs/fastapi/status")
if echo "$response" | grep -q "running"; then
    pass "Get doc status"
else
    fail "Get doc status failed"
fi

# Test: POST /docs/{name}/stop (stop a doc)
info "POST /docs/fastapi/stop - Stop doc"
response=$(curl -s -X POST "$BASE_URL/docs/fastapi/stop")
if echo "$response" | grep -q "stopped"; then
    pass "Stop doc fastapi"
else
    fail "Stop doc failed"
fi

# Test: GET /docs/{name}/status after stop
info "GET /docs/fastapi/status - Verify stopped"
response=$(curl -s "$BASE_URL/docs/fastapi/status")
if echo "$response" | grep -q "exited\|not_found"; then
    pass "Doc is stopped"
else
    warn "Doc may still be running: $response"
fi

# Test: Unknown doc returns 404
info "GET /docs/nonexistent/status - Unknown doc"
response=$(curl -s -w "%{http_code}" "$BASE_URL/docs/nonexistent/status")
if echo "$response" | grep -q "404\|Unknown doc"; then
    pass "Unknown doc returns error"
else
    fail "Unknown doc should return error"
fi

echo ""
echo "============================================="
echo -e "${GREEN}All API tests passed!${NC}"
echo "============================================="
