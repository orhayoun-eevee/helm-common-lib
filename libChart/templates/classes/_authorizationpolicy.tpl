{{- define "libChart.classes.authorizationpolicy" -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items }}
{{- range $policyKey, $policy := .Values.network.istio.authorizationPolicy.items }}
{{- if $policy.enabled }}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ include "common.helpers.chart.names.name" $ }}-{{ $policyKey }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "authorization-policy"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  selector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" $ | nindent 6 }}
  {{- if $policy.action }}
  action: {{ $policy.action }}
  {{- else }}
  action: ALLOW
  {{- end }}
  {{- if $policy.rules }}
  rules:
    {{- toYaml $policy.rules | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
