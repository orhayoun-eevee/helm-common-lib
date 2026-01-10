{{- define "libChart.classes.servicemonitor" -}}
{{- if and .Values.metrics .Values.metrics.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: servicemonitor
spec:
  selector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" . | nindent 6 }}
  endpoints:
    - port: metrics
      interval: {{ .Values.metrics.interval | default "10s" }}
      scrapeTimeout: {{ .Values.metrics.scrapeTimeout | default "5s" }}
      {{- if .Values.metrics.component }}
      metricRelabelings:
        - targetLabel: component
          replacement: {{ .Values.metrics.component }}
      {{- end }}
{{- end }}
{{- end -}}

