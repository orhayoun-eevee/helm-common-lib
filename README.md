# helm-common-lib

Unified Helm library chart for application deployment. Provides reusable templates for Deployment, Services, Ingress, Monitoring, Persistence, and more.

## Overview

This repository contains:
- **`libChart/`**: The library chart (published to OCI) - reusable templates for building custom charts
- **`appChart/`**: Generic application chart (published to OCI) - ready-to-use standardized deployment template

Both charts are published to GitHub Container Registry (GHCR) and can be used as dependencies in other Helm charts.

## Publishing a Release

Both charts are automatically published to GitHub Container Registry (GHCR) when you push a git tag. They are published in **lockstep** with synchronized versions.

### Release Process

1. **Update the chart version** in `libChart/Chart.yaml`:
   ```yaml
   version: 0.0.2  # Bump to your desired version
   ```

2. **Commit the change**:
   ```bash
   git add libChart/Chart.yaml
   git commit -m "chore: bump version to 0.0.2"
   ```

3. **Create and push a git tag** matching the version (with `v` prefix):
   ```bash
   git tag v0.0.2
   git push origin v0.0.2
   ```

4. **GitHub Actions will automatically**:
   - Verify the tag matches the chart version
   - Lint both charts
   - Validate manifests with kubeconform
   - Package and publish `lib-chart` to `oci://ghcr.io/orhayoun-eevee/libchart`
   - Sync `app-chart` version and update its dependency to use the published `lib-chart`
   - Package and publish `app-chart` to `oci://ghcr.io/orhayoun-eevee/app-chart`

### Version Verification

The workflow enforces that the git tag version (e.g., `v0.0.2`) must exactly match the `version` field in `libChart/Chart.yaml` (e.g., `0.0.2`). If they don't match, the publish will fail. The `app-chart` version is automatically synchronized to match `lib-chart` during the release process.

## Using as a Dependency

### Option 1: Use `app-chart` as a Generic Service Chart (Recommended)

For most services, you can use `app-chart` directly without creating your own Helm chart. This is the fastest way to deploy standardized services.

#### With Helm CLI

```bash
helm install my-service oci://ghcr.io/orhayoun-eevee/app-chart \
  --version 0.0.2 \
  --set global.name=my-service \
  --set deployment.containers.app.image=my-service:latest \
  --set service.ports.http.port=8080
```

#### With ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-service
  namespace: argocd
spec:
  project: default
  source:
    chart: app-chart
    repoURL: oci://ghcr.io/orhayoun-eevee
    targetRevision: 0.0.2
    helm:
      values: |
        global:
          name: my-service
          namespace: production
        deployment:
          replicas: 3
          containers:
            app:
              image: my-service:latest
              imagePullPolicy: IfNotPresent
              ports:
                - name: http
                  containerPort: 8080
        service:
          ports:
            http:
              port: 80
              targetPort: http
        httpRoute:
          enabled: true
          host: my-service.example.com
          port: 80
```

#### Example Values File

Create a `values.yaml` for your service:

```yaml
global:
  name: my-service
  namespace: production

deployment:
  replicas: 2
  containers:
    app:
      image: my-service:v1.2.3
      imagePullPolicy: IfNotPresent
      ports:
        - name: http
          containerPort: 8080
      env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: my-service-secrets
              key: database-url

service:
  type: ClusterIP
  ports:
    http:
      port: 80
      targetPort: http

persistence:
  enabled: true
  claims:
    data:
      storage: 10Gi
      accessMode: ReadWriteOnce

httpRoute:
  enabled: true
  host: my-service.example.com
  port: 80
```

### Option 2: Use `lib-chart` to Build Custom Charts

If you need custom logic or additional resources beyond what `app-chart` provides, create your own chart that depends on `lib-chart`:

```yaml
apiVersion: v2
name: my-custom-app
version: 1.0.0
dependencies:
  - name: lib-chart
    version: 0.0.2
    repository: oci://ghcr.io/orhayoun-eevee/libchart
```

Then in your `templates/deployment.yaml`:

```yaml
{{- include "libchart.classes.deployment" . -}}
```

### In This Repository (Development)

The `appChart` in this repository uses a local file dependency to ensure it always tests the current source code:

```yaml
dependencies:
  - name: lib-chart
    version: 0.0.1
    repository: file://../libChart
```

During the release process, this dependency is automatically updated to use the OCI repository before publishing.

## Validation

The repository includes validation scripts to ensure chart quality:

```bash
./scripts/validate.sh
```

This script:
- Lints both charts
- Validates generated manifests with kubeconform
- Compares against golden snapshot to detect drift

To update the golden snapshot:
```bash
./scripts/validate.sh --update
```