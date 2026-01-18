{{- define "libChart.classes.destinationrule" -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.destinationrule .Values.network.istio.destinationrule.enabled .Values.network.istio.destinationrule.host (ne (.Values.network.istio.destinationrule.host | toString) "") }}
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "destination-rule"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  host: {{ .Values.network.istio.destinationrule.host }}
  {{- if .Values.network.istio.destinationrule.trafficPolicy }}
  trafficPolicy:
    {{- toYaml .Values.network.istio.destinationrule.trafficPolicy | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
