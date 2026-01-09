{{- define "libChart.classes.pvc" -}}
{{- if and .Values.persistence .Values.persistence.enabled .Values.persistence.claims }}
  {{- range $name, $claim := .Values.persistence.claims }}
    {{- if $claim }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ printf "%s-%s" (include "common.helpers.chart.names.name" $) $name }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "pvc"
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

