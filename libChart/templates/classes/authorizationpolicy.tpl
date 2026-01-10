{{- define "libChart.classes.authorizationpolicy" -}}
{{- if and .Values.security .Values.security.authorizationPolicies }}
  {{- range $name, $policy := .Values.security.authorizationPolicies }}
    {{- if $policy }}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ printf "%s-%s" (include "common.helpers.chart.names.name" $) $name }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: authorization-policy
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

