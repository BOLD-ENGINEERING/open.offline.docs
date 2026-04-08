#!/usr/bin/env bash
# System Dependency Tests
# Run with: bash tests/deps.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

EXPECTED_PYTHON="3"
EXPECTED_DOCKER="2[0-9]"
EXPECTED_CURL="[78]"

echo "============================================="
echo "  Open Offline Docs - Dependency Tests"
echo "============================================="
echo ""

issues=0
missing_deps=()

# Docker
echo -n "Docker: "
if command -v docker &> /dev/null; then
    version=$(docker --version | grep -oE '[0-9]+' | head -1)
    if [[ "$version" =~ $EXPECTED_DOCKER ]]; then
        pass "docker $version (required: $EXPECTED_DOCKER+)"
    else
        fail "docker $version (expected: $EXPECTED_DOCKER+)"
        issues=$((issues + 1))
        missing_deps+=("docker")
    fi
else
    fail "not found"
    issues=$((issues + 1))
    missing_deps+=("docker")
fi

# docker-compose
echo -n "docker-compose: "
if command -v docker &> /dev/null; then
    if docker compose version &> /dev/null; then
        version=$(docker compose version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        pass "docker-compose $version"
    else
        fail "plugin not available"
        issues=$((issues + 1))
        missing_deps+=("docker-compose")
    fi
else
    fail "docker not installed"
    issues=$((issues + 1))
    missing_deps+=("docker")
fi

# Python 3
echo -n "Python 3: "
if command -v python3 &> /dev/null; then
    version=$(python3 --version | grep -oE '[0-9]+' | head -1)
    if [[ "$version" -ge "$EXPECTED_PYTHON" ]]; then
        pass "python3 $version"
    else
        fail "python3 $version (expected: 3+)"
        issues=$((issues + 1))
        missing_deps+=("python")
    fi
else
    fail "not found"
    issues=$((issues + 1))
    missing_deps+=("python")
fi

# curl
echo -n "curl: "
if command -v curl &> /dev/null; then
    version=$(curl --version | grep -oE 'curl [0-9]+\.[0-9]+' | grep -oE '[0-9]+' | head -1)
    if [[ "$version" =~ $EXPECTED_CURL ]]; then
        pass "curl $version"
    else
        fail "curl $version (expected: 7+)"
        issues=$((issues + 1))
        missing_deps+=("curl")
    fi
else
    fail "not found"
    issues=$((issues + 1))
    missing_deps+=("curl")
fi

# Bun (optional)
echo -n "Bun (optional): "
if command -v bun &> /dev/null; then
    version=$(bun --version)
    pass "bun $version"
else
    warn "not installed (optional for TUI)"
fi

echo ""
echo "Paths:"
echo "  docker:   $(command -v docker 2>/dev/null || echo 'not in PATH')"
echo "  python3:  $(command -v python3 2>/dev/null || echo 'not in PATH')"
echo "  curl:     $(command -v curl 2>/dev/null || echo 'not in PATH')"
echo "  bun:      $(command -v bun 2>/dev/null || echo 'not in PATH')"
echo "  composer: $(command -v composer 2>/dev/null || echo 'not in PATH')"
echo ""

if [ $issues -eq 0 ]; then
    echo "============================================="
    echo -e "${GREEN}All required dependencies satisfied!${NC}"
    echo "============================================="
else
    echo "============================================="
    echo -e "${RED}$issues issue(s) found. Please install missing dependencies.${NC}"
    echo "============================================="
    echo ""
    echo "Recommended:"
    for dep in "${missing_deps[@]}"; do
        case "$dep" in
            docker)
                echo "  Docker:       https://www.docker.com/get-started/"
                ;;
            docker-compose)
                echo "  docker-compose: https://docs.docker.com/compose/install/"
                ;;
            python)
                echo "  Python 3:     https://www.python.org/downloads/"
                ;;
            curl)
                echo "  curl:         https://curl.se/download.html"
                ;;
        esac
    done
    echo ""
    echo "Optional (for TUI):"
    echo "  Bun:          https://bun.sh/"
    exit 1
fi