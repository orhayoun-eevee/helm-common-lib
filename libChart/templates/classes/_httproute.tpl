{{- define "libChart.classes.httproute" -}}
{{- if and .Values.network.httpRoute .Values.network.httpRoute.enabled }}
{{- $baseName := include "libChart.name" . }}
{{- $httpRoute := .Values.network.httpRoute }}
{{- $gateway := $httpRoute.gateway }}
{{- $defaultHostnames := list }}
{{- if and (ne $httpRoute.hosts nil) (gt (len $httpRoute.hosts) 0) }}
  {{- $defaultHostnames = $httpRoute.hosts }}
{{- else if $httpRoute.host }}
  {{- $defaultHostnames = list $httpRoute.host }}
{{- end }}
{{- range $route := $httpRoute.routes }}
{{- if $route.enabled }}
{{- $routeHostnames := $defaultHostnames }}
{{- if and (ne $route.hostnames nil) (gt (len $route.hostnames) 0) }}
  {{- $routeHostnames = $route.hostnames }}
{{- end }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $baseName }}-{{ $route.name }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "http-route") | nindent 4 }}
spec:
  parentRefs:
    - name: {{ $gateway.name }}
      namespace: {{ $gateway.namespace }}
      kind: Gateway
      group: gateway.networking.k8s.io
      {{- if $route.listener.sectionName }}
      sectionName: {{ $route.listener.sectionName }}
      {{- end }}
      {{- if $route.listener.port }}
      port: {{ $route.listener.port }}
      {{- end }}
  hostnames:
    {{- toYaml $routeHostnames | nindent 4 }}
  rules:
    {{- if $route.rules }}
    {{- range $route.rules }}
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
    {{- else if $route.matches }}
    - matches:
        {{- toYaml $route.matches | nindent 8 }}
      {{- if $route.backendRefs }}
      backendRefs:
        {{- toYaml $route.backendRefs | nindent 8 }}
      {{- end }}
      {{- if $route.filters }}
      filters:
        {{- toYaml $route.filters | nindent 8 }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
