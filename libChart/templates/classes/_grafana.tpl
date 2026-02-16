{{- define "libChart.classes.grafana" -}}
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  {{- with .labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .instanceSelector }}
  instanceSelector:
    {{- with .matchLabels }}
    matchLabels:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .matchExpressions }}
    matchExpressions:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- with .json }}
  json: |
{{- . | nindent 4 }}
  {{- end }}
  {{- with .folder }}
  folder: {{ . | quote }}
  {{- end }}
  {{- with .folderUID }}
  folderUID: {{ . | quote }}
  {{- end }}
  {{- with .folderRef }}
  folderRef: {{ . | quote }}
  {{- end }}
  {{- with .plugins }}
  plugins:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if hasKey . "allowCrossNamespaceImport" }}
  allowCrossNamespaceImport: {{ .allowCrossNamespaceImport }}
  {{- end }}
{{- end -}}
