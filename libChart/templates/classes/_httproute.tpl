{{- define "libChart.classes.httproute" -}}
{{- if and .Values.network.httpRoute .Values.network.httpRoute.enabled .Values.network.httpRoute.host }}
{{- $baseName := include "common.helpers.chart.names.name" . }}
{{- $gateway := .Values.network.httpRoute.gateway }}
{{- $host := .Values.network.httpRoute.host }}
{{- range .Values.network.httpRoute.routes }}
{{- if .enabled }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $baseName }}-{{ .name }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "http-route"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  parentRefs:
    - name: {{ $gateway.name }}
      namespace: {{ $gateway.namespace }}
      kind: Gateway
      group: gateway.networking.k8s.io
      {{- if .listener.sectionName }}
      sectionName: {{ .listener.sectionName }}
      {{- end }}
      {{- if .listener.port }}
      port: {{ .listener.port }}
      {{- end }}
  hostnames:
    - {{ $host }}
  rules:
    {{- if .rules }}
    {{- range .rules }}
    - {{- if .matches }}
      matches:
        {{- toYaml .matches | nindent 8 }}
      {{- end }}
      {{- if .backendRefs }}
      backendRefs:
        {{- toYaml .backendRefs | nindent 8 }}
      {{- end }}
      {{- if .filters }}
      filters:
        {{- toYaml .filters | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- else if .matches }}
    - matches:
        {{- toYaml .matches | nindent 8 }}
      {{- if .backendRefs }}
      backendRefs:
        {{- toYaml .backendRefs | nindent 8 }}
      {{- end }}
      {{- if .filters }}
      filters:
        {{- toYaml .filters | nindent 8 }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
