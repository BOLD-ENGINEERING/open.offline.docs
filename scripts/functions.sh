#!/usr/bin/env bash

run_list() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  echo "Available Documentation Sites:"
  echo "  php       - Complete PHP language documentation"
  echo "  python    - Full Python programming language documentation"
  echo "  astro     - Modern web framework for content-focused websites"
  echo "  fastapi   - Modern, fast web framework for building APIs"
  echo "  alpine    - Minimal JavaScript framework for markup"
  echo "  slimphp   - Slim PHP framework documentation"
  echo ""
  echo "Management API:"
  echo "  api       - Service API (port $API_PORT)"
}

run_help() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  echo "  Open Offline Docs - Docker-based Documentation System"
  echo "  ------------------------------------------------------------"
  echo ""
  echo "  COMMANDS:"
  echo "    doctor           Check system dependencies"
  echo "    build            Build Docker images"
  echo "    up               Start all services"
  echo "    up --only api    Start only API service"
  echo "    down             Stop all services"
  echo "    status           Show container status"
  echo "    stop             Stop all containers"
  echo "    clean            Clean up containers and images"
  echo "    tui              Start Terminal UI"
  echo "    list             List available docs"
  echo "    test --dep       Run dependency tests"
  echo "    test --api       Run API tests"
  echo "    help             Show this help"
  echo ""
  echo "  DOC MANAGEMENT:"
  echo "    Use 'bash ood tui' to start/stop individual docs visually"
  echo ""
  echo "  OPTIONS:"
  echo "    --only=X         Start specific services (e.g., --only=api)"
  echo "    --port=X=Y       Set port for service (e.g., --port=api=9000)"
  echo ""
  echo "  EXAMPLES:"
  echo "    bash ood doctor                           # Check dependencies"
  echo "    bash ood build && bash ood up            # Build and start"
  echo "    bash ood up --only api && bash ood tui  # API + TUI"
  echo "    bash ood status                          # Check status"
  echo "    bash ood clean                           # Full cleanup"
  echo "    bash ood test --dep                      # Run dependency tests"
  echo "    bash ood test --api                      # Run API tests"
  echo ""
}

run_notice() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  echo "  Open Offline Docs - Docker-based Documentation System"
  echo ""
  echo "  Run 'bash ood help' for commands and options"
  echo "  Run 'bash ood doctor' to check system dependencies"
  echo ""
}

run_doctor() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  echo "Running system diagnostics..."
  echo ""
  
  local issues=0
  
  echo -n "Docker: "
  if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
      echo "[*] Available (daemon running)"
    else
      echo "[x] Installed but daemon not running"
      issues=$((issues + 1))
    fi
  else
    echo "[x] Not found"
    issues=$((issues + 1))
  fi
  
  echo -n "Bun: "
  if command -v bun &> /dev/null; then
    echo "[*] Available"
  else
    echo "[x] Not found (required for TUI)"
    issues=$((issues + 1))
  fi
  
  echo -n "docker-compose: "
  if docker compose version &> /dev/null; then
    echo "[*] Available"
  else
    echo "[x] Not found"
    issues=$((issues + 1))
  fi
  
  echo -n "curl: "
  if command -v curl &> /dev/null; then
    echo "[*] Available"
  else
    echo "[x] Not found"
    issues=$((issues + 1))
  fi
  
  echo -n "Python3: "
  if command -v python3 &> /dev/null; then
    echo "[*] Available"
  else
    echo "[x] Not found"
    issues=$((issues + 1))
  fi
  
  echo ""
  if [ $issues -eq 0 ]; then
    echo "All dependencies are available! [*]"
    echo "You can run: bash ood up"
  else
    echo "Found $issues issue(s). Please install missing dependencies."
  fi
}

run_tui() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  echo "[tui] Starting Terminal UI..."
  cd "$BASE_DIR/tui"
  bun run index.ts 2>&1
}

run_test() {
  echo ""
  cat "$BASE_DIR/banner.txt"
  echo ""
  if $TEST_DEP; then
    echo "[test] Running dependency tests..."
    bash "$BASE_DIR/tests/deps.sh"
  elif $TEST_API; then
    echo "[test] Running API tests..."
    bash "$BASE_DIR/tests/api.sh"
  else
    echo "[test] Usage:"
    echo "  bash ood test --dep   # Run dependency tests"
    echo "  bash ood test --api  # Run API tests (requires API running)"
  fi
}
