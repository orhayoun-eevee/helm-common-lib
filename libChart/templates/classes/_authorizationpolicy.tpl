{{- define "libChart.classes.authorizationPolicy" -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items }}
{{- $items := .Values.network.istio.authorizationPolicy.items -}}
{{- range $policyKey := (keys $items | sortAlpha) }}
{{- $policy := index $items $policyKey }}
{{- if $policy.enabled }}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ include "libChart.name" $ }}-{{ $policyKey }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "authorization-policy") | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "libChart.selectorLabels" $ | nindent 6 }}
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
