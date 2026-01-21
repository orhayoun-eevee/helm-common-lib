{{- define "libChart.lib.istio" -}}
{{- if and .Values.network .Values.network.istio .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items }}
{{ include "libChart.classes.authorizationpolicy" . }}
{{- end }}
{{- if and .Values.network .Values.network.istio .Values.network.istio.destinationrule .Values.network.istio.destinationrule.enabled }}
{{ include "libChart.classes.destinationrule" . }}
{{- end }}
{{- end -}}
