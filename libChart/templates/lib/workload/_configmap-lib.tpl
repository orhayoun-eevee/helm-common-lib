{{- define "libChart.lib.configmap" -}}
{{- if and .Values.configMap .Values.configMap.items }}
{{- $ctx := dict "items" .Values.configMap.items "namePrefix" (.Values.global.name | default "app") "componentLabel" (.Values.configMap.componentLabel | default "config") "additionalLabels" (.Values.configMap.additionalLabels | default dict) "context" . }}
{{ include "libChart.classes.configmap" $ctx }}
{{- end }}
{{- end -}}
