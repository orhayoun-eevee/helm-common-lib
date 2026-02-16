{{- define "libChart.classes.configmap" -}}
{{- if and .Values.configMap .Values.configMap.items }}
{{- $namePrefix := include "libChart.name" . -}}
{{- $componentLabel := .Values.configMap.componentLabel | default "config" -}}
{{- $additionalLabels := .Values.configMap.additionalLabels | default dict -}}
{{- $items := .Values.configMap.items -}}
{{- range $itemKey := (keys $items | sortAlpha) }}
{{- $item := index $items $itemKey }}
{{- $configMapName := printf "%s-%s" $namePrefix $itemKey -}}
{{- $configMapData := $item.data -}}
{{- $labels := include "libChart.labelsWithComponent" (dict "root" $ "component" $componentLabel) | fromYaml -}}
{{- range $k := (keys $additionalLabels | sortAlpha) }}
  {{- $_ := set $labels $k (index $additionalLabels $k) -}}
{{- end }}
{{- $annotations := $item.annotations | default (dict) -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configMapName }}
  namespace: {{ $.Values.global.namespace | default "default" }}
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
