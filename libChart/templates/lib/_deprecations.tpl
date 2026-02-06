{{- /*
  Deprecation warnings: collect and emit as YAML comments so users see them when running helm template.
  Does not fail; only warns.
*/ -}}
{{- define "libChart.deprecations" -}}
{{- $warnings := list -}}

{{- /* Legacy persistence.retain at top level -> use persistence.claims.<name>.retain */ -}}
{{- if and .Values.persistence (hasKey .Values.persistence "retain") -}}
  {{- $warnings = append $warnings "persistence.retain is deprecated. Use per-claim setting: persistence.claims.<claimName>.retain (default: true)." -}}
{{- end -}}

{{- /* Emit warnings as YAML comments at the start of the manifest */ -}}
{{- if $warnings -}}
# --- DEPRECATION WARNINGS ---
{{- range $warnings }}
# {{ . }}
{{- end }}
# ---
{{- end -}}
{{- end -}}
