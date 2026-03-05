{{- /*
  Workload validations:
  - workload.type selection and type-specific container checks
  - CronJob schedule/timeZone compatibility
  - Deployment-only feature guards when workload.type=cronJob
*/ -}}
{{- define "libChart.validation.workload" -}}
{{- $errors := list -}}
{{- $workload := .Values.workload | default dict -}}
{{- $kind := $workload.type | default "" -}}

{{- if not $kind }}
  {{- $errors = append $errors "workload.type is required and must be one of: deployment, cronJob" -}}
{{- end }}

{{- if eq $kind "cronJob" }}
  {{- $spec := .Values.workload.spec | default dict -}}
  {{- $schedule := $spec.schedule | default "" -}}
  {{- if not $schedule }}
    {{- $errors = append $errors "workload.spec.schedule is required when workload.type=cronJob" -}}
  {{- end }}
  {{- if regexMatch "(^|\\s)(TZ|CRON_TZ)=" $schedule }}
    {{- $errors = append $errors "workload.spec.schedule must not use TZ/CRON_TZ; use workload.spec.timeZone instead" -}}
  {{- end }}
  {{- if and $spec.timeZone (not (semverCompare ">=1.27.0-0" .Capabilities.KubeVersion.Version)) }}
    {{- $errors = append $errors (printf "workload.spec.timeZone requires Kubernetes >= 1.27 (detected %s)" .Capabilities.KubeVersion.Version) -}}
  {{- end }}

  {{- $containers := $spec.containers | default dict -}}
  {{- $hasEnabled := false -}}
  {{- range $name := (keys $containers | sortAlpha) }}
    {{- $container := index $containers $name }}
    {{- if $container.enabled }}{{- $hasEnabled = true }}{{- end }}
  {{- end }}
  {{- if not $hasEnabled }}
    {{- $errors = append $errors "workload.spec.containers must have at least one enabled container when workload.type=cronJob" -}}
  {{- end }}

  {{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled }}
    {{- $errors = append $errors "podDisruptionBudget.enabled is only supported when workload.type=deployment" -}}
  {{- end }}

  {{- $hasServices := false -}}
  {{- if and .Values.network .Values.network.services .Values.network.services.items }}
    {{- $serviceItems := .Values.network.services.items -}}
    {{- range $serviceKey := (keys $serviceItems | sortAlpha) }}
      {{- $service := index $serviceItems $serviceKey }}
      {{- if $service.enabled }}{{- $hasServices = true }}{{- end }}
    {{- end }}
  {{- end }}
  {{- if $hasServices }}
    {{- $errors = append $errors "network.services.items.*.enabled is only supported when workload.type=deployment" -}}
  {{- end }}

  {{- if and .Values.network .Values.network.httpRoute .Values.network.httpRoute.enabled }}
    {{- $errors = append $errors "network.httpRoute.enabled is only supported when workload.type=deployment" -}}
  {{- end }}

  {{- if and .Values.metrics .Values.metrics.enabled .Values.metrics.serviceMonitor .Values.metrics.serviceMonitor.enabled }}
    {{- $errors = append $errors "metrics.serviceMonitor.enabled is only supported when workload.type=deployment" -}}
  {{- end }}

  {{- $hasIstioAuthz := false -}}
  {{- if and .Values.network .Values.network.istio .Values.network.istio.enabled .Values.network.istio.authorizationPolicy .Values.network.istio.authorizationPolicy.enabled .Values.network.istio.authorizationPolicy.items }}
    {{- $authzItems := .Values.network.istio.authorizationPolicy.items -}}
    {{- range $key := (keys $authzItems | sortAlpha) }}
      {{- $item := index $authzItems $key }}
      {{- if $item.enabled }}{{- $hasIstioAuthz = true }}{{- end }}
    {{- end }}
  {{- end }}
  {{- if $hasIstioAuthz }}
    {{- $errors = append $errors "network.istio.authorizationPolicy.items.*.enabled is only supported when workload.type=deployment" -}}
  {{- end }}

  {{- if and .Values.network .Values.network.istio .Values.network.istio.enabled .Values.network.istio.destinationRule .Values.network.istio.destinationRule.enabled }}
    {{- $errors = append $errors "network.istio.destinationRule.enabled is only supported when workload.type=deployment" -}}
  {{- end }}
{{- end }}

{{- join "\n" $errors -}}
{{- end -}}
