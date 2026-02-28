#!/usr/bin/env bash
set -euo pipefail

iso_url="${1:-}"
sha256_expected="${2:-}"
iso_dir="/vms/libvirt/iso"

if [ -z "$iso_url" ]; then
  echo "Usage: fetch-iso.sh <url> [sha256]" >&2
  exit 1
fi

mkdir -p "$iso_dir"

filename="${iso_url##*/}"
output_path="$iso_dir/$filename"

echo "Downloading $iso_url -> $output_path"

curl -L --fail --continue-at - --output "$output_path" "$iso_url"

if [ -n "$sha256_expected" ]; then
  echo "$sha256_expected  $output_path" | sha256sum -c -
  echo "SHA256 verified."
fi

ls -lh "$output_path"
