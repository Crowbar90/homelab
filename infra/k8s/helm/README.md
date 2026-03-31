# Helm Charts — Infrastructure as Code

This directory contains declarative Helm chart deployments for the k3s homelab cluster.
Charts are managed via the **k3s Helm Controller** using the `HelmChart` CRD — no manual `helm install` required.

## Directory Structure

```
helm/
├── _bootstrap/        # Documents which charts use spec.bootstrap: true
├── namespaces/        # Namespace manifests (applied before charts)
└── charts/
    └── <chart-name>/
        ├── helmchart.yaml      # k3s HelmChart CRD (deployment declaration + all non-sensitive values)
        └── secrets.enc.yaml    # sops-encrypted Kubernetes Secret (sensitive values only)
```

## How it works

Each chart has two components:

| File | Purpose | Committed? |
|---|---|---|
| `helmchart.yaml` | k3s `HelmChart` CRD — chart source, version, `valuesContent` (non-sensitive), and `valuesSecret` reference | ✅ Yes |
| `secrets.enc.yaml` | sops-encrypted `Secret` manifest with sensitive values | ✅ Yes (encrypted) |

**`helmchart.yaml` is the single source of truth for non-sensitive values** — they live in `spec.valuesContent` inline. The Helm Controller merges these with values from `spec.valuesSecret` at deploy time.

Sensitive values are passed via `spec.valuesSecret`, pointing to a Kubernetes `Secret` whose `data.values.yaml` key contains additional Helm values that get merged in on top.

### Bootstrap charts

Charts with `spec.bootstrap: true` are deployed by the k3s Helm Controller during cluster startup, before other workloads are scheduled. See [`_bootstrap/README.md`](./_bootstrap/README.md).

## Adding a new chart

1. **Create the chart directory:**
   ```bash
   mkdir -p infra/k8s/helm/charts/<chart-name>
   ```

2. **Create a namespace** (if needed) in `namespaces/<name>.yaml`.

3. **Write `helmchart.yaml`** — copy an existing one as a template. Set `spec.chart`, `spec.repo`, `spec.version`, `spec.targetNamespace`, and put all non-sensitive values in `spec.valuesContent`. Add `spec.bootstrap: true` if the chart must run at cluster startup.

4. **Create and encrypt `secrets.enc.yaml`:**
   ```bash
   # Create the plaintext template (DO NOT COMMIT THIS):
   cp infra/k8s/helm/charts/nfs-subdir-provisioner/secrets.enc.yaml \
      infra/k8s/helm/charts/<chart-name>/secrets.yaml
   # Edit your values, then encrypt:
   sops --config infra/k8s/.sops.yaml \
     -e infra/k8s/helm/charts/<chart-name>/secrets.yaml \
     > infra/k8s/helm/charts/<chart-name>/secrets.enc.yaml
   # Remove the plaintext copy:
   rm infra/k8s/helm/charts/<chart-name>/secrets.yaml
   ```

5. **Apply to the cluster:**
   ```bash
   # Apply namespace first
   kubectl apply -f infra/k8s/helm/namespaces/<namespace>.yaml
   # Decrypt and apply the secret
   sops --config infra/k8s/.sops.yaml \
     -d infra/k8s/helm/charts/<chart-name>/secrets.enc.yaml | kubectl apply -f -
   # Apply the HelmChart manifest
   kubectl apply -f infra/k8s/helm/charts/<chart-name>/helmchart.yaml
   ```

## Editing an encrypted secret

```bash
# sops opens the file in your $EDITOR, re-encrypts on save
sops --config infra/k8s/.sops.yaml infra/k8s/helm/charts/<chart-name>/secrets.enc.yaml
```

## Editing non-sensitive values

Edit `spec.valuesContent` directly in `helmchart.yaml` and re-apply:
```bash
kubectl apply -f infra/k8s/helm/charts/<chart-name>/helmchart.yaml
```

## Bootstrap charts

See [`_bootstrap/README.md`](./_bootstrap/README.md) for charts that must run before all others (e.g. storage provisioners).

## Sensitive vs. non-sensitive values

| Put in `secrets.enc.yaml` | Put in `helmchart.yaml` `valuesContent` |
|---|---|
| Passwords, API keys, tokens | Storage class names |
| TLS private keys | Replica counts / resource limits |
| Webhook URLs (Slack, etc.) | Container image references |
| SMTP credentials | Chart version pins |
| OAuth client secrets | Access modes, reclaim policies |
| Internal IPs & hostnames | Public domain names |
| NFS server IP & share path | Mount options (nfsvers, etc.) |
