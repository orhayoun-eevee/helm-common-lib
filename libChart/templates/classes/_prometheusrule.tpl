{{- define "libChart.classes.prometheusrule" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.prometheusRule .Values.metrics.prometheusRule.enabled .Values.metrics.prometheusRule.rules }}
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "prometheus-rule"

spec:
  groups:
    - name: {{ include "common.helpers.chart.names.name" . }}.rules
      rules:
        {{- toYaml .Values.metrics.prometheusRule.rules | nindent 8 }}
{{- end }}
{{- end -}}
