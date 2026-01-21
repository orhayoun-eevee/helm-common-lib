{{- define "libChart.lib.service" -}}
{{- if and .Values.network.services .Values.network.services.items }}
{{ include "libChart.classes.service" . }}
{{- end }}
{{- end -}}
