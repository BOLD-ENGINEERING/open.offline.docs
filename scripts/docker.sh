#!/usr/bin/env bash
# Docker-related functions

docker_build() {
  echo "[docker] Building Docker images..."
  cd "$BASE_DIR"
  
  echo "[*] Building doc-base image..."
  docker compose -f "$DOCKER_DIR/docker-compose.yml" build doc-base
  echo "[*] Building API image..."
  docker compose -f "$DOCKER_DIR/docker-compose.yml" build api
  
  echo "[docker] Build complete."
  echo ""
  echo "Images built:"
  echo "  - ood-doc-base:latest (doc containers)"
  echo "  - ood-api:latest (API service)"
}

docker_up() {
  echo "[docker] Starting services..."
  cd "$BASE_DIR"
  
  if [ -n "$ONLY" ]; then
    IFS=',' read -ra SERVICES <<< "$ONLY"
    for svc in "${SERVICES[@]}"; do
      case "$svc" in
        api)
          echo "[docker] Starting API service..."
          docker compose -f "$DOCKER_DIR/docker-compose.yml" up -d api
          ;;
        *)
          echo "[docker] Unknown service: $svc"
          ;;
      esac
    done
    echo "[docker] Done."
  else
    docker compose -f "$DOCKER_DIR/docker-compose.yml" up -d
  fi
  
  echo ""
  echo "Services:"
  echo "  API:   http://127.0.0.1:$API_PORT"
  echo "  Docs:  Use 'bash ood tui' to manage"
  echo ""
  echo "Next: Run 'bash ood tui' to start/stop docs"
}

docker_down() {
  echo "[docker] Stopping services..."
  cd "$BASE_DIR"
  
  if [ -n "$ONLY" ]; then
    IFS=',' read -ra SERVICES <<< "$ONLY"
    for svc in "${SERVICES[@]}"; do
      case "$svc" in
        api)
          echo "[docker] Stopping API..."
          docker compose -f "$DOCKER_DIR/docker-compose.yml" stop api
          ;;
        *)
          echo "[docker] Unknown service: $svc"
          ;;
      esac
    done
  else
    docker compose -f "$DOCKER_DIR/docker-compose.yml" down
  fi
  echo "[docker] Services stopped."
}

docker_status() {
  echo "[docker] Service status:"
  cd "$BASE_DIR"
  docker compose -f "$DOCKER_DIR/docker-compose.yml" ps
}

docker_clean() {
  echo "[docker] Cleaning up..."
  docker_down
  
  echo "[docker] Pruning unused containers..."
  docker container prune -f
  
  echo "[docker] Cleanup complete."
}