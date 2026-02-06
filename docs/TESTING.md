# Testing Guide

This document describes all tests used in this repository, how to run them locally, and how to extend them. The same steps run in CI (see [.github/workflows/ci.yaml](../.github/workflows/ci.yaml)).

## Overview

| Test type | What it does | Runs in CI | Script / command |
|-----------|--------------|------------|-------------------|
| **Unit tests** | Assert on rendered templates (Deployment, Services, etc.) | ✅ `unit-test` job | `helm unittest appChart` |
| **Helm lint** | Schema + chart structure validation | ✅ (inside validate.sh) | `helm lint libChart` / `helm lint appChart` |
| **Chart-testing (ct) lint** | Lint all charts per ct config | ✅ `lint-and-validate` job | `ct lint --config ct.yaml --all` |
| **Golden snapshot** | Compare rendered manifests to saved baseline (drift detection) | ✅ (inside validate.sh) | `./scripts/validate.sh` |
| **Kubeconform** | Validate generated YAML against Kubernetes APIs | ✅ (inside validate.sh) | Used inside `validate.sh` |
| **Optional: lint.sh** | Single entry: strict lint + template + validate.sh + ajv | No (local only) | `./scripts/lint.sh` |

## Prerequisites

- **helm** (3.x)
- **helm-unittest** plugin: `helm plugin install https://github.com/helm-unittest/helm-unittest`
- **kubeconform**: required by `validate.sh` ([install](https://github.com/yannh/kubeconform#installation))
- **diff**: standard on Unix/macOS
- **chart-testing (ct)** (optional for full CI parity): [install](https://github.com/helm/chart-testing#installation), e.g. `brew install chart-testing`
- **ajv** (optional, for standalone schema check in `lint.sh`): `npm install -g ajv-cli`

## Run all tests locally (CI parity)

From the repository root:

```bash
# 1. Dependencies
helm dependency update appChart

# 2. Unit tests
helm unittest appChart

# 3. Chart-testing lint (if ct is installed)
ct lint --config ct.yaml --all

# 4. Lint + golden + kubeconform
./scripts/validate.sh
```

Or use the single-entry script (does not run ct or unittest):

```bash
./scripts/lint.sh
```

`lint.sh` runs: strict helm lint, template generation, full `validate.sh` (lint both charts, template, kubeconform, golden diff), and optional ajv schema check.

---

## 1. Unit tests (helm-unittest)

- **Purpose**: Test that templates render expected structure and values (e.g. Deployment name, replicas, image).
- **Location**: Tests live in **appChart**, not libChart, because library charts are not directly templateable. appChart includes libChart and renders `templates/all.yaml`, so unit tests assert on that output.
- **Files**: `appChart/tests/*_test.yaml` (e.g. `deployment_test.yaml`).

### Run

```bash
helm dependency update appChart
helm unittest appChart
```

Run a single test file:

```bash
helm unittest appChart appChart/tests/deployment_test.yaml
```

Update snapshot assertions (if you use snapshot tests):

```bash
helm unittest appChart --update-snapshot
```

### How to extend

1. **Add a new test case** in an existing file (e.g. `appChart/tests/deployment_test.yaml`):
   - Add a new `- it: <description>` under `tests:`.
   - Use `set:` to override values (e.g. `global.name`, `deployment.containers`).
   - Use `asserts:` with `documentIndex` (0 = first rendered doc, 1 = Deployment, etc.) and `equal`, `matchSnapshot`, or other [helm-unittest assertions](https://github.com/helm-unittest/helm-unittest/blob/master/docs/assertions.md).

2. **Add a new test file** for another resource (e.g. Service, HTTPRoute):
   - Create `appChart/tests/service_test.yaml` (or similar).
   - Set `suite:`, `templates: [templates/all.yaml]`, and a list of `tests:`.
   - Run `helm unittest appChart` to include it.

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

See [libChart/tests/README.md](../libChart/tests/README.md) for why tests run via appChart.

---

## 2. Helm lint

- **Purpose**: Validates chart structure and, for libChart, runs **values.schema.json** (types, required fields, patterns). Catches many config errors before template render.
- **Location**: `libChart/values.schema.json`, `libChart/Chart.yaml`, `appChart/Chart.yaml`.

### Run

```bash
helm lint libChart
helm lint libChart --strict   # stricter (e.g. icon recommended)
helm dependency update appChart && helm lint appChart
```

### How to extend

- **Schema**: Edit `libChart/values.schema.json` to add or tighten validation (new properties, patterns, `if`/`then` for conditionals). Run `helm lint libChart --strict` and optional `ajv validate -s libChart/values.schema.json -d <values-file>` to verify.
- **Charts**: Lint runs on any chart with a `Chart.yaml`; adding a new chart under `chart-dirs` in `ct.yaml` will include it in ct lint as well.

---

## 3. Chart-testing (ct) lint

- **Purpose**: Lint all charts listed in `ct.yaml` (libChart, appChart) with a single command; can also enforce version bumps and maintainers (disabled in this repo).
- **Config**: `ct.yaml` at repo root.

### Run

```bash
helm dependency update appChart
ct lint --config ct.yaml --all
```

### How to extend

- Add another chart directory under `chart-dirs` in `ct.yaml` so it is included in `ct lint --all`.
- Adjust `check-version-increment`, `validate-maintainers`, or `helm-extra-args` in `ct.yaml` as needed.

---

## 4. Golden snapshot (validate.sh)

- **Purpose**: Render manifests with a fixed values file and compare to a committed baseline (`tests/golden.yaml`) to detect unintended changes (drift).
- **Locations**:
  - **Input values**: `tests/values.test.yaml`
  - **Baseline**: `tests/golden.yaml`
  - **Script**: `scripts/validate.sh`

Rendering uses **appChart** with `tests/values.test.yaml`; output is validated with kubeconform and then diffed against `tests/golden.yaml`.

### Run

```bash
./scripts/validate.sh
```

If you intentionally changed templates or test values and want to accept the new output as the baseline:

```bash
./scripts/validate.sh --update
# Then commit tests/golden.yaml
```

### How to extend

1. **Change the baseline**: Edit `tests/values.test.yaml` (add features, new resources, etc.), run `./scripts/validate.sh --update`, review the diff in `tests/golden.yaml`, and commit.
2. **Add another golden set** (optional): Duplicate the pattern: e.g. `tests/values.test-minimal.yaml` and a script or Make target that renders to `tests/golden-minimal.yaml` and diffs. Not required for current CI.
3. **Kubeconform**: validate.sh skips some CRDs (ServiceMonitor, PrometheusRule, HTTPRoute, etc.) if they lack schemas. To change that, edit the `kubeconform` invocation in `scripts/validate.sh`.

---

## 5. Validation error testing (optional)

To manually test that **template validation** fails with clear errors (e.g. empty `global.name`, invalid DNS name), you can use small values files and expect a non-zero exit.

Example values that should **fail** template validation:

- **Empty name**: `tests/values-validation-examples/empty-name.yaml`
- **Invalid name format**: `tests/values-validation-examples/invalid-name-format.yaml`

Run (expect failure):

```bash
cd appChart
helm dependency update
helm template test . -f ../tests/values-validation-examples/empty-name.yaml
# Expect: Error: ... global.name ...
```

These are **not** run in CI; they are for local and doc reference. See `tests/values-validation-examples/README.md` for details.

---

## CI workflow summary

- **unit-test**: `helm dependency update appChart` → `helm unittest appChart`
- **lint-and-validate**: `helm dependency update appChart` → `ct lint --config ct.yaml --all` → install kubeconform → `./scripts/validate.sh`

No separate job runs `scripts/lint.sh`; that script is for local use (strict lint + validate.sh + optional ajv).

---

## Quick reference

| Goal | Command |
|------|--------|
| Run everything (CI parity) | `helm dependency update appChart && helm unittest appChart && ct lint --config ct.yaml --all && ./scripts/validate.sh` |
| Unit tests only | `helm unittest appChart` |
| Golden + lint + kubeconform | `./scripts/validate.sh` |
| Update golden | `./scripts/validate.sh --update` |
| Single-entry local check | `./scripts/lint.sh` |
| Lint one chart | `helm lint libChart --strict` or `helm lint appChart` |
