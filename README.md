# helm-common-lib

Unified Helm library chart for application deployment. Provides reusable templates for Deployment, Services, Ingress, Monitoring, Persistence, and more.

## Overview

This repository contains:
- **`libChart/`**: The library chart (published to OCI)
- **`appChart/`**: Example application chart that consumes the library

## Publishing a Release

The library chart is automatically published to GitHub Container Registry (GHCR) when you push a git tag.

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
   - Lint the chart
   - Validate manifests with kubeconform
   - Package and publish to `oci://ghcr.io/orhayoun-eevee/helm-charts`

### Version Verification

The workflow enforces that the git tag version (e.g., `v0.0.2`) must exactly match the `version` field in `libChart/Chart.yaml` (e.g., `0.0.2`). If they don't match, the publish will fail.

## Using as a Dependency

### In Your Helm Chart (Consumers)

Add `libChart` as a dependency in your chart's `Chart.yaml`:

```yaml
apiVersion: v2
name: my-app
version: 1.0.0
dependencies:
  - name: libChart
    version: 0.0.2  # Use the published version
    repository: oci://ghcr.io/orhayoun-eevee/helm-charts
```

### In This Repository (Development)

The `appChart` in this repository uses a local file dependency to ensure it always tests the current source code:

```yaml
dependencies:
  - name: libChart
    version: 0.0.1
    repository: file://../libChart
```

Remember to update to the OCI repository before committing if you want to use the published version.

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