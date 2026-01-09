{{- define "common.helpers.metadata.labels" -}}
helm.sh/chart: {{ include "common.helpers.chart.names.chart" . }}
app.kubernetes.io/name: {{ include "common.helpers.chart.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: service
app.kubernetes.io/name: radarr
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}