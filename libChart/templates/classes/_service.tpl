{{- define "libChart.classes.service" -}}
{{- if and .Values.network.services .Values.network.services.items -}}
{{- range $serviceKey, $service := .Values.network.services.items }}
{{- if and $service.enabled $service.ports }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.helpers.chart.names.name" $ }}-{{ $serviceKey }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "service"
  {{- if $service.annotations }}
  annotations:
    {{- toYaml $service.annotations | nindent 4 }}
  {{- end }}
spec:
  type: {{ $service.type | default "ClusterIP" }}
  ports:
    {{- range $portName, $port := $service.ports }}
    - name: {{ $portName }}
      port: {{ $port.port }}
      targetPort: {{ $port.targetPort }}
      protocol: {{ $port.protocol | default "TCP" }}
    {{- end }}
  selector:
    {{- include "common.helpers.metadata.selectorLabels" $ | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
