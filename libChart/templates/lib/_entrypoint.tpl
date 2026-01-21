{{- define "libChart.all" -}}

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
