{{- define "libChart.classes.destinationRule" -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.destinationRule .Values.network.istio.destinationRule.enabled .Values.network.istio.destinationRule.host (ne (.Values.network.istio.destinationRule.host | toString) "") }}
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ include "libChart.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "destination-rule") | nindent 4 }}
spec:
  host: {{ .Values.network.istio.destinationRule.host }}
  {{- if .Values.network.istio.destinationRule.trafficPolicy }}
  trafficPolicy:
    {{- toYaml .Values.network.istio.destinationRule.trafficPolicy | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
