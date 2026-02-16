# Deprecation Policy and Current Deprecations

This document describes how deprecations work in helm-common-lib and lists current deprecations.

---

## How Deprecations Work

- **Warnings only**: Deprecations are emitted as YAML comments at the top of the rendered manifest when you run `helm template` or `helm install --dry-run`. They do not cause the chart to fail.
- **Location**: Logic lives in `libChart/templates/_deprecations.tpl` and is invoked at the start of `libChart.all` (before validations and resource generation).
- **Purpose**: To give advance notice of configuration changes so you can migrate before a future release that enforces or removes the deprecated behavior.

---

## Current Deprecations

### 1. Gateway defaults removed (v0.0.6+)

**What changed**: The library chart no longer sets default values for `network.httpRoute.gateway.name` and `network.httpRoute.gateway.namespace`. They are left empty in the library defaults.

**Why**: Defaults were environment-specific (`shared-platform-gateway`, `istio-system`) and reduced portability. Explicit configuration is required when HTTPRoute is enabled.

**What you need to do**: If you use `network.httpRoute.enabled: true`, set in your application chart:

```yaml
network:
  httpRoute:
    enabled: true
    host: myapp.example.com
    port: 80
    gateway:
      name: my-gateway      # Set to your Gateway name
      namespace: istio-system  # Set to your Gateway namespace
```

**Validation**: If HTTPRoute is enabled and `gateway.name` or `gateway.namespace` is missing or empty, template validation will fail with a clear error before any resources are rendered.

---

### 2. `persistence.retain` (legacy top-level)

**Status**: Removed. The JSON schema now rejects unknown properties under `persistence` via `additionalProperties: false`.

**What to use instead**: Set retention per PVC claim:

```yaml
persistence:
  enabled: true
  claims:
    config:
      size: 1Gi
      storageClass: longhorn
      retain: true   # Keep PVC on helm uninstall (default: true)
```

**If you still use the old key**: Schema validation will fail with `additional properties 'retain' not allowed`. Move to `persistence.claims.<name>.retain`.

---

### 3. `destinationrule` renamed to `destinationRule` (v0.0.7+)

**What changed**: The values key `network.istio.destinationrule` has been renamed to `network.istio.destinationRule` to follow Helm's camelCase naming convention.

**Why**: Per [Helm Values Best Practices](https://helm.sh/docs/chart_best_practices/values/#naming-conventions), "Variable names should begin with a lowercase letter, and words should be separated with camelcase." The old key violated this convention.

**What you need to do**: Update any references to the old key name in your values files:

```yaml
# OLD (no longer works):
network:
  istio:
    destinationrule:
      enabled: true
      host: my-service.namespace.svc.cluster.local

# NEW:
network:
  istio:
    destinationRule:
      enabled: true
      host: my-service.namespace.svc.cluster.local
```

**Breaking change**: This is an immediate breaking change with no deprecation warning period. If you were using `destinationrule`, you must update to `destinationRule` when upgrading to v0.0.7+.

---

### 4. Dead `networkpolicies` section removed from defaults (v0.0.7+)

**What changed**: The `network.networkpolicies` section was removed from `libChart/values.yaml` and other default values files.

**Why**: This section was dead code that contained:
- Infrastructure-specific values (specific IPs, namespace names) inappropriate for library chart defaults
- A typo (`enabled: tfrue`)
- A different key structure than the actual template implementation (which uses `network.networkPolicy.items`)

**What you need to do**: If you were using the `network.networkPolicy` feature (the correct key), no action needed. The removed section was unused dead code. If you somehow were referencing `networkpolicies` (with an 's'), update to `networkPolicy` (singular).

---

### 5. Schema strictness improvements (v0.0.7+)

**What changed**: The JSON Schema (`values.schema.json`) now enforces stricter validation:
- Added `additionalProperties: false` to all objects with known keys (deployment, network, metrics, etc.) to catch typos
- Added `minProperties: 1` to `deployment.containers` to enforce at least one container is defined
- Added `resources` sub-schema requiring `requests` and `limits` to be objects (type-only validation)

**Why**: Prevents silent typos like `destinationrule` vs `destinationRule` (correct camelCase). Catches structural errors earlier with clear messages.

**Breaking**: Values files with typos in property names will now fail schema validation. Common errors:
- `deploymentt` instead of `deployment` → `additional properties 'deploymentt' not allowed`
- `replicass` instead of `replicas` → `additional properties 'replicass' not allowed`
- `destinationrule` instead of `destinationRule` → `additional properties 'destinationrule' not allowed`
- Empty `containers: {}` → `minProperties: got 0, want 1`

**Fix**: Correct typos in your values files. Use your IDE's schema validation or run `helm lint` to catch errors early.

---

## Policy

- Deprecations are announced in release notes and in this document.
- When possible, we use a deprecation window (warnings first, then breaking change in a later minor/major) rather than removing support immediately.
- For breaking changes (e.g. gateway defaults), validation ensures invalid configurations fail fast with clear messages.
