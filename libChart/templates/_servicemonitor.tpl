{{- define "libchart.classes.servicemonitor" -}}
{{- if and .Values.metrics .Values.metrics.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- $chartName := include "common.helpers.chart.names.chart" . -}}
    {{- $appName := include "common.helpers.chart.names.name" . -}}
    {{- $appVersion := .Chart.AppVersion -}}
    {{- if and .Values.global .Values.global.chart .Values.global.chart.appVersion -}}
      {{- $appVersion = .Values.global.chart.appVersion -}}
    {{- end -}}
    {{- $labels := dict
      "helm.sh/chart" $chartName
      "app.kubernetes.io/name" $appName
      "app.kubernetes.io/instance" .Release.Name
      "app.kubernetes.io/version" $appVersion
      "app.kubernetes.io/managed-by" .Release.Service
      "app.kubernetes.io/component" "servicemonitor"
    -}}
    {{- toYaml $labels | nindent 4 }}
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

