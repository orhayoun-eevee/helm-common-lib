{{- define "libChart.all" -}}

{{- /* ---- Deprecation warnings (emit as comments, do not fail) ---- */ -}}
{{- include "libChart.deprecations" . -}}

{{- /* ---- Validations (fail-fast with clear errors) ---- */ -}}
{{- include "libChart.validations" . -}}

{{- /* ---- Workload ---- */ -}}
{{ include "libChart.group.workload" . }}

{{- /* ---- Networking ---- */ -}}
{{ include "libChart.group.networking" . }}

{{- /* ---- Observability ---- */ -}}
{{ include "libChart.group.observability" . }}

{{- /* ---- Storage ---- */ -}}
{{ include "libChart.group.storage" . }}

{{- /* ---- Security ---- */ -}}
{{ include "libChart.group.security" . }}

{{- end -}}
