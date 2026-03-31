# Bootstrap Charts

Charts with `spec.bootstrap: true` in their `HelmChart` manifest are deployed by the k3s Helm Controller **during cluster startup**, before other workloads are scheduled.

This is the native, declarative way to mark a chart as cluster-critical — no symlinking or copying into `/var/lib/rancher/k3s/server/manifests/` needed.

## How to mark a chart as bootstrap

Simply set `spec.bootstrap: true` in the chart's `helmchart.yaml`:

```yaml
spec:
  bootstrap: true
  chart: ...
```

## Apply order for a fresh cluster

Even with `spec.bootstrap: true`, the corresponding Kubernetes `Secret` (from `secrets.enc.yaml`) must exist before the Helm Controller can render the chart values. Apply in this order:

```bash
# 1. Apply namespaces
kubectl apply -f infra/k8s/helm/namespaces/

# 2. Apply secrets for bootstrap charts
sops -d infra/k8s/helm/charts/nfs-subdir-provisioner/secrets.enc.yaml | kubectl apply -f -

# 3. Apply bootstrap charts
kubectl apply -f infra/k8s/helm/charts/nfs-subdir-provisioner/helmchart.yaml

# 4. Wait for the StorageClass to be ready, then apply remaining charts
kubectl apply -f infra/k8s/helm/charts/home-assistant/helmchart.yaml
# ... etc
```

## Currently bootstrap-required charts

| Chart | Reason |
|---|---|
| `nfs-subdir-provisioner` | Provides the `nfs-client` StorageClass — required by all PVCs |
