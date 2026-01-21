{{- define "libChart.lib.deployment" -}}
{{- if and .Values.deployment .Values.deployment.containers }}
{{ include "libChart.classes.deployment" . }}
{{- end }}
{{- end -}}
