{{- define "libChart.classes.serviceaccount" -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name | default (include "libChart.name" .) }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "serviceaccount") | nindent 4 }}
  {{- if .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml .Values.serviceAccount.annotations | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount | default false }}
{{- end -}}
{{- end -}}
