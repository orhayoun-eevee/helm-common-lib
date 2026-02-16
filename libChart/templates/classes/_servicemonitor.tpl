{{- define "libChart.classes.servicemonitor" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.serviceMonitor .Values.metrics.serviceMonitor.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "libChart.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "servicemonitor") | nindent 4 }}
spec:
  {{- if .Values.metrics.serviceMonitor.selector }}
  selector:
    {{- toYaml .Values.metrics.serviceMonitor.selector | nindent 4 }}
  {{- else }}
  selector:
    matchLabels:
      {{- include "libChart.selectorLabels" . | nindent 6 }}
  {{- end }}
  {{- if .Values.metrics.serviceMonitor.namespaceSelector }}
  namespaceSelector:
    {{- toYaml .Values.metrics.serviceMonitor.namespaceSelector | nindent 4 }}
  {{- end }}
  endpoints:
    - port: {{ .Values.metrics.serviceMonitor.portName | default "metrics" }}
      interval: {{ .Values.metrics.serviceMonitor.interval | default "10s" }}
      scrapeTimeout: {{ .Values.metrics.serviceMonitor.scrapeTimeout | default "5s" }}
      {{- if .Values.metrics.serviceMonitor.path }}
      path: {{ .Values.metrics.serviceMonitor.path }}
      {{- end }}
      {{- if .Values.metrics.serviceMonitor.honorLabels }}
      honorLabels: {{ .Values.metrics.serviceMonitor.honorLabels }}
      {{- end }}
      {{- if .Values.metrics.serviceMonitor.relabelings }}
      relabelings:
        {{- toYaml .Values.metrics.serviceMonitor.relabelings | nindent 8 }}
      {{- end }}
      {{- if .Values.metrics.serviceMonitor.metricRelabelings }}
      metricRelabelings:
        {{- toYaml .Values.metrics.serviceMonitor.metricRelabelings | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
