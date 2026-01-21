{{- define "libChart.lib.pvc" -}}
{{- if and .Values.persistence .Values.persistence.enabled .Values.persistence.claims }}
{{ include "libChart.classes.pvc" . }}
{{- end }}
{{- end -}}
