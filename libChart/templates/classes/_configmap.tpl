{{- define "libChart.classes.configmap" -}}
{{- $items := .items -}}
{{- $namePrefix := .namePrefix -}}
{{- $componentLabel := .componentLabel -}}
{{- $additionalLabels := .additionalLabels -}}
{{- $context := .context -}}
{{- if $items }}
{{- range $itemKey, $item := $items }}
{{- $configMapName := printf "%s-%s" $namePrefix $itemKey -}}
{{- $configMapData := $item.data -}}
{{- $baseLabels := include "common.helpers.metadata.labels" $context | fromYaml -}}
{{- $labels := $baseLabels }}
{{- if $componentLabel }}
  {{- $labels = merge $labels (dict "app.kubernetes.io/component" $componentLabel) -}}
{{- end }}
{{- if $additionalLabels }}
  {{- $labels = merge $labels $additionalLabels -}}
{{- end }}
{{- $annotations := $item.annotations | default (dict) -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configMapName }}
  namespace: {{ $context.Values.global.namespace | default "default" }}
  {{- if $labels }}
  labels:
    {{- toYaml $labels | nindent 4 }}
  {{- end }}
  {{- if $annotations }}
  annotations:
    {{- toYaml $annotations | nindent 4 }}
  {{- end }}
data:
  {{- toYaml $configMapData | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}
