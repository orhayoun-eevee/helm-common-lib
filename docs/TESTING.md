# Testing Guide

This document describes all tests used in this repository, how to run them locally, and how to extend them. The same steps run in CI (see [.github/workflows/pr-required-checks.yaml](../.github/workflows/pr-required-checks.yaml)).

## Overview

| Test type | What it does | Runs in CI | Script / command |
|-----------|--------------|------------|-------------------|
| **Unit tests** | Assert on rendered templates (Deployment, Services, etc.) | ✅ `unit-test` job | `helm unittest test-chart` |
| **Aggregation test** | Verifies multi-domain template validation errors are aggregated | ✅ (inside `make ci`) | `make test-aggregation` |
| **Helm lint** | Schema + chart structure validation | ✅ (inside validate pipeline) | `helm lint libChart` / `helm lint test-chart` |
| **Chart-testing (ct) lint** | Lint all charts per ct config | ✅ `validate` pipeline | `ct lint --config ct.yaml --all` |
| **Snapshot testing** | Compare rendered manifests to saved baselines (drift detection) | ✅ (inside validate pipeline) | `make snapshot-update` |
| **Kubeconform** | Validate generated YAML against Kubernetes APIs | ✅ (inside validate pipeline) | Part of `build-workflow` validation |

## Prerequisites

- **Docker** -- All validation tools run inside the `helm-validate` Docker image ([install](https://docs.docker.com/get-docker/))
- **make** -- For running tasks

One-time setup:

```bash
make docker-build
```

This builds a Docker image containing all required tools (helm, helm-unittest, kubeconform, yamllint, chart-testing, checkov, kube-linter, yq). No local tool installation is needed beyond Docker and make.

## Run all tests locally (CI parity)

From the repository root:

```bash
# 1. Dependencies
make deps

# 2. Unit tests
make test

# 3. Validation aggregation check
make test-aggregation

# 4. Full validation (lint + kubeconform + snapshot check)
make validate
```

Or run the complete CI suite:

```bash
make ci
```

This mirrors exactly what GitHub CI runs.

---

## 1. Unit tests (helm-unittest)

- **Purpose**: Test that templates render expected structure and values (e.g. Deployment name, replicas, image).
- **Location**: Tests live in **test-chart**, not libChart, because library charts are not directly templateable. test-chart includes libChart and renders `templates/all.yaml`, so unit tests assert on that output.
- **Files**: `test-chart/tests/*_test.yaml` (e.g. `deployment_test.yaml`).

### Run

```bash
helm dependency update test-chart
helm unittest test-chart
```

Run a single test file:

```bash
helm unittest test-chart test-chart/tests/deployment_test.yaml
```

Update snapshot assertions (if you use snapshot tests):

```bash
helm unittest test-chart --update-snapshot
```

### How to extend

1. **Add a new test case** in an existing file (e.g. `test-chart/tests/deployment_test.yaml`):
   - Add a new `- it: <description>` under `tests:`.
   - Use `set:` to override values (e.g. `global.name`, `deployment.containers`).
   - Use `asserts:` with `documentIndex` (0 = first rendered doc, 1 = Deployment, etc.) and `equal`, `matchSnapshot`, or other [helm-unittest assertions](https://github.com/helm-unittest/helm-unittest/blob/master/docs/assertions.md).

2. **Add a new test file** for another resource (e.g. Service, HTTPRoute):
   - Create `test-chart/tests/service_test.yaml` (or similar).
   - Set `suite:`, `templates: [templates/all.yaml]`, and a list of `tests:`.
   - Run `helm unittest test-chart` to include it.

3. **Test validation (failures)**:
   - Use `failedTemplate` assert to check that invalid values cause template/validation to fail with a specific error message. Example:

   ```yaml
   - it: should fail when global.name is empty
     set:
       global:
         name: ""
         namespace: default
       deployment:
         containers:
           app:
             enabled: true
             image:
               repository: nginx
               tag: "1.0"
     asserts:
       - failedTemplate:
           errorMessage: "global.name"
   ```

See [libChart/tests/README.md](../libChart/tests/README.md) for why tests run via test-chart.

---

## 2. Helm lint

- **Purpose**: Validates chart structure and, for libChart, runs **values.schema.json** (types, required fields, patterns). Catches many config errors before template render.
- **Location**: `libChart/values.schema.json`, `libChart/Chart.yaml`, `test-chart/Chart.yaml`.

### Run

```bash
helm lint libChart
helm lint libChart --strict   # stricter (e.g. icon recommended)
helm dependency update test-chart && helm lint test-chart
```

### How to extend

- **Schema**: Edit `libChart/values.schema.json` to add or tighten validation (new properties, patterns, `if`/`then` for conditionals). Run `helm lint libChart --strict` and optional `ajv validate -s libChart/values.schema.json -d <values-file>` to verify.
- **Charts**: Lint runs on any chart with a `Chart.yaml`; adding a new chart under `chart-dirs` in `ct.yaml` will include it in ct lint as well.

---

## 3. Chart-testing (ct) lint

- **Purpose**: Lint all charts listed in `ct.yaml` (libChart, test-chart) with a single command; can also enforce version bumps and maintainers (disabled in this repo).
- **Config**: `ct.yaml` at repo root.

### Run

```bash
helm dependency update test-chart
ct lint --config ct.yaml --all
```

### How to extend

- Add another chart directory under `chart-dirs` in `ct.yaml` so it is included in `ct lint --all`.
- Adjust `check-version-increment`, `validate-maintainers`, or `helm-extra-args` in `ct.yaml` as needed.

---

## 4. Snapshot Testing

- **Purpose**: Render manifests with fixed scenario files and compare to committed baselines (`tests/snapshots/*.yaml`) to detect unintended changes (drift).
- **Locations**:
  - **Input scenarios**: `tests/scenarios/*.yaml` (e.g., `full.yaml`, `minimal.yaml`)
  - **Baseline snapshots**: `tests/snapshots/*.yaml`
  - **Validation framework**: `build-workflow` (Docker-based validation)

Rendering uses **test-chart** with each scenario in `tests/scenarios/`; output is validated with kubeconform, Checkov, and kube-linter, then compared against `tests/snapshots/`.

### Run

```bash
make validate
```

If you intentionally changed templates or scenarios and want to accept the new output as the baseline:

```bash
make snapshot-update
# Then commit tests/snapshots/
```

### How to extend

1. **Add a new scenario**: Create a new file in `tests/scenarios/` (e.g., `tests/scenarios/monitoring.yaml`) with specific configuration. Run `make snapshot-update` to generate the corresponding snapshot file.

2. **Update existing scenarios**: Edit files in `tests/scenarios/` to add features or change configuration. Run `make snapshot-update`, review the diff in `tests/snapshots/`, and commit.

3. **Kubeconform validation**: The validation framework handles CRD schemas automatically using external schema catalogs. Configuration is in `build-workflow/configs/`.

---

## 5. Policy and Security Validation

The validation framework includes automated security and policy checks:

- **Checkov**: Scans for security misconfigurations (image pull policies, resource limits, etc.)
- **kube-linter**: Enforces Kubernetes best practices (anti-affinity, liveness probes, etc.)
- **Configuration**: `.checkov.yaml` in the repository root (kube-linter uses the framework default from `build-workflow`)

### Testing policy compliance

The full validation pipeline automatically runs these checks:

```bash
make validate
```

To skip Checkov checks, configure them in `.checkov.yaml` at the repository root. Kube-linter uses the framework default configuration from `build-workflow/configs/kube-linter-default.yaml`. Always document why a check is skipped.

---

## CI workflow summary

- **unit-test**: `helm dependency update test-chart` → `helm unittest test-chart`
- **validate**: Uses `build-workflow` Docker image to run 5-layer validation:
  1. Syntax validation (helm lint, yamllint)
  2. Schema validation (kubeconform)
  3. Metadata validation (chart-testing)
  4. Test execution (helm-unittest)
  5. Policy validation (Checkov, kube-linter)

---

## Quick reference

| Goal | Command |
|------|--------|
| Run everything (CI parity) | `make ci` |
| Unit tests only | `make test` |
| Full validation (snapshot + lint + kubeconform + policy) | `make validate` |
| Update snapshots | `make snapshot-update` |
| Lint one chart | `helm lint libChart --strict` or `helm lint test-chart` |
