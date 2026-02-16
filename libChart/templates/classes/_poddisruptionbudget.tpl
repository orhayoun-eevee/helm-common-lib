{{- define "libChart.classes.poddisruptionbudget" -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "libChart.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "pod-disruption-budget") | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "libChart.selectorLabels" . | nindent 6 }}
  {{- /* Use index + ne nil to support zero values (e.g., minAvailable: 0).
       A simple {{- if .val }} would drop 0 because Go templates treat 0 as falsy.
       This matches the pattern used in the PDB validation template (_pdb.tpl). */ -}}
  {{- $min := index .Values.podDisruptionBudget "minAvailable" }}
  {{- if ne $min nil }}
  minAvailable: {{ $min }}
  {{- end }}
  {{- $max := index .Values.podDisruptionBudget "maxUnavailable" }}
  {{- if ne $max nil }}
  maxUnavailable: {{ $max }}
  {{- end }}
  {{- if .Values.podDisruptionBudget.unhealthyPodEvictionPolicy }}
  unhealthyPodEvictionPolicy: {{ .Values.podDisruptionBudget.unhealthyPodEvictionPolicy }}
  {{- end }}
{{- end }}
{{- end -}}
