{{- /*
Workload strategy dispatcher.
Concrete rendering stays in classes/_deployment.tpl and classes/_cronjob.tpl.
*/ -}}
{{- define "libChart.workload.render" -}}
{{- $ctx := include "libChart.workload.buildContext" . | fromYaml -}}
{{- $strategies := dict
      "deployment" "libChart.classes.deployment"
      "cronJob" "libChart.classes.cronjob"
-}}
{{- $renderer := index $strategies $ctx.type -}}
{{- if not $renderer }}
  {{- fail (printf "workload.type %q is not supported by renderer registry" $ctx.type) -}}
{{- end }}
{{ include $renderer (dict "root" . "ctx" $ctx) }}
{{- end -}}

{{- define "libChart.workload.buildContext" -}}
{{- $workload := .Values.workload | default dict -}}
{{- $ctx := dict
      "type" ($workload.type | default "")
      "spec" ($workload.spec | default dict)
-}}
{{- toYaml $ctx -}}
{{- end -}}

{{/*
Render shared pod spec fields for deployment/cronjob workloads.
Call with: include "libChart.workload.podSpecCommon" (dict "root" $ "spec" .ctx.spec)
*/}}
{{- define "libChart.workload.podSpecCommon" -}}
{{- $root := .root -}}
{{- $spec := .spec | default dict -}}
{{- if $spec.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml $spec.imagePullSecrets | nindent 2 }}
{{- end }}
{{- if ne (index $spec "terminationGracePeriodSeconds") nil }}
terminationGracePeriodSeconds: {{ index $spec "terminationGracePeriodSeconds" }}
{{- end }}
{{- if $spec.podSecurityContext }}
securityContext:
  {{- toYaml $spec.podSecurityContext | nindent 2 }}
{{- end }}
{{- if and $root.Values.serviceAccount $root.Values.serviceAccount.name }}
serviceAccountName: {{ $root.Values.serviceAccount.name }}
{{- else if and $root.Values.serviceAccount $root.Values.serviceAccount.create }}
serviceAccountName: {{ include "libChart.name" $root }}
{{- end }}
{{- if $spec.affinity }}
affinity:
  {{- toYaml $spec.affinity | nindent 2 }}
{{- end }}
{{- if $spec.tolerations }}
tolerations:
  {{- toYaml $spec.tolerations | nindent 2 }}
{{- end }}
{{- if $spec.nodeSelector }}
nodeSelector:
  {{- toYaml $spec.nodeSelector | nindent 2 }}
{{- end }}
{{- if $spec.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml $spec.topologySpreadConstraints | nindent 2 }}
{{- end }}
{{- if ne $spec.hostNetwork nil }}
hostNetwork: {{ $spec.hostNetwork }}
{{- end }}
{{- if $spec.dnsPolicy }}
dnsPolicy: {{ $spec.dnsPolicy }}
{{- else if $spec.hostNetwork }}
dnsPolicy: ClusterFirstWithHostNet
{{- end }}
{{- if ne $spec.automountServiceAccountToken nil }}
automountServiceAccountToken: {{ $spec.automountServiceAccountToken }}
{{- end }}
{{- if ne $spec.enableServiceLinks nil }}
enableServiceLinks: {{ $spec.enableServiceLinks }}
{{- end }}
{{- end -}}
