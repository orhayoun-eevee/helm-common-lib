{{- define "libchart.classes.networkpolicy" -}}
{{- if and .Values.security .Values.security.networkPolicy }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: "network-policy"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  podSelector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" . | nindent 6 }}
  {{- $policy := .Values.security.networkPolicy }}
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
{{- end -}}

