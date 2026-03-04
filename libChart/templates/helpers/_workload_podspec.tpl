{{- /*
Workload strategy dispatcher.
Concrete rendering stays in classes/_deployment.tpl and classes/_cronjob.tpl.
*/ -}}
{{- define "libChart.workload.render" -}}
{{- if eq .Values.workload.type "deployment" }}
{{ include "libChart.classes.deployment" . }}
{{- else if eq .Values.workload.type "cronJob" }}
{{ include "libChart.classes.cronjob" . }}
{{- end }}
{{- end -}}
