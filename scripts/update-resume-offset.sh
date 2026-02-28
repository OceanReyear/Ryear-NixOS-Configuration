#!/usr/bin/env bash
set -euo pipefail

config_file="/etc/nixos/hosts/reyear-nixos/configuration.nix"
swapfile="/swap/swapfile"
btrfs_bin="/run/current-system/sw/bin/btrfs"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root." >&2
  exit 1
fi

if [ ! -f "$swapfile" ]; then
  echo "Swapfile not found at $swapfile" >&2
  exit 1
fi

if [ ! -x "$btrfs_bin" ]; then
  echo "btrfs not found at $btrfs_bin" >&2
  exit 1
fi

offset="$($btrfs_bin inspect-internal map-swapfile -r "$swapfile" 2>/dev/null || true)"

if [ -z "$offset" ]; then
  echo "Failed to read resume offset from $swapfile" >&2
  exit 1
fi

if ! grep -q 'resumeOffset = "' "$config_file"; then
  echo "resumeOffset setting not found in $config_file" >&2
  exit 1
fi

sed -i -E "s/(resumeOffset = \\")[0-9]+(\\";)/\\1${offset}\\2/" "$config_file"

echo "Updated resumeOffset to $offset in $config_file"
echo "Run: nixos-rebuild switch --flake /etc/nixos#reyear-nixos"
