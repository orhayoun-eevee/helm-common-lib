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
make bump VERSION=0.0.7

# Commit and tag
git commit -am "chore: bump version to 0.0.7"
git push
git tag v0.0.7 && git push origin v0.0.7
```

The publish workflow automatically packages and pushes the chart to GHCR when you push a version tag.

**For the complete developer workflow, release process, troubleshooting, and Makefile reference, see [docs/WORKFLOW.md](docs/WORKFLOW.md).**

## CI Workflow Triggers

- `on-pr.yaml`:
  - automatic on PRs to `main`
  - runs `validate-lib` (library checks) then `validate-test` (full 5-layer pipeline on `test-chart`)
- `pr-required-checks.yaml`:
  - automatic on PRs to `main`
  - always-on required status that aggregates dependency review, validation, renovate-config, and scaffold drift checks
- `on-tag.yaml`:
  - automatic on `v*` tag push
  - publishes the chart via reusable `release-chart.yaml`
- `renovate-config.yaml`:
  - automatic when Renovate config files change
  - supports manual `workflow_dispatch`
- `dependency-review.yaml`:
  - automatic on PRs to `main`
  - calls centralized reusable dependency review workflow from `build-workflow`
- `codeql.yaml`:
  - automatic on CI automation/chart path changes and weekly schedule
  - calls centralized reusable CodeQL workflow from `build-workflow`

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
    version: "0.0.7"
    repository: "oci://ghcr.io/orhayoun-eevee"
```

Then in your chart's `templates/all.yaml`:

```yaml
{{ include "libChart.all" . }}
```

This renders all libChart resources based on your values.

### Configuration

Configure your chart via `values.yaml`. See [libChart/values.yaml](libChart/values.yaml) for the complete schema with inline documentation.

Minimal example:

```yaml
global:
  name: my-service
  namespace: production

deployment:
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

### Using Individual Templates

If you only need specific resources instead of `libChart.all`, you can include individual templates:

```yaml
{{- include "libChart.classes.deployment" . -}}
{{- include "libChart.classes.service" . -}}
```

See `libChart/templates/classes/` for all available resource templates.

### In This Repository (Development)

The `test-chart` in this repository uses a local file dependency to ensure it always tests the current source code:

```yaml
dependencies:
  - name: lib-chart
    version: 0.0.7
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

Branch protection on `main` is expected to require passing `required-checks` before merge.
This ensures Renovate automerge only merges changes that pass CI.
