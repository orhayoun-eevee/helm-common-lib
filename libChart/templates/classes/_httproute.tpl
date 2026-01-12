{{- define "libChart.classes.httproute" -}}
{{- if and .Values.httpRoute .Values.httpRoute.enabled .Values.httpRoute.host }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "httproute"

spec:
  parentRefs:
    - name: {{ .Values.httpRoute.gateway.name }}
      namespace: {{ .Values.httpRoute.gateway.namespace }}
  hostnames:
    - {{ .Values.httpRoute.host }}
  rules:
    {{- range .Values.httpRoute.routes }}
    - matches:
        {{- if .rules }}
        {{- range .rules }}
        {{- if .matches }}
        {{- toYaml .matches | nindent 8 }}
        {{- end }}
        {{- end }}
        {{- else if .matches }}
        {{- toYaml .matches | nindent 8 }}
        {{- end }}
      backendRefs:
        {{- if .rules }}
        {{- range .rules }}
        {{- if .backendRefs }}
        {{- toYaml .backendRefs | nindent 8 }}
        {{- end }}
        {{- end }}
        {{- else if .backendRefs }}
        {{- toYaml .backendRefs | nindent 8 }}
        {{- end }}
      {{- if .filters }}
      filters:
        {{- toYaml .filters | nindent 8 }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
