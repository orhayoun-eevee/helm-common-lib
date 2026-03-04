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
    {{- $rules := tpl (toYaml $route.rules) $ | fromYamlArray }}
    {{- toYaml $rules | nindent 4 }}
    {{- else if $route.matches }}
    {{- $rule := dict "matches" (tpl (toYaml $route.matches) $ | fromYamlArray) }}
    {{- if $route.backendRefs }}
      {{- $rule = set $rule "backendRefs" (tpl (toYaml $route.backendRefs) $ | fromYamlArray) }}
    {{- end }}
    {{- if $route.filters }}
      {{- $rule = set $rule "filters" (tpl (toYaml $route.filters) $ | fromYamlArray) }}
    {{- end }}
    {{- toYaml (list $rule) | nindent 4 }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
