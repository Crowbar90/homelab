#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages (ps: [ps.scramp ps.pyyaml])" "sops"
"""Compute the SCRAM-SHA-256 hash for the sonarr postgres password.

Reads the plaintext from the helm chart's SOPS-encrypted secrets
manifest. By default uses
infra/k8s/helm/charts/sonarr/secrets.enc.yaml; override with the
SONARR_SECRETS_FILE env var. The plaintext is never embedded in
this script or in the repo.
"""
import base64
import os
import subprocess
import sys

import scramp

SECRETS_FILE = os.environ.get(
    "SONARR_SECRETS_FILE",
    "infra/k8s/helm/charts/sonarr/secrets.enc.yaml",
)

SOPS_CONFIG = os.environ.get(
    "SOPS_CONFIG",
    "infra/k8s/.sops.yaml",
)

decrypted = subprocess.run(
    [
        "sops",
        "--config",
        SOPS_CONFIG,
        "--decrypt",
        SECRETS_FILE,
    ],
    check=True,
    capture_output=True,
    text=True,
).stdout

import yaml

doc = yaml.safe_load(decrypted)
controllers = yaml.safe_load(doc["stringData"]["controllers"])
password = controllers["sonarr"]["containers"]["sonarr"]["env"][
    "SONARR__POSTGRES__PASSWORD"
]

if not password:
    sys.exit(f"empty password in {SECRETS_FILE}")

m = scramp.ScramMechanism()
salt, stored_key, server_key, iteration_count = m.make_auth_info(password)
print(
    f"SCRAM-SHA-256${iteration_count}:"
    f"{base64.b64encode(salt).decode()}"
    f"${base64.b64encode(stored_key).decode()}:"
    f"{base64.b64encode(server_key).decode()}"
)
