{{- define "libChart.lib.pdb" -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled }}
{{ include "libChart.classes.poddisruptionbudget" . }}
{{- end }}
{{- end -}}
