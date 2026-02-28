#!/usr/bin/env bash
set -euo pipefail

mirror="https://docker.mirrors.tuna.tsinghua.edu.cn"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi

printf "Checking Docker registry mirror: %s\n" "$mirror"

status=$(curl -s -o /dev/null -w "%{http_code}" "$mirror/v2/")

if [ "$status" = "200" ]; then
  echo "Mirror reachable (HTTP 200)"
else
  echo "Mirror check failed (HTTP $status)" >&2
  exit 1
fi
