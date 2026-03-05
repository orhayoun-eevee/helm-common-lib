# helm-common-lib

Unified Helm library chart for application deployment. Provides reusable templates for Deployment, Services, Ingress, Monitoring, Persistence, and more.

## Overview

This repository contains:
- **`libChart/`**: The library chart (published to OCI) - reusable templates for building custom charts
- **`test-chart/`**: Test harness chart used for rendering and validating libChart templates

The library chart is published to GitHub Container Registry (GHCR) and can be used as a dependency in other Helm charts.

## Development and Release

### Quick Start

For contributors working on helm-common-lib:

```bash
# Install dependencies
make deps

# Make template changes, then update snapshot files
make snapshot-update

# Run full local CI (same as GitHub CI)
make ci

# Commit and push
git commit -am "feat: your changes"
git push
```

### Creating a Release

```bash
# Bump version in all Chart.yaml files
make bump VERSION=0.0.8

# Commit and tag
git commit -am "chore: bump version to 0.0.8"
git push
git tag v0.0.8 && git push origin v0.0.8
```

The publish workflow automatically packages and pushes the chart to GHCR when you push a version tag.

**For the complete developer workflow, release process, troubleshooting, and Makefile reference, see [docs/WORKFLOW.md](docs/WORKFLOW.md).**

## CI Workflow Triggers

- `pr-required-checks.yaml`:
  - automatic on PRs to `main` and `merge_group` (`checks_requested`)
  - always-on required status via centralized `pr-required-checks-chart.yaml` that aggregates dependency review, validation, renovate-config, and CodeQL checks
- `on-tag.yaml`:
  - automatic on `v*` tag push
  - publishes the chart via reusable `release-chart.yaml` with keyless signing/attestation
- `renovate-config.yaml`:
  - automatic on push to `main` when Renovate config files change
  - supports manual `workflow_dispatch`

For full cross-repo trigger ownership and lifecycle details, see `https://github.com/orhayoun-eevee/build-workflow/blob/main/docs/workflow-trigger-matrix.md`.

## Testing and Validation

### Quick Reference

```bash
make help           # Show all available commands
make test           # Run unit tests
make validate       # Run full 5-layer validation pipeline
make ci             # Run full CI suite locally
```

### Test Types

| Test | What it does | Command |
|------|----------------|---------|
| **Unit tests** | Assert on rendered templates | `make test` |
| **Schema tests** | Verify invalid values fail schema validation | `make test-schema` |
| **Validation** | Full 5-layer pipeline (syntax, schema, metadata, tests, policy) | `make validate` |
| **Full CI** | Everything (mirrors GitHub CI) | `make ci` |

**For detailed testing documentation, see [docs/TESTING.md](docs/TESTING.md).**

**For the complete workflow guide, see [docs/WORKFLOW.md](docs/WORKFLOW.md).**

**For validation architecture and rules, see [docs/VALIDATIONS.md](docs/VALIDATIONS.md).**

**For deprecation policy and current breaking changes, see [docs/DEPRECATIONS.md](docs/DEPRECATIONS.md).**

## Using as a Dependency

### Add libChart as a Dependency

In your chart's `Chart.yaml`:

```yaml
dependencies:
  - name: lib-chart
    version: "0.0.8"
    repository: "oci://ghcr.io/orhayoun-eevee"
```

Then in your chart's `templates/all.yaml`:

```yaml
{{ include "libChart.all" . }}
```

This renders all libChart resources based on your values.

### Configuration

Configure your chart via `values.yaml`. See [libChart/values.yaml](libChart/values.yaml) for the complete schema with inline documentation.

Workload selection:
- `workload.type` is required.
- Supported values are `deployment` and `cronJob`.
- Kubernetes compatibility target is `>=1.30`.

Notable deployment networking option:
- `workload.spec.hostNetwork` is supported.
- If `workload.spec.hostNetwork: true` and `workload.spec.dnsPolicy` is not set, the chart renders `dnsPolicy: ClusterFirstWithHostNet`.
- `network.services.items.<name>.ports.<port>.targetPort` is optional; if omitted, Kubernetes defaults it to `port`.

Notable CronJob options:
- `workload.spec.schedule` is required when `workload.type=cronJob`.
- `workload.spec.timeZone` is supported on Kubernetes 1.27+.
- `workload.spec.nameOverride` must be DNS-1123 compliant and <= 52 characters (Kubernetes CronJob/Job naming rule).
- Do not use `TZ=`/`CRON_TZ=` inside `workload.spec.schedule`; use `workload.spec.timeZone`.
- In `workload.type=cronJob` mode, deployment-oriented features fail validation (`podDisruptionBudget`, service/httpRoute routing, ServiceMonitor, Istio routing resources).

Service account behavior:
- If `serviceAccount.name` is set, workloads bind to that name even when `serviceAccount.create=false` (use existing ServiceAccount).
- If `serviceAccount.name` is empty and `serviceAccount.create=true`, chart name is used.

Notable ServiceMonitor endpoint auth options:
- `metrics.serviceMonitor.bearerTokenSecret` is supported for Secret-based bearer token auth.
- `metrics.serviceMonitor.authorization` is supported for Prometheus Operator authorization configuration.

Notable HTTPRoute hostname options:
- Legacy `network.httpRoute.host` is supported.
- `network.httpRoute.hosts` is supported for shared multi-host routing.
- `network.httpRoute.routes[].hostnames` is supported for route-specific host overrides.
- `network.httpRoute.routes[].rules` supports Helm templating via `tpl` for dynamic values.

Strict schema behavior:
- Container and initContainer objects reject unknown keys (fail-fast typo detection).

Minimal example:

```yaml
global:
  name: my-service
  namespace: production

workload:
  type: deployment
  spec:
    replicas: 2
    containers:
      app:
        enabled: true
        image:
          repository: my-service
          tag: "v1.2.3"
        ports:
          - name: http
            containerPort: 8080

network:
  services:
    items:
      main:
        enabled: true
        type: ClusterIP
        ports:
          http:
            port: 80
            targetPort: http
```

CronJob example:

```yaml
global:
  name: my-batch
  namespace: production

workload:
  type: cronJob
  spec:
    schedule: "0 * * * *"
    timeZone: "Etc/UTC"
    concurrencyPolicy: Forbid
    restartPolicy: OnFailure
    containers:
      app:
        enabled: true
        image:
          repository: busybox
          tag: "1.36"
        command: ["/bin/sh", "-c"]
        args: ["date; echo run"]
```

### Using Individual Templates

If you only need specific resources instead of `libChart.all`, you can include individual templates:

```yaml
{{- include "libChart.classes.deployment" . -}}
{{- include "libChart.classes.cronjob" . -}}
{{- include "libChart.classes.service" . -}}
```

See `libChart/templates/classes/` for all available resource templates.

### In This Repository (Development)

The `test-chart` in this repository uses a local file dependency to ensure it always tests the current source code:

```yaml
dependencies:
  - name: lib-chart
    version: 0.0.8
    repository: file://../libChart
```

## Documentation

- **[docs/WORKFLOW.md](docs/WORKFLOW.md)** -- Complete development workflow, release process, and troubleshooting
- **[docs/TESTING.md](docs/TESTING.md)** -- Comprehensive testing documentation
- **[docs/VALIDATIONS.md](docs/VALIDATIONS.md)** -- Validation rules and requirements
- **[docs/DEPRECATIONS.md](docs/DEPRECATIONS.md)** -- Deprecation warnings and migration guides

## Dependency Automation Policy

`helm-common-lib` uses Renovate with scoped automerge for low-risk dependency updates:

- `github-actions`: `digest`, `pin`, `pinDigest`, `patch`, `minor`
- `helmv3` dependencies: `digest`, `pin`, `pinDigest`, `patch`, `minor`
- `major` updates are not automerged

Branch protection on `main` is expected to require only the aggregate `ci-required` status before merge.
Recommended contexts:
- `PR Required Checks / ci-required / ci-required (pull_request)`
- `PR Required Checks / ci-required / ci-required (merge_group)`
This ensures Renovate automerge only merges changes that pass CI.
