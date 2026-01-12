{{- define "libChart.classes.prometheusrule" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.rules }}
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
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
      "app.kubernetes.io/component" "prometheus-rule"
    -}}
    {{- toYaml $labels | nindent 4 }}

spec:
  groups:
    - name: {{ include "common.helpers.chart.names.name" . }}.rules
      rules:
        {{- toYaml .Values.metrics.rules | nindent 8 }}
{{- end }}
{{- end -}}
