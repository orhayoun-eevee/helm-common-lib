{{- define "libChart.lib.httproute" -}}
{{- if and .Values.network.httpRoute .Values.network.httpRoute.enabled }}
{{ include "libChart.classes.httproute" . }}
{{- end }}
{{- end -}}
