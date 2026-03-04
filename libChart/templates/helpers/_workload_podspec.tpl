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

{{/*
Render shared pod spec fields for deployment/cronjob workloads.
Call with: include "libChart.workload.podSpecCommon" (dict "root" $ "cfg" .Values.deployment)
*/}}
{{- define "libChart.workload.podSpecCommon" -}}
{{- $root := .root -}}
{{- $cfg := .cfg | default dict -}}
{{- if $cfg.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml $cfg.imagePullSecrets | nindent 2 }}
{{- end }}
{{- if ne (index $cfg "terminationGracePeriodSeconds") nil }}
terminationGracePeriodSeconds: {{ index $cfg "terminationGracePeriodSeconds" }}
{{- end }}
{{- if $cfg.podSecurityContext }}
securityContext:
  {{- toYaml $cfg.podSecurityContext | nindent 2 }}
{{- end }}
{{- if and $root.Values.serviceAccount $root.Values.serviceAccount.name }}
serviceAccountName: {{ $root.Values.serviceAccount.name }}
{{- else if and $root.Values.serviceAccount $root.Values.serviceAccount.create }}
serviceAccountName: {{ include "libChart.name" $root }}
{{- end }}
{{- if $cfg.affinity }}
affinity:
  {{- toYaml $cfg.affinity | nindent 2 }}
{{- end }}
{{- if $cfg.tolerations }}
tolerations:
  {{- toYaml $cfg.tolerations | nindent 2 }}
{{- end }}
{{- if $cfg.nodeSelector }}
nodeSelector:
  {{- toYaml $cfg.nodeSelector | nindent 2 }}
{{- end }}
{{- if $cfg.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml $cfg.topologySpreadConstraints | nindent 2 }}
{{- end }}
{{- if ne $cfg.hostNetwork nil }}
hostNetwork: {{ $cfg.hostNetwork }}
{{- end }}
{{- if $cfg.dnsPolicy }}
dnsPolicy: {{ $cfg.dnsPolicy }}
{{- else if $cfg.hostNetwork }}
dnsPolicy: ClusterFirstWithHostNet
{{- end }}
{{- if ne $cfg.automountServiceAccountToken nil }}
automountServiceAccountToken: {{ $cfg.automountServiceAccountToken }}
{{- end }}
{{- if ne $cfg.enableServiceLinks nil }}
enableServiceLinks: {{ $cfg.enableServiceLinks }}
{{- end }}
{{- end -}}
