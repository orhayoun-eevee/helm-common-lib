{{- define "libChart.classes.destinationrule" -}}
{{- if and .Values.circuitBreaker .Values.circuitBreaker.enabled }}
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "destination-rule"

spec:
  host: {{ include "common.helpers.chart.names.name" . }}
  {{- if .Values.circuitBreaker.trafficPolicy }}
  trafficPolicy:
    {{- toYaml .Values.circuitBreaker.trafficPolicy | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}

