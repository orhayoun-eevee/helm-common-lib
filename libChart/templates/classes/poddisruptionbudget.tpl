{{- define "libChart.classes.poddisruptionbudget" -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: pod-disruption-budget
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "common.helpers.chart.names.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- end }}
  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
{{- end }}
{{- end -}}

