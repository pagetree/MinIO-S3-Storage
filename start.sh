#!/bin/sh
set -eu

DATA_DIR="${RAILWAY_VOLUME_MOUNT_PATH:-/data}"
API_PORT="${PORT:-9000}"
CONSOLE_PORT="${MINIO_CONSOLE_PORT:-9001}"
export MINIO_HOST="${MINIO_HOST:-127.0.0.1}"
export MINIO_API_PORT="$API_PORT"

mkdir -p "$DATA_DIR"

CREDS_FILE="${DATA_DIR}/.root-credentials"

if [ -z "${MINIO_ROOT_USER:-}" ] || [ -z "${MINIO_ROOT_PASSWORD:-}" ]; then
  if [ -f "$CREDS_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CREDS_FILE"
  else
    MINIO_ROOT_USER="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)"
    MINIO_ROOT_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 40)"
    umask 077
    printf 'MINIO_ROOT_USER=%s\nMINIO_ROOT_PASSWORD=%s\n' \
      "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" > "$CREDS_FILE"
    echo "Generated MinIO credentials and saved them on the volume"
    echo "MINIO_ROOT_USER=${MINIO_ROOT_USER}"
    echo "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}"
  fi
  export MINIO_ROOT_USER MINIO_ROOT_PASSWORD
fi

if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export MINIO_SERVER_URL="${MINIO_SERVER_URL:-https://${RAILWAY_PUBLIC_DOMAIN}}"
  export MINIO_BROWSER_REDIRECT_URL="${MINIO_BROWSER_REDIRECT_URL:-https://${RAILWAY_PUBLIC_DOMAIN}}"
fi

minio server "$DATA_DIR" --address ":${API_PORT}" --console-address ":${CONSOLE_PORT}" &
MINIO_PID=$!

stop() {
  kill -TERM "$MINIO_PID" 2>/dev/null || true
  wait "$MINIO_PID" 2>/dev/null || true
}

trap stop INT TERM

/usr/local/bin/init-bucket.sh
wait "$MINIO_PID"
