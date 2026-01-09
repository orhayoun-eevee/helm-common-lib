{{- define "common.helpers.metadata.labels" -}}
{{- $chartName := include "common.helpers.chart.names.chart" . -}}
{{- $appName := include "common.helpers.chart.names.name" . -}}
{{- $appVersion := .Chart.AppVersion -}}
{{- if and .Values.global .Values.global.chart .Values.global.chart.appVersion -}}
  {{- $appVersion = .Values.global.chart.appVersion -}}
{{- end -}}
helm.sh/chart: {{ $chartName }}
app.kubernetes.io/name: {{ $appName }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ $appVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
