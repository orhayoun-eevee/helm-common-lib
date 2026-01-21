{{- define "libChart.classes.grafana" -}}
{{- if and .Values.metrics.grafana .Values.metrics.grafana.enabled -}}
  {{- if and .Values.metrics.grafana.dashboard .Values.metrics.grafana.dashboard.enabled .Values.metrics.grafana.dashboard.items -}}
    {{- $root := . -}}
    {{- $namePrefix := include "common.helpers.chart.names.name" $root -}}
    {{- $baseLabels := include "common.helpers.metadata.labels" $root | fromYaml -}}
    {{- $globalInstanceSelector := .Values.metrics.grafana.instanceSelector | default (dict) -}}
    {{- range $dashboardKey, $dashboard := .Values.metrics.grafana.dashboard.items }}
      {{- $dashboardName := $dashboard.name | default $dashboardKey -}}
      {{- $resourceName := printf "%s-%s" $namePrefix $dashboardKey -}}
      {{- $jsonContent := "" -}}
      
      {{- /* Load JSON from file if specified, otherwise use inline json */ -}}
      {{- if $dashboard.file -}}
        {{- $filePath := printf "dashboards/%s" $dashboard.file -}}
        {{- if $.Files.Get $filePath -}}
          {{- $jsonContent = $.Files.Get $filePath -}}
        {{- else -}}
          {{- fail (printf "Grafana dashboard file not found: %s" $filePath) -}}
        {{- end -}}
      {{- else if $dashboard.json -}}
        {{- $jsonContent = $dashboard.json -}}
        {{- if kindIs "map" $jsonContent -}}
          {{- $jsonContent = $jsonContent | toJson -}}
        {{- end -}}
      {{- end -}}
      
      {{- if and $jsonContent (ne (toString $jsonContent) "") -}}
      {{- $labels := $baseLabels }}
      {{- $labels = merge $labels (dict "app.kubernetes.io/component" "grafana-dashboard") -}}
      {{- $instanceSelector := $globalInstanceSelector -}}
      {{- if $dashboard.instanceSelector -}}
        {{- $instanceSelector = $dashboard.instanceSelector -}}
      {{- end -}}
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: {{ $resourceName }}
  namespace: {{ $root.Values.global.namespace | default "default" }}
  {{- if $labels }}
  labels:
    {{- toYaml $labels | nindent 4 }}
  {{- end }}
  {{- if $dashboard.annotations }}
  annotations:
    {{- toYaml $dashboard.annotations | nindent 4 }}
  {{- end }}
spec:
  {{- if $instanceSelector }}
  instanceSelector:
    {{- if $instanceSelector.matchLabels }}
    matchLabels:
      {{- toYaml $instanceSelector.matchLabels | nindent 6 }}
    {{- end }}
    {{- if $instanceSelector.matchExpressions }}
    matchExpressions:
      {{- toYaml $instanceSelector.matchExpressions | nindent 6 }}
    {{- end }}
  {{- end }}
  json: |
{{ $jsonContent | indent 4 }}
  {{- if $dashboard.folder }}
  folder: {{ $dashboard.folder | quote }}
  {{- end }}
  {{- if $dashboard.folderUID }}
  folderUID: {{ $dashboard.folderUID | quote }}
  {{- end }}
  {{- if $dashboard.folderRef }}
  folderRef: {{ $dashboard.folderRef | quote }}
  {{- end }}
  {{- if $dashboard.plugins }}
  plugins:
    {{- toYaml $dashboard.plugins | nindent 4 }}
  {{- end }}
      {{- end -}}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- end -}}
