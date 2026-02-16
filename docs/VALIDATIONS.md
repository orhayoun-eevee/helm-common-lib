# Validation System

The helm-common-lib validates configuration values using a two-layer approach: **JSON Schema** (structural validation) and **Go templates** (business logic). Invalid values cause rendering to fail with clear error messages.

## Validation Architecture

```
User values  →  Layer 1: JSON Schema  →  Layer 2: Go Templates  →  Render Manifests
                (types, patterns,        (iteration logic,
                 conditional-required)    zero-value awareness)
```

**Schema Scope**: The libChart `values.schema.json` validates **all values passed to charts that depend on libChart**, not just the library's own defaults. When you use libChart as a dependency in application charts (e.g., sonarr-helm), Helm applies the library's schema to your entire values structure. This means typos, invalid patterns, and missing required fields are caught at schema validation time regardless of where the values are defined.

**Layer 1 (JSON Schema)** runs on `helm lint`, `helm install`, `helm upgrade`, and `helm template`. It enforces:
- Types (string, integer, boolean, object, array)
- Patterns (DNS-1123, port ranges, resource quantities, duration patterns)
- Enums (ClusterIP, Always, TCP, strategy types, protocols)
- Required fields (unconditional and conditional via `if/then/else`)
- Min/max constraints (minLength, maxLength, minimum, maximum, minProperties)
- `additionalProperties: false` on known-key objects to catch typos (e.g., `destinationrule` vs `destinationRule`)

**Layer 2 (Go Templates)** runs during template rendering (after schema passes). It enforces:
- Business logic requiring iteration (e.g., "at least one enabled container")
- Zero-value awareness (distinguishing `0` from absent using `index + ne nil`)
- Mutual exclusivity (e.g., PDB minAvailable vs maxUnavailable)

## Behavior: Error Aggregation

- Schema validation reports ALL structural errors together
- Template validation collects ALL business logic errors and reports them together
- No resources are rendered until all validations pass
- Error messages point to the exact field and how to fix it

## What Gets Validated?

Validations are enforced either by **JSON schema** or by **templates**. Each item below is marked with where it is enforced.

### Global Configuration
- [schema] `global.name` is required and not empty
- [schema] `global.name` is valid DNS-1123 format (lowercase, alphanumeric, dashes)
- [schema] `global.name` is ≤ 63 characters
- [schema] `global.namespace` is required and not empty
- [template] `global.labels.overrides` cannot override selector labels (`app.kubernetes.io/name`, `app.kubernetes.io/instance`)

### Deployment
- [schema] At least one container must be defined (minProperties: 1)
- [schema] Container names match DNS-1123 subdomain pattern
- [schema] Each container has `image` object with `repository` and `tag` (minLength 1)
- [schema] Container ports (when defined) are in range 1-65535
- [schema] Resources (when defined) must have `requests` and `limits` as objects
- [template] At least one container must be enabled (requires iteration logic)

### Networking - HTTPRoute
- [schema] When HTTPRoute is enabled: host, port, gateway.name, and gateway.namespace are required and non-empty (via `if/then/else`)
- [schema] Port is in range 1-65535

### Networking - Service
- [schema] Service items (when defined) have required `enabled`, `type`, `ports`; ports object has minProperties 1; port numbers 1-65535

### Networking - DestinationRule (Istio)
- [schema] When DestinationRule is enabled, host is required and non-empty (via `if/then/else`)

### Storage - PVC
- [schema] When persistence is enabled and claims are defined: each claim has required `size` and `storageClass`; size matches Kubernetes format (e.g. `1Gi`); accessMode is valid enum

### Observability - ServiceMonitor
- [schema] When ServiceMonitor is configured: port in range 1-65535; interval and scrapeTimeout match duration pattern (e.g. `10s`, `1m`)

### Security - SealedSecret
- [schema] SealedSecret items require `data` with minProperties 1
- [schema] All data values must be non-empty strings (encrypted base64 values)

### Workload - PodDisruptionBudget
- [template] When PDB is enabled: exactly one of minAvailable or maxUnavailable must be set (mutually exclusive with zero-value awareness)

## How to See Validation Errors

### Schema Validation Errors

When a value fails schema validation, you'll see errors from `helm lint`, `helm install`, `helm upgrade`, or `helm template`:

```bash
helm template my-release ./my-chart -f values.yaml
# Error: values don't meet the specifications of the schema(s) in the following chart(s):
# my-chart:
# - httpRoute: host is required
# - httpRoute.gateway: name is required
```

### Template Validation Errors

When a value fails template validation:

```bash
helm template my-release ./my-chart -f values.yaml
# Error: execution error at (libChart/templates/helpers/_validations.tpl:XX:YY):
#   deployment.containers must have at least one enabled container
```

> **Tip:** All validation rules and fixes are documented in this file. Search for the error message text to find the corresponding "Fix" section.

## How to Fix Common Issues

### Empty or Missing global.name

**Error:**
```
global.name is required
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

### No Enabled Containers

**Error:**
```
deployment.containers must have at least one enabled container
```

**Fix:**
```yaml
deployment:
  containers:
    app:
      enabled: true  # At least one container must be enabled
      image:
        repository: "nginx"
        tag: "1.25"
```

### PDB Mutual Exclusivity

**Error:**
```
podDisruptionBudget.minAvailable and maxUnavailable are mutually exclusive (set only one)
```

**Fix:**
```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1  # Use EITHER minAvailable OR maxUnavailable, not both
  # maxUnavailable: 1  # Comment out one of them
```

## Testing Validations

helm-common-lib uses a comprehensive testing strategy for validations:

### 1. Schema Fail-Case Tests (`make test-schema`)

Automated tests in `tests/schema-fail-cases/` verify that invalid values are rejected by the schema:
- Invalid DNS-1123 names (uppercase, special characters)
- Unknown enum values (invalid strategy types, service types)
- Out-of-range ports
- Typos in property names (caught by `additionalProperties: false`)
- Missing required fields when features are enabled

Run: `make test-schema` or `./scripts/test-schema.sh`

### 2. Template Business Logic Tests

`test-chart/tests/validation_test.yaml` uses helm-unittest `failedTemplate` assertions to verify template-level validations:
- At least one enabled container (iteration logic)
- PDB mutual exclusivity (zero-value awareness)

Run: `make test`

### 3. Template Error Aggregation Test (`make test-aggregation`)

`scripts/test-validation-aggregation.sh` verifies multi-domain template error aggregation via `helm template` output:
- Confirms render fails when multiple validation domains are violated
- Confirms all expected error messages are present in output
Run: `make test-aggregation`

### 4. Integration Tests

Snapshot testing (`make validate`) catches unintentional rendering changes after any validation updates.

## Implementation Details

### Architecture

Validations are split between JSON Schema and Go templates:

**JSON Schema** (`libChart/values.schema.json`):
- Structural validation (types, patterns, enums, required fields, minProperties, additionalProperties)
- Conditional requirements via `if/then/else` (JSON Schema draft-07)
- Runs before template rendering on `helm lint`/`install`/`upgrade`/`template`
- Uses `additionalProperties: false` on known-key objects to prevent typos and enforce camelCase naming

**Go Templates** (`libChart/templates/helpers/validations/`):
- **Orchestrator** — `_validations.tpl`: defines `libChart.validations`, which includes deployment and PDB validations
- **Domain files**:
  - `_deployment.tpl` — at least one enabled container (iteration logic)
  - `_pdb.tpl` — minAvailable and maxUnavailable mutually exclusive (zero-value awareness)

**Kubernetes Pass-Through Objects**: Some schema fields (`podSecurityContext`, `securityContext`, `resources.requests`, `resources.limits`, `livenessProbe`, `readinessProbe`, `startupProbe`, `lifecycle`) are typed as `"type": "object"` with NO `additionalProperties: false`. This allows users to pass any valid Kubernetes API field. The structure (e.g., `resources` must have `requests`/`limits` as objects) is validated, but the contents are passed through to kubeconform and ultimately the Kubernetes API server.

**Design choice (fail vs required):** The orchestrator uses `fail()` with error aggregation instead of Helm's built-in `required()` function. The `required()` function stops at the first missing value; our approach collects ALL errors and reports them together, so users can fix everything in one pass. See [Helm Tips: Using the 'required' function](https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-required-function).

### How It Works

1. **Schema Validation** (`values.schema.json`) runs first on `helm lint`/`install`/`upgrade`/`template`. It validates structure, types, patterns, conditional requirements using `if/then/else`, and catches typos via `additionalProperties: false`.
2. **Template Validation** (`libChart/templates/helpers/_validations.tpl`) runs during template rendering (after schema passes). It validates business logic that schema cannot express.
3. **Kubernetes Manifest Validation** (kubeconform) validates rendered manifests against K8s API schemas, including CRDs fetched from [datreeio/CRDs-catalog](https://github.com/datreeio/CRDs-catalog).
4. **Error collection** uses string concatenation — each domain template appends errors to a list, and the orchestrator joins them with newlines before calling `fail`.

### Adding New Validations

**For structural checks (types, patterns, conditional-required):** Add to `libChart/values.schema.json`.

Example - add conditional requirement using `if/then/else`:

```json
"myFeature": {
  "type": "object",
  "properties": {
    "enabled": { "type": "boolean", "default": false },
    "host": { "type": "string" }
  },
  "if": {
    "properties": { "enabled": { "const": true } },
    "required": ["enabled"]
  },
  "then": {
    "required": ["host"],
    "properties": {
      "host": { "minLength": 1 }
    }
  }
}
```

**For business logic (iteration, zero-value awareness, cross-field rules):** Create a template file.

1. Create `libChart/templates/helpers/validations/_<domain>.tpl` with a define `libChart.validation.<domain>` that returns errors as a newline-delimited string (or empty string if valid).
2. Add `"libChart.validation.<domain>"` to the `$validators` list in `libChart/templates/helpers/_validations.tpl`.

Example:

```yaml
{{- define "libChart.validation.myFeature" -}}
{{- $errors := list -}}
{{- if .Values.myFeature.enabled }}
  {{- $items := .Values.myFeature.items | default dict }}
  {{- if eq (len $items) 0 }}
    {{- $errors = append $errors "myFeature.items must have at least one item when enabled" -}}
  {{- end }}
{{- end }}
{{- join "\n" $errors -}}
{{- end -}}
```

**Decision rule:** If JSON Schema can express it with a clear error message, it goes in schema. Templates are reserved for iteration-based logic, nil-awareness, and complex cross-field business rules.

### Skipping Validations

Validations run unconditionally when a feature is enabled. To skip a specific validation, disable the feature flag that triggers it (e.g. set `podDisruptionBudget.enabled: false`). This follows Helm's convention: values drive behavior.

## Feedback

If you encounter false positives, missing validations, or have suggestions for clearer error messages, please open an issue with your values (redacted if needed) and the error message.
