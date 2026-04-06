#!/usr/bin/env bash
# Variables and configuration

PROJECT_NAME="OOD"
PROJECT_FULL="Open Offline Docs"

# Get the directory where this script (ood) is located
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_DIR="${BASE_DIR:-$SCRIPT_PATH}"
SCRIPT_DIR="${SCRIPT_DIR:-$SCRIPT_PATH/scripts}"
MANAGER_DIR="$BASE_DIR/manager"
API_DIR="$BASE_DIR/api"
DOCKER_DIR="$BASE_DIR/docker"
DOCS_DIR="$BASE_DIR/docs"

# Port configurations
PHP_PORT=8002
ASTRO_PORT=8003
PYTHON_PORT=8001
ALPINE_PORT=8004
FASTAPI_PORT=8000
SLIMPHP_PORT=8005
API_PORT=8080