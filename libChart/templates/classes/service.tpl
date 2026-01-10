{{- define "libChart.classes.service" -}}
{{- if and .Values.service .Values.service.ports -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: service
  {{- if .Values.service.annotations }}
  annotations:
    {{- toYaml .Values.service.annotations | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  ports:
    {{- range $name, $port := .Values.service.ports }}
    - name: {{ $name }}
      port: {{ $port.port }}
      targetPort: {{ $port.targetPort }}
      protocol: {{ $port.protocol | default "TCP" }}
    {{- end }}
  selector:
    app.kubernetes.io/name: {{ include "common.helpers.chart.names.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end -}}

