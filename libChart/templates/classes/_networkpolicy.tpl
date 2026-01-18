{{- define "libChart.classes.networkpolicy" -}}
{{- if and .Values.network .Values.network.networkPolicy .Values.network.networkPolicy.items }}
{{- range $policyKey, $policy := .Values.network.networkPolicy.items }}
{{- if $policy.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "common.helpers.chart.names.name" $ }}-{{ $policyKey }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "network-policy"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  podSelector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" $ | nindent 6 }}
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
