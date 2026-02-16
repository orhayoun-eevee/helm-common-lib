{{- define "libChart.group.workload" -}}

{{ include "libChart.classes.serviceaccount" . }}

{{ include "libChart.classes.configmap" . }}

{{ include "libChart.classes.deployment" . }}

{{ include "libChart.classes.poddisruptionbudget" . }}

{{- end -}}

{{- define "libChart.group.networking" -}}
{{- if and .Values.network .Values.network.enabled }}

{{ include "libChart.classes.service" . }}

{{ include "libChart.classes.httproute" . }}

{{ include "libChart.classes.networkpolicy" . }}

{{- if and .Values.network.istio .Values.network.istio.enabled }}
  {{- if and .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items }}
{{ include "libChart.classes.authorizationPolicy" . }}
  {{- end }}
  {{- if and .Values.network.istio.destinationRule .Values.network.istio.destinationRule.enabled }}
{{ include "libChart.classes.destinationRule" . }}
  {{- end }}
{{- end }}

{{- end }}
{{- end -}}

{{- define "libChart.group.observability" -}}
{{- if and .Values.metrics .Values.metrics.enabled }}
  {{- if and .Values.metrics.serviceMonitor .Values.metrics.serviceMonitor.enabled }}
{{ include "libChart.classes.servicemonitor" . }}
  {{- end }}
  {{- if and .Values.metrics.prometheusRule .Values.metrics.prometheusRule.enabled .Values.metrics.prometheusRule.rules }}
{{ include "libChart.classes.prometheusrule" . }}
  {{- end }}
{{ include "libChart.grafanaDashboard" . }}
{{- end }}
{{- end -}}

{{- define "libChart.group.storage" -}}

{{ include "libChart.classes.pvc" . }}

{{- end -}}

{{- define "libChart.group.security" -}}

{{ include "libChart.classes.sealedsecret" . }}

{{- end -}}
