#!/usr/bin/env bash
# Command flag parsing

ONLY=""
LIST=false
HELP=false
STOP=false
CLEAN=false
STATUS=false
BUILD=false
UP=false
DOWN=false
TUI=false
DOCTOR=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    tui)
      TUI=true
      shift
      ;;
    doctor)
      DOCTOR=true
      shift
      ;;
    clean)
      CLEAN=true
      shift
      ;;
    list)
      LIST=true
      shift
      ;;
    help)
      HELP=true
      shift
      ;;
    --only)
      ONLY="$2"
      shift 2
      ;;
    --port)
      IFS='=' read -r name port <<< "$2"
      case "$name" in
        php) PHP_PORT=$port ;;
        python) PYTHON_PORT=$port ;;
        fastapi) FASTAPI_PORT=$port ;;
        alpine) ALPINE_PORT=$port ;;
        astro) ASTRO_PORT=$port ;;
        slimphp) SLIMPHP_PORT=$port ;;
        api) API_PORT=$port ;;
        *) echo "Unknown service for --port: $name"; exit 1 ;;
      esac
      shift 2
      ;;
    stop)
      STOP=true
      shift
      ;;
    build)
      BUILD=true
      shift
      ;;
    up)
      UP=true
      shift
      ;;
    down)
      DOWN=true
      shift
      ;;
    status)
      STATUS=true
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done