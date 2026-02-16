{{- define "libChart.classes.service" -}}
{{- if and .Values.network.services .Values.network.services.items -}}
{{- $items := .Values.network.services.items -}}
{{- range $serviceKey := (keys $items | sortAlpha) }}
{{- $service := index $items $serviceKey }}
{{- if and $service.enabled $service.ports }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "libChart.name" $ }}-{{ $serviceKey }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" (printf "service-%s" $serviceKey)) | nindent 4 }}
  {{- if $service.annotations }}
  annotations:
    {{- toYaml $service.annotations | nindent 4 }}
  {{- end }}
spec:
  type: {{ $service.type | default "ClusterIP" }}
  ports:
    {{- range $portName := (keys $service.ports | sortAlpha) }}
    {{- $port := index $service.ports $portName }}
    - name: {{ $portName }}
      port: {{ $port.port }}
      targetPort: {{ $port.targetPort }}
      protocol: {{ $port.protocol | default "TCP" }}
    {{- end }}
  selector:
    {{- include "libChart.selectorLabels" $ | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
