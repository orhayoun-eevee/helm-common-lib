{{- define "libChart.lib.prometheus" -}}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.serviceMonitor .Values.metrics.serviceMonitor.enabled }}
{{ include "libChart.classes.servicemonitor" . }}
{{- end }}
{{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.prometheusRule .Values.metrics.prometheusRule.enabled .Values.metrics.prometheusRule.rules }}
{{ include "libChart.classes.prometheusrule" . }}
{{- end }}
{{- end -}}
