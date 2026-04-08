#!/bin/bash

set -e

DOC_TYPE="${DOC_TYPE:-static}"
PORT="${PORT:-8000}"
DOC_PATH="${DOC_PATH:-/app}"

echo "Starting doc server..."
echo "  Type: $DOC_TYPE"
echo "  Port: $PORT"
echo "  Path: $DOC_PATH"

cd "$DOC_PATH"

case "$DOC_TYPE" in
    mkdocs)
        echo "Starting MkDocs server..."
        exec python3 -m mkdocs serve --dev-addr "0.0.0.0:$PORT"
        ;;
    astro)
        echo "Starting Astro dev server..."
        if command -v pnpm &> /dev/null; then
            exec pnpm dev -- --host "0.0.0.0" --port "$PORT"
        else
            exec npm run dev -- --host "0.0.0.0" --port "$PORT"
        fi
        ;;
    jekyll)
        echo "Starting Jekyll server..."
        exec bundle exec jekyll serve --host "0.0.0.0" --port "$PORT"
        ;;
    static)
        echo "Starting static file server..."
        exec python3 -m http.server "$PORT"
        ;;
    *)
        echo "Unknown doc type: $DOC_TYPE"
        echo "Defaulting to static server..."
        exec python3 -m http.server "$PORT"
        ;;
esac
