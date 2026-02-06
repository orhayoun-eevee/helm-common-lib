# Testing Improvement Plan

> **Note:** This document outlines FUTURE improvements to the testing infrastructure. 
> For current testing documentation, see [TESTING.md](TESTING.md).
> This is a planning document for tracking test coverage gaps and enhancement roadmap.

Based on the analysis of the current test suite, this document outlines identified gaps and actionable recommendations to improve test coverage, reliability, and developer experience.

## Executive Summary

The current testing infrastructure provides a good baseline for regression detection (Golden Snapshot) and schema compliance (Helm Lint). However, **unit test coverage is very low (~7%)**, covering only the Deployment resource. Validation logic is largely untested by automated negative tests, relying mostly on schema definitions.

## Identified Gaps

### 1. Low Unit Test Coverage
- **Current State:** Only `Deployment` (1 of 14 templates) has explicit unit tests (`deployment_test.yaml`).
- **Missing:** No dedicated unit tests for:
  - `Service` (ClusterIP, NodePort, LoadBalancer)
  - `Ingress` / `HTTPRoute` (Gateway API logic)
  - `PersistentVolumeClaim` (Retention policies, storage classes)
  - `ServiceAccount` (Annotation logic, automount)
  - `NetworkPolicy`, `PodDisruptionBudget`, `ServiceMonitor`, `PrometheusRule`, `SealedSecret`, etc.
- **Risk:** Logic errors in these templates (e.g., incorrect label merging, conditional properties) may pass silent regression checks if they don't break the golden file structure but produce incorrect values.

### 2. Lack of Validation Tests
- **Current State:** Only `global.name` (empty and invalid format) has manual validation example files.
- **Missing:** Automated negative tests for:
  - Missing required fields (e.g., `deployment.containers`, `image.repository`).
  - Invalid formats (e.g., PVC size, duration strings).
  - Conditional requirements (e.g., `httpRoute` enabled without `gateway`).
  - Mutual exclusivity (e.g., PDB `minAvailable` vs `maxUnavailable`).
- **Risk:** Users may encounter cryptic template errors at install time instead of clear validation messages.

### 3. Golden File Limitations
- **Current State:** A single huge `golden.yaml` covers "everything enabled."
- **Missing:**
  - Scenarios for "minimal configuration" (defaults).
  - Scenarios for specific features disabled (e.g., no persistence, no metrics).
  - ConfigMap rendering (currently missing from golden output).
- **Risk:** Defaults and edge cases in conditional logic are not verified.

### 4. CI/CD Efficiency
- **Current State:** Sequential steps; local `validate.sh` runs redundant linting.
- **Improvement:** Could parallelize unit tests and linting.

---

## Recommendations

### Priority 1: Expand Unit Test Coverage (High Impact)

Create dedicated test files for core networking and storage resources.

**Action Items:**
1. Create `appChart/tests/service_test.yaml`:
   - Assert `spec.type` changes correctly.
   - Assert ports are rendered correctly.
   - Assert annotations are applied.
2. Create `appChart/tests/pvc_test.yaml`:
   - Assert `accessModes` and `storageClassName`.
   - Assert retention annotations (`helm.sh/resource-policy`).
3. Create `appChart/tests/httproute_test.yaml`:
   - Assert hostnames and gateway references.

### Priority 2: Automate Validation Testing (Medium Impact)

Convert manual validation examples into automated `failedTemplate` tests.

**Action Items:**
1. Create `appChart/tests/validation_test.yaml`.
2. Add test cases using `failedTemplate` assertion for:
   - Empty image repository.
   - Invalid PVC size.
   - Missing gateway configuration.
   - Invalid port ranges.

**Example:**
```yaml
- it: should fail when image repository is empty
  set:
    deployment.containers.app.image.repository: ""
  asserts:
    - failedTemplate:
        errorMessage: "image.repository is required"
```

### Priority 3: Refine Golden Snapshots (Low Impact)

Ensure all resources are covered and edge cases are visible.

**Action Items:**
1. Enable `ConfigMap` in `tests/values.test.yaml` (if applicable) to ensure it appears in `golden.yaml`.
2. Consider adding a `golden-minimal.yaml` generated from default values to ensure the chart works with zero configuration (beyond required fields).

---

## Proposed Roadmap

| Phase | Goal | Tasks |
|-------|------|-------|
| **Phase 1** | Networking Coverage | Add `service_test.yaml` and `httproute_test.yaml` |
| **Phase 2** | Validation Safety | Add `validation_test.yaml` covering top 5 common errors |
| **Phase 3** | Storage & Security | Add `pvc_test.yaml` and `serviceaccount_test.yaml` |
| **Phase 4** | Full Coverage | Reach 100% template coverage (at least one test per file) |

## How to Contribute Tests

See [docs/TESTING.md](./TESTING.md#how-to-extend) for detailed instructions on adding new unit tests.
