# Validation System

The helm-common-lib includes a comprehensive validation system that checks configuration values at template rendering time.

## Current Status: WARNING-ONLY Mode ⚠️

**As of version 0.0.x, all validations are in WARNING-ONLY mode.**

This means:
- ✅ Validations run during `helm template`, `helm install`, and `helm upgrade`
- ✅ Warnings appear as YAML comments in the rendered output
- ⚠️ **Warnings do NOT prevent deployment** - templates render successfully even with validation issues
- 🔮 **Future versions will make these BLOCKING** - fix warnings now to avoid breaking changes later

### Why Warning-Only?

This phased approach allows us to:
1. **Introduce validations safely** without breaking existing deployments
2. **Give users time to fix issues** before they become blocking errors
3. **Gather feedback** on validation accuracy and usefulness
4. **Test thoroughly** across all application charts

### When Will This Change?

We plan to make validations blocking (fail-fast) in a future major version. You will see:
- Deprecation notices in release notes
- Clear migration guide
- At least one minor version of warning-only period before enforcement

## What Gets Validated?

### Global Configuration
- ✅ `global.name` is required and not empty
- ✅ `global.name` is valid DNS-1123 format (lowercase, alphanumeric, dashes)
- ✅ `global.name` is ≤ 63 characters
- ✅ `global.namespace` is required and not empty

### Deployment
- ✅ At least one container is defined
- ✅ Each enabled container has `image.repository` and `image.tag`
- ✅ Image repository is not empty
- ✅ Image tag is not empty
- ✅ Container ports are in valid range (1-65535)
- ✅ Container names are valid DNS-1123 subdomain

### Networking - HTTPRoute
- ✅ Gateway name and namespace are required when HTTPRoute is enabled
- ✅ Host is required when HTTPRoute is enabled
- ✅ Port is in valid range (1-65535)

### Networking - Service
- ✅ At least one service item exists when services are enabled
- ✅ Each service has at least one port defined
- ✅ Service ports are in valid range (1-65535)

### Networking - DestinationRule (Istio)
- ✅ Service name is required when DestinationRule is enabled
- ✅ TLS mode is valid (DISABLE, SIMPLE, MUTUAL, ISTIO_MUTUAL)

### Storage - PVC
- ✅ At least one claim exists when persistence is enabled
- ✅ Each claim has required fields (size, storageClass)
- ✅ Storage size matches Kubernetes format (e.g., "1Gi", "500Mi")
- ✅ Access mode is valid (ReadWriteOnce, ReadOnlyMany, ReadWriteMany)

### Observability - ServiceMonitor
- ✅ Port is required and in valid range
- ✅ Interval format is valid (e.g., "10s", "1m")

### Security - SealedSecret
- ✅ At least one secret item exists when SealedSecret is enabled
- ✅ Each secret has encrypted data

### Workload - PodDisruptionBudget
- ✅ Either minAvailable or maxUnavailable is set (not both)

## How to See Warnings

Run `helm template` to see validation warnings in the output:

```bash
helm template my-release ./my-chart -f values.yaml
```

Look for sections like this in the output:

```yaml
# ==========================================
# ⚠️  VALIDATION WARNINGS (Non-Breaking)
# ==========================================
# The following validation issues were detected.
# These are currently WARNINGS ONLY and will not prevent deployment.
# In a future version, these will become blocking errors.
# Please fix these issues to ensure compatibility with future releases.
#
# - global.name is required and cannot be empty. Please set 'global.name' to a valid DNS-1123 name (lowercase alphanumeric with dashes).
# - deployment.containers must have at least one enabled container defined
# ==========================================
```

## How to Fix Common Issues

### Empty or Missing global.name

**Error:**
```
global.name is required and cannot be empty
```

**Fix:**
```yaml
global:
  name: "my-app"  # DNS-1123 format: lowercase, alphanumeric, dashes
  namespace: "default"
```

### Invalid DNS-1123 Format

**Error:**
```
global.name 'MyApp' is invalid. Must be DNS-1123 compliant
```

**Fix:**
```yaml
global:
  name: "my-app"  # Use lowercase only
```

### Missing Container Image

**Error:**
```
deployment.containers.main.image.repository is required
```

**Fix:**
```yaml
deployment:
  containers:
    main:
      enabled: true
      image:
        repository: "nginx"  # Required
        tag: "1.25"          # Required
```

### Missing HTTPRoute Gateway

**Error:**
```
network.httpRoute.gateway.name is required when HTTPRoute is enabled
```

**Fix:**
```yaml
network:
  httpRoute:
    enabled: true
    gateway:
      name: "my-gateway"        # Required
      namespace: "istio-system" # Required
    host: "app.example.com"     # Required
```

## Disabling Validations (Not Recommended)

Currently, there is no way to disable validations because they are in warning-only mode and don't block deployments.

If you absolutely need to bypass warnings for testing:
1. Comment out the validation call in `libChart/templates/lib/_entrypoint.tpl`
2. Remove the line: `{{- include "libChart.validations.run" . -}}`

**Note:** This is strongly discouraged and will not be supported in future versions.

## Testing Validations

The validation system is tested in two ways:

1. **Unit tests** - `appChart/tests/validation_test.yaml` tests that warnings appear correctly
2. **Manual testing** - Example invalid values in `tests/values-validation-examples/`

To manually test a validation:

```bash
cd appChart
helm dependency update
helm template test . -f ../tests/values-validation-examples/empty-name.yaml
# Check output for validation warnings
```

## Implementation Details

### Architecture

Validations are organized in a modular structure:

```
libChart/templates/
├── helpers/validation/
│   ├── _main.tpl           # Orchestrator - runs all validations
│   ├── _global.tpl         # Global config validations
│   ├── _naming.tpl         # DNS-1123 validation helper
│   ├── _networking.tpl     # Port validation helper
│   ├── _storage.tpl        # Size format validation helper
│   └── _time.tpl           # Duration format validation helper
└── lib/
    ├── workload/
    │   ├── _deployment-validations.tpl
    │   └── _pdb-validations.tpl
    ├── networking/
    │   ├── _service-validations.tpl
    │   ├── _httproute-validations.tpl
    │   └── _destinationrule-validations.tpl
    ├── storage/
    │   └── _pvc-validations.tpl
    ├── observability/
    │   └── _servicemonitor-validations.tpl
    └── security/
        └── _sealedsecret-validations.tpl
```

### How It Works

1. **Entrypoint** (`_entrypoint.tpl`) calls `libChart.validations.run` before rendering resources
2. **Orchestrator** (`_main.tpl`) creates a shared context with an `errors` list
3. **Each validator** appends errors to the shared list
4. **Orchestrator** emits all errors as YAML comments (warning-only mode)
5. **Future:** Orchestrator will call `fail` to block rendering (enforcement mode)

### Adding New Validations

To add a new validation:

1. Create a validation template (e.g., `lib/myfeature/_myfeature-validations.tpl`)
2. Define your validation function:
   ```yaml
   {{- define "libChart.validations.myfeature" -}}
   {{- $root := .root -}}
   {{- $scratch := .scratch -}}
   
   {{- if $root.Values.myfeature.enabled -}}
     {{- if not $root.Values.myfeature.requiredField -}}
       {{- $_ := set $scratch "errors" (append $scratch.errors "myfeature.requiredField is required") -}}
     {{- end -}}
   {{- end -}}
   {{- end -}}
   ```
3. Call it from `_main.tpl`:
   ```yaml
   {{- include "libChart.validations.myfeature" $ctx -}}
   ```

## Feedback

If you encounter:
- ❌ False positives (warnings for valid configurations)
- ❌ Missing validations (issues that should be caught but aren't)
- 💡 Suggestions for better error messages

Please open an issue with:
- Your values.yaml (redacted if needed)
- The warning message
- What you expected vs what happened

## Future Plans

- [ ] Transition to fail-fast mode in v0.1.0 or v1.0.0
- [ ] Add optional strict mode via feature flag
- [ ] Add validation summary in `helm template` output
- [ ] Add validation severity levels (error, warning, info)
- [ ] Add validation skip annotations for special cases
