# Application-v2 Chart Improvement Plan

This document tracks architectural improvements, bug fixes, and feature enhancements for the `application-v2` Helm chart.

## 🔴 Critical Fixes (High Priority)

- [ ] **Fix Variable Substitution in Security Policies**
    - The documentation claims `{service.name}` variables are substituted in AuthorizationPolicies and NetworkPolicies.
    - **Issue**: The templates currently use plain string printing (`{{ . }}`) or `toYaml` which does not execute templates.
    - **Task**: Update `authorizationpolicy.yaml` to use `{{ tpl . $ }}` for principals.
    - **Task**: Update `networkpolicy.yaml` to pass the ingress/egress spec through `tpl` before rendering.

- [ ] **Fix Service Name Fallback**
    - **Issue**: `service.name` is required in `values.yaml` and has no fallback. If omitted, templates break or generate empty names.
    - **Task**: Update `_helpers.tpl` (`application-v2.name`) to default to `.Chart.Name` if `.Values.service.name` is empty.

## 🟡 Developer Experience (Simplification)

- [ ] **Implement "Main Container" Shortcut**
    - **Issue**: Users must currently define the entire `containers` map, even for simple single-container apps.
    - **Task**: Add top-level `image`, `command`, and `args` to `values.yaml`.
    - **Task**: Update `deployment.yaml` to inject a default "app" container if these values are present, merging it with the `containers` map.

- [ ] **Refine Persistence Mounting Logic**
    - **Issue**: `mountPersistence: true` on a container currently mounts *all* defined `extraVolumes`. This is too coarse for multi-container pods.
    - **Task**: Allow containers to specify a list of volume names to mount (e.g., `mountVolumes: ["config", "media"]`).
    - **Task**: Deprecate or refine the global `mountPersistence` flag.

## 🛡️ Operational Readiness (Safety)

- [ ] **Add Default Probes**
    - **Issue**: If users forget to define probes, deployments are operationally blind and risk downtime during rollouts.
    - **Task**: In `deployment.yaml`, detect if `livenessProbe` / `readinessProbe` are missing.
    - **Task**: Inject a safe default (e.g., TCP socket on the service port) if explicitly enabled via a `probes.default: true` flag.

- [ ] **Create "Safe Default" NetworkPolicy**
    - **Issue**: Enabling NetworkPolicy requires defining *everything* manually.
    - **Task**: Create a `security.networkPolicy.defaults` boolean.
    - **Task**: If enabled, inject standard egress rules for:
        - DNS (UDP/TCP 53)
        - Kubernetes API
        - Istio Sidecar communication

## 🔵 Long-term Maintenance

- [ ] **Add JSON Schema Validation**
    - **Task**: Create `values.schema.json`.
    - **Details**: Enforce types (e.g., `replicas` must be integer) and required fields (e.g., `image.repository` if main container used).

- [ ] **Add HorizontalPodAutoscaler (HPA) Support**
    - **Task**: Create `templates/hpa.yaml`.
    - **Task**: Add `autoscaling` section to `values.yaml`.

- [ ] **Documentation Updates**
    - **Task**: Update `README.md` to reflect the "Main Container" shortcut and new Security features.
    - **Task**: Document the variable substitution syntax clearly.

