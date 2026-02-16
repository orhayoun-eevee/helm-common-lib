{{- define "libChart.classes.networkpolicy" -}}
{{- if and .Values.network .Values.network.networkPolicy .Values.network.networkPolicy.items }}
{{- $items := .Values.network.networkPolicy.items -}}
{{- range $policyKey := (keys $items | sortAlpha) }}
{{- $policy := index $items $policyKey }}
{{- if $policy.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "libChart.name" $ }}-{{ $policyKey }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "network-policy") | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "libChart.selectorLabels" $ | nindent 6 }}
  {{- if $policy.policyTypes }}
  policyTypes:
    {{- toYaml $policy.policyTypes | nindent 4 }}
  {{- end }}
  {{- if $policy.ingress }}
  ingress:
    {{- toYaml $policy.ingress | nindent 4 }}
  {{- end }}
  {{- if $policy.egress }}
  egress:
    {{- toYaml $policy.egress | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
