{{- define "libChart.group.workload" -}}

{{ include "libChart.lib.serviceaccount" . }}

{{ include "libChart.lib.deployment" . }}

{{ include "libChart.lib.pdb" . }}

{{- end -}}

{{- define "libChart.group.networking" -}}

{{ include "libChart.lib.service" . }}

{{ include "libChart.lib.httproute" . }}

{{ include "libChart.lib.networkpolicy" . }}

{{ include "libChart.lib.istio" . }}

{{- end -}}

{{- define "libChart.group.observability" -}}

{{ include "libChart.lib.prometheus" . }}

{{ include "libChart.lib.grafana" . }}

{{- end -}}

{{- define "libChart.group.storage" -}}

{{ include "libChart.lib.pvc" . }}

{{- end -}}

{{- define "libChart.group.security" -}}

{{ include "libChart.lib.sealedsecret" . }}

{{- end -}}
