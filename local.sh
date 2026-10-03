#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/src/.env"
COMPOSE=(docker compose --env-file "$ENV_FILE")

export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

ensure_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    cp "$ROOT_DIR/src/.env.example" "$ENV_FILE"
    echo "Created src/.env from src/.env.example. Review it before running in production."
  fi
}

compose() {
  ensure_env
  "${COMPOSE[@]}" "$@"
}

case "${1:-help}" in
  init)
    compose up -d --build
    compose exec -T --user "$HOST_UID:$HOST_GID" app composer install
    compose exec -T --user "$HOST_UID:$HOST_GID" app php artisan key:generate
    compose exec -T --user "$HOST_UID:$HOST_GID" app php artisan migrate --force
    compose exec -T --user "$HOST_UID:$HOST_GID" app npm install
    ;;
  up|start) compose up -d ;;
  rebuild) compose up -d --build --force-recreate --remove-orphans ;;
  down) compose down ;;
  stop) compose stop ;;
  restart) compose restart ;;
  logs)
    if [[ $# -gt 1 ]]; then
      compose logs -f "$2"
    else
      compose logs -f
    fi
    ;;
  shell|ssh) compose exec --user "$HOST_UID:$HOST_GID" app bash ;;
  artisan) shift; compose exec -T --user "$HOST_UID:$HOST_GID" app php artisan "$@" ;;
  composer) shift; compose exec -T --user "$HOST_UID:$HOST_GID" app composer "$@" ;;
  npm) shift; compose exec -T --user "$HOST_UID:$HOST_GID" app npm "$@" ;;
  permissions) compose exec -T app chown -R "$HOST_UID:$HOST_GID" storage bootstrap/cache ;;
  help|--help|-h)
    cat <<'USAGE'
Usage: ./local.sh <command>

Commands: init, up (start), rebuild, down, stop, restart, logs [service],
          shell (ssh), artisan <args>, composer <args>, npm <args>, permissions
USAGE
    ;;
  *) echo "Unknown command: $1. Run ./local.sh help." >&2; exit 1 ;;
esac
