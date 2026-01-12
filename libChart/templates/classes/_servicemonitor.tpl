{{- define "libChart.classes.servicemonitor" -}}
{{- if and .Values.metrics .Values.metrics.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "servicemonitor"
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  selector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" . | nindent 6 }}
  {{- if .Values.metrics.namespaceSelector }}
  namespaceSelector:
    {{- toYaml .Values.metrics.namespaceSelector | nindent 4 }}
  {{- end }}
  endpoints:
    - port: metrics
      interval: {{ .Values.metrics.interval | default "10s" }}
      scrapeTimeout: {{ .Values.metrics.scrapeTimeout | default "5s" }}
      {{- if .Values.metrics.path }}
      path: {{ .Values.metrics.path }}
      {{- end }}
      {{- if .Values.metrics.honorLabels }}
      honorLabels: {{ .Values.metrics.honorLabels }}
      {{- end }}
      {{- if .Values.metrics.relabelings }}
      relabelings:
        {{- toYaml .Values.metrics.relabelings | nindent 8 }}
      {{- end }}
      {{- if .Values.metrics.metricRelabelings }}
      metricRelabelings:
        {{- toYaml .Values.metrics.metricRelabelings | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
