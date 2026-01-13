{{- define "libChart.classes.grafana" -}}
{{- if and .Values.metrics.grafana .Values.metrics.grafana.enabled -}}
  {{- if and .Values.metrics.grafana.dashboard .Values.metrics.grafana.dashboard.enabled .Values.metrics.grafana.dashboard.items -}}
    {{- $root := . -}}
    {{- $namePrefix := include "common.helpers.chart.names.name" $root -}}
    {{- $additionalLabels := dict "grafana_dashboard" "1" -}}
    {{- range $dashboardKey, $dashboard := .Values.metrics.grafana.dashboard.items }}
    {{- if $dashboard.enabled }}
      {{- $dashboardName := printf "%s.json" $dashboardKey -}}
      {{- toYaml $dashboard -}}
      {{- $jsonContent := $dashboard.json -}}
      {{- if kindIs "map" $jsonContent -}}
        {{- $jsonContent = $jsonContent | toJson -}}
      {{- end -}}
      {{- $dashboardData := dict $dashboardName $jsonContent -}}
      {{- $item := dict "data" $dashboardData -}}
      {{- if $dashboard.annotations -}}
        {{- $_ := set $item "annotations" $dashboard.annotations -}}
      {{- end -}}
      {{- $singleItemDict := dict $dashboardKey $item -}}
      {{- include "libChart.classes.configmap" (dict "items" $singleItemDict "namePrefix" $namePrefix "componentLabel" "grafana-dashboard" "additionalLabels" $additionalLabels "context" $root) -}}
    {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- end -}}
