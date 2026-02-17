#!/usr/bin/env bash
set -euo pipefail

export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

tofu \
  -chdir=infra/terraform \
  "$@" \
  -var-file <(sops -d infra/terraform/terraform.sops.tfvars)

