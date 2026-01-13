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
{{- if and .Values.network .Values.network.networkPolicy .Values.network.networkPolicy.items -}}
  {{- include "libChart.classes.networkpolicy" . -}}
{{- end -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items -}}
  {{- include "libChart.classes.authorizationpolicy" . -}}
{{- end -}}
{{- if and .Values.network.httpRoute .Values.network.httpRoute.enabled -}}
  {{- include "libChart.classes.httproute" . -}}
{{- end -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.destinationrule .Values.network.istio.destinationrule.enabled -}}
  {{- include "libChart.classes.destinationrule" . -}}
{{- end -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled -}}
  {{- include "libChart.classes.poddisruptionbudget" . -}}
{{- end -}}
{{- if and .Values.metrics .Values.metrics.enabled -}}
  {{- include "libChart.classes.servicemonitor" . -}}
  {{- if and .Values.metrics.prometheusRule .Values.metrics.prometheusRule.rules -}}
    {{- include "libChart.classes.prometheusrule" . -}}
  {{- end -}}
  {{- if and .Values.metrics.grafana .Values.metrics.grafana.enabled -}}
    {{- include "libChart.classes.grafana" . -}}
  {{- end -}}
{{- end -}}
{{- end -}}

