#!/usr/bin/env bash
#
# Build and deploy the NixOS Proxmox VM template.
#
# Usage:
#   ./scripts/deploy-template.sh [PROXMOX_SSH] [TEMPLATE_ID] [STORAGE]
#
# Defaults:
#   PROXMOX_SSH  = root@192.168.40.10 (or set PROXMOX_SSH env var)
#   TEMPLATE_ID  = 9002               (or set TEMPLATE_ID env var)
#   STORAGE      = local-lvm          (or set STORAGE env var)

set -euo pipefail

PROXMOX_SSH="${1:-${PROXMOX_SSH:-root@192.168.40.10}}"
TEMPLATE_ID="${2:-${TEMPLATE_ID:-9002}}"
STORAGE="${3:-${STORAGE:-local-lvm}}"
# Proxmox dump directory – qmrestore requires the VMA to live here
PROXMOX_DUMP_DIR="/var/lib/vz/dump"
REMOTE_VMA="${PROXMOX_DUMP_DIR}/vzdump-qemu-${TEMPLATE_ID}.vma.zst"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="${REPO_ROOT}/templates/nixos-template"

echo "==> Building NixOS Proxmox image..."
#nix build "${TEMPLATE_DIR}#proxmox" --extra-experimental-features nix-command --extra-experimental-features flakes

VMA_FILE=$(find "${TEMPLATE_DIR}/result/" -name '*.vma.zst' | head -1)
if [ -z "$VMA_FILE" ]; then
  echo "ERROR: No VMA file found in build output"
  exit 1
fi
echo "    Built: ${VMA_FILE}"

echo "==> Uploading VMA to Proxmox dump dir (${PROXMOX_SSH}:${REMOTE_VMA})..."
ssh "$PROXMOX_SSH" "mkdir -p ${PROXMOX_DUMP_DIR}"
rsync "$VMA_FILE" "${PROXMOX_SSH}:${REMOTE_VMA}"

echo "==> Checking if VM ${TEMPLATE_ID} already exists..."
if ssh "$PROXMOX_SSH" "qm status ${TEMPLATE_ID}" &>/dev/null; then
  echo "    Destroying existing VM ${TEMPLATE_ID}..."
  ssh "$PROXMOX_SSH" "qm destroy ${TEMPLATE_ID} --purge"
fi

echo "==> Restoring VMA as VM ${TEMPLATE_ID}..."
ssh "$PROXMOX_SSH" "qmrestore ${REMOTE_VMA} ${TEMPLATE_ID} --storage ${STORAGE} --unique true"

echo "==> Converting VM ${TEMPLATE_ID} to template..."
ssh "$PROXMOX_SSH" "qm template ${TEMPLATE_ID}"

echo "==> Cleaning up remote VMA file..."
ssh "$PROXMOX_SSH" "rm -f ${REMOTE_VMA}"

echo "==> Done! Template VM ${TEMPLATE_ID} is ready."
