#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8081/health}"
NAME="${2:-prod-automation}"

for n in $(seq 1 30); do
  if curl -fsS "$URL" >/dev/null; then
    echo "SMOKE_OK url=$URL"
    exit 0
  fi
  echo "SMOKE_retry_$n"
  sleep 2
done

echo "SMOKE_FAIL url=$URL"
docker logs --tail=200 "$NAME" || true
exit 1
