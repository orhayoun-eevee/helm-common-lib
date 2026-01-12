{{- define "libChart.all" -}}
{{- if and .Values.deployment .Values.deployment.containers -}}
  {{- include "libChart.classes.deployment" . -}}
{{- end -}}
{{- if and .Values.network.services .Values.network.services.items -}}
  {{- include "libChart.classes.service" . -}}
{{- end -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create -}}
  {{- include "libChart.classes.serviceaccount" . -}}
{{- end -}}
{{- if and .Values.persistence .Values.persistence.enabled .Values.persistence.claims -}}
  {{- include "libChart.classes.pvc" . -}}
{{- end -}}
{{- if and .Values.security .Values.security.networkPolicy -}}
  {{- include "libChart.classes.networkpolicy" . -}}
{{- end -}}
{{- if and .Values.security .Values.security.authorizationPolicies -}}
  {{- include "libChart.classes.authorizationpolicy" . -}}
{{- end -}}
{{- if and .Values.httpRoute .Values.httpRoute.enabled -}}
  {{- include "libChart.classes.httproute" . -}}
{{- end -}}
{{- if and .Values.circuitBreaker .Values.circuitBreaker.enabled -}}
  {{- include "libChart.classes.destinationrule" . -}}
{{- end -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled -}}
  {{- include "libChart.classes.poddisruptionbudget" . -}}
{{- end -}}
{{- if and .Values.metrics .Values.metrics.enabled -}}
  {{- include "libChart.classes.servicemonitor" . -}}
  {{- if .Values.metrics.rules -}}
    {{- include "libChart.classes.prometheusrule" . -}}
  {{- end -}}
{{- end -}}
{{- end -}}

