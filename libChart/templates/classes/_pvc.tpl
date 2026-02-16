{{- define "libChart.classes.pvc" -}}
{{- if and .Values.persistence .Values.persistence.enabled .Values.persistence.claims }}
  {{- $claims := .Values.persistence.claims -}}
  {{- range $name := (keys $claims | sortAlpha) }}
    {{- $claim := index $claims $name }}
    {{- if $claim }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ printf "%s-%s" (include "libChart.name" $) $name }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "pvc") | nindent 4 }}
  {{- if $claim.retain }}
  annotations:
    helm.sh/resource-policy: keep
  {{- end }}
spec:
  accessModes:
    - {{ $claim.accessMode | default "ReadWriteOnce" }}
  {{- if $claim.storageClass }}
  storageClassName: {{ $claim.storageClass }}
  {{- end }}
  resources:
    requests:
      storage: {{ $claim.size }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
