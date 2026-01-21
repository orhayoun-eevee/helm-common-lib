{{- define "libChart.lib.serviceaccount" -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create }}
{{ include "libChart.classes.serviceaccount" . }}
{{- end }}
{{- end -}}
