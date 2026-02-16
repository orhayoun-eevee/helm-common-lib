{{- define "libChart.grafanaDashboard" -}}
{{- with .Values.metrics.grafana }}
  {{- if and .enabled .dashboard .dashboard.enabled .dashboard.items }}
    {{- $namePrefix := include "libChart.name" $ -}}
    {{- $baseLabels := include "libChart.labels" $ | fromYaml -}}
    {{- $_ := set $baseLabels "app.kubernetes.io/component" "grafana-dashboard" -}}
    {{- $globalInstanceSelector := .instanceSelector | default (dict) -}}
    {{- $namespace := $.Values.global.namespace | default "default" -}}
    {{- range $dashboardKey, $dashboard := .dashboard.items }}
      {{- if $dashboard.enabled }}
        {{- $resourceName := printf "%s-%s" $namePrefix $dashboardKey -}}
        {{- $jsonContent := "" -}}

        {{- /* Load JSON from file if specified, otherwise use inline json */ -}}
        {{- if $dashboard.file }}
          {{- $filePath := printf "dashboards/%s" $dashboard.file -}}
          {{- $fileContent := $.Files.Get $filePath -}}
          {{- if $fileContent }}
            {{- /* fromJson will fail with clear error if JSON is invalid */ -}}
            {{- $jsonContent = $fileContent | fromJson | toJson -}}
          {{- else }}
            {{- fail (printf "Grafana dashboard file not found: %s" $filePath) }}
          {{- end }}
        {{- else if $dashboard.json }}
          {{- if kindIs "map" $dashboard.json }}
            {{- $jsonContent = $dashboard.json | toJson -}}
          {{- else if kindIs "string" $dashboard.json }}
            {{- /* fromJson will fail with clear error if JSON is invalid */ -}}
            {{- $jsonContent = $dashboard.json | fromJson | toJson -}}
          {{- else }}
            {{- fail (printf "Grafana dashboard '%s' has invalid json type: expected string or map, got %s" $dashboardKey (kindOf $dashboard.json)) }}
          {{- end }}
        {{- end }}

        {{- if $jsonContent }}
          {{- $params := dict "name" $resourceName "namespace" $namespace "labels" $baseLabels "json" $jsonContent -}}
          {{- $params = merge $params (dict "instanceSelector" ($dashboard.instanceSelector | default $globalInstanceSelector)) -}}
          {{- if $dashboard.annotations }}
            {{- $params = merge $params (dict "annotations" $dashboard.annotations) -}}
          {{- end }}
          {{- if $dashboard.folder }}
            {{- $params = merge $params (dict "folder" $dashboard.folder) -}}
          {{- end }}
          {{- if $dashboard.folderUID }}
            {{- $params = merge $params (dict "folderUID" $dashboard.folderUID) -}}
          {{- end }}
          {{- if $dashboard.folderRef }}
            {{- $params = merge $params (dict "folderRef" $dashboard.folderRef) -}}
          {{- end }}
          {{- if $dashboard.plugins }}
            {{- $params = merge $params (dict "plugins" $dashboard.plugins) -}}
          {{- end }}
          {{- if hasKey $dashboard "allowCrossNamespaceImport" }}
            {{- $params = merge $params (dict "allowCrossNamespaceImport" $dashboard.allowCrossNamespaceImport) -}}
          {{- end }}
          {{- include "libChart.classes.grafana" $params -}}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
