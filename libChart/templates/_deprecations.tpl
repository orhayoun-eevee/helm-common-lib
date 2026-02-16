{{- /*
  Deprecation warnings: emitted as YAML comments so users see them in helm template output.
  Does not fail; only warns.

  Currently empty. Most deprecated keys (e.g., persistence.retain, destinationrule) are now
  caught by the JSON Schema (additionalProperties: false) before template rendering, which is
  the preferred approach. This template is reserved for deprecations that schema cannot express
  (e.g., renamed nested fields, behavioral changes).

  To add a deprecation:
    1. Append to $warnings inside the define block
    2. Document it in docs/DEPRECATIONS.md
    3. Remove after the deprecation window (typically one minor version)
*/ -}}
{{- define "libChart.deprecations" -}}
{{- $warnings := list -}}
{{- /* No active deprecation checks. See docs/DEPRECATIONS.md for history. */ -}}
{{- if $warnings -}}
# --- DEPRECATION WARNINGS ---
{{- range $warnings }}
# {{ . }}
{{- end }}
# ---
{{- end -}}
{{- end -}}
