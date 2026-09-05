#!/bin/sh
set -eu

HOST="${MINIO_HOST:-127.0.0.1}"
API_PORT="${MINIO_API_PORT:-9000}"
BUCKET="${BUCKET_NAME:-bucket}"
USER="${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
PASS="${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"

echo "Waiting for MinIO at ${HOST}:${API_PORT}"

TRIES=0
MAX_TRIES=60

while [ "$TRIES" -lt "$MAX_TRIES" ]; do
  if mc alias set local "http://${HOST}:${API_PORT}" "$USER" "$PASS" >/dev/null 2>&1 \
    && mc ready local >/dev/null 2>&1; then
    break
  fi
  TRIES=$((TRIES + 1))
  sleep 2
done

if [ "$TRIES" -ge "$MAX_TRIES" ]; then
  echo "MinIO did not become ready in time"
  exit 1
fi

mc mb --ignore-existing "local/${BUCKET}"
echo "Bucket ${BUCKET} is ready"
exit 0
