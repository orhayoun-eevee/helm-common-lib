# Deprecation Policy and Current Deprecations

This document describes how deprecations work in helm-common-lib and lists current deprecations.

---

## How Deprecations Work

- **Warnings only**: Deprecations are emitted as YAML comments at the top of the rendered manifest when you run `helm template` or `helm install --dry-run`. They do not cause the chart to fail.
- **Location**: Logic lives in `libChart/templates/lib/_deprecations.tpl` and is invoked at the start of `libChart.all` (before validations and resource generation).
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

**Status**: Deprecated in favor of per-claim configuration.

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

**If you still use the old key**: You will see a deprecation warning in the rendered output. Move to `persistence.claims.<name>.retain` when convenient.

---

## Policy

- Deprecations are announced in release notes and in this document.
- When possible, we use a deprecation window (warnings first, then breaking change in a later minor/major) rather than removing support immediately.
- For breaking changes (e.g. gateway defaults), validation ensures invalid configurations fail fast with clear messages.
