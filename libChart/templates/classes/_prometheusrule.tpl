{{- define "libChart.classes.prometheusrule" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.prometheusRule .Values.metrics.prometheusRule.enabled .Values.metrics.prometheusRule.rules }}
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "libChart.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "prometheus-rule") | nindent 4 }}
spec:
  groups:
    - name: {{ include "libChart.name" . }}.rules
      rules:
        {{- toYaml .Values.metrics.prometheusRule.rules | nindent 8 }}
{{- end }}
{{- end -}}
