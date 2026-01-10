{{- define "libChart.classes.prometheusrule" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.rules }}
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
spec:
  groups:
    - name: {{ include "common.helpers.chart.names.name" . }}.rules
      rules:
        {{- toYaml .Values.metrics.rules | nindent 8 }}
{{- end }}
{{- end -}}

