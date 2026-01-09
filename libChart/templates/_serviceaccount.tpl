{{- define "libChart.classes.serviceaccount" -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name | default (include "common.helpers.chart.names.name" .) }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "serviceaccount"
  {{- if .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml .Values.serviceAccount.annotations | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount | default false }}
{{- end -}}
{{- end -}}
