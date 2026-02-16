# Testing Improvement Plan

> **Note:** This document tracks FUTURE improvements beyond current baseline.
> For current testing documentation, see [TESTING.md](TESTING.md).
> This is a planning document for tracking test coverage gaps and enhancement roadmap.

Based on the current test suite, this document tracks remaining gaps and next improvements for reliability and coverage.

## Executive Summary

The current testing infrastructure provides regression detection via snapshot testing (`tests/scenarios/`, `tests/snapshots/`), schema compliance (helm lint + JSON schema), and policy enforcement (Checkov + kube-linter). Unit test coverage now includes dedicated tests for all resource templates with 12 suites.

## Current Test Coverage

| Template | Unit Tests | Snapshot Coverage |
|----------|-----------|-------------------|
| Deployment | `deployment_test.yaml` | full, minimal |
| Service | `service_test.yaml` | full |
| HTTPRoute | `httproute_test.yaml` | - |
| PVC | `pvc_test.yaml` | full |
| ServiceAccount | `security_test.yaml` | full, minimal |
| ServiceMonitor | `observability_test.yaml` | full |
| PrometheusRule | `observability_test.yaml` | full |
| NetworkPolicy | `security_test.yaml` | full |
| SealedSecret | `security_test.yaml` | - |
| PodDisruptionBudget | `validation_test.yaml`, `pdb_test.yaml` | full |
| Validation logic | `validation_test.yaml` | - |
| AuthorizationPolicy | `istio_test.yaml` | - |
| DestinationRule | `istio_test.yaml` | - |
| ConfigMap | `configmap_test.yaml` | full |
| GrafanaDashboard | `grafana_test.yaml` | - |

## Identified Gaps

### Snapshot Scenario Gaps
- **Current State:** Two scenarios -- `full.yaml` (9 resources) and `minimal.yaml` (2 resources).
- **Missing:**
  - A scenario with Istio features (DestinationRule, AuthorizationPolicy)
  - A scenario with HTTPRoute enabled
  - A scenario with multiple services
- **Risk:** CRD resources and edge cases in conditional logic are not verified by snapshots.

---

## Recommendations

### Priority 1: Add Missing Snapshot Scenarios (High Impact)

**Action Items:**
1. Create `tests/scenarios/istio.yaml` -- enables DestinationRule and AuthorizationPolicy
2. Create `tests/scenarios/httproute.yaml` -- enables HTTPRoute with routes
3. Create `tests/scenarios/multi-service.yaml` -- verifies multiple service definitions

### Priority 2: Expand Multi-Item Cases (Medium Impact)

**Action Items:**
1. Add multi-item ConfigMap rendering assertions
2. Add multi-policy AuthorizationPolicy assertions
3. Add dashboard plugin and inline JSON Grafana assertions

---

## Proposed Roadmap

| Phase | Goal | Tasks |
|-------|------|-------|
| **Phase 1** | Scenario Coverage | Add `istio.yaml`, `httproute.yaml`, and `multi-service.yaml` scenarios |
| **Phase 2** | Edge Cases | Expand multi-item and alternate-path assertions in existing unit suites |

## How to Contribute Tests

See [docs/TESTING.md](./TESTING.md#how-to-extend) for detailed instructions on adding new unit tests and scenarios.
