#!/usr/bin/env bash
set -euo pipefail

iso_dir="/vms/libvirt/iso"
images_dir="/vms/libvirt/images"
exports_dir="/vms/libvirt/vms"

printf "ISO directory: %s\n" "$iso_dir"
ls -lh "$iso_dir" 2>/dev/null || echo "(empty)"

printf "\nVM images directory: %s\n" "$images_dir"
ls -lh "$images_dir" 2>/dev/null || echo "(empty)"

printf "\nVM exports directory: %s\n" "$exports_dir"
ls -lh "$exports_dir" 2>/dev/null || echo "(empty)"
