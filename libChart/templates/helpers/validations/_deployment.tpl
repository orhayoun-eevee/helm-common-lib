{{- /*
  Deployment validations - business logic only (schema handles types/format/conditional-required).
  Returns error messages as newline-delimited string (empty string if valid).
  Schema cross-ref: values.schema.json -> $.properties.deployment.properties.containers

  Schema enforces: container names (DNS-1123), required image object with repository/tag (minLength 1),
                   port ranges, at least one container defined (minProperties: 1).
  Template enforces: at least one enabled container (requires iteration over dynamic map keys).
*/ -}}
{{- define "libChart.validation.deployment" -}}
{{- $errors := list -}}
{{- if ne .Values.workload.type "deployment" }}
  {{- join "\n" $errors -}}
{{- else -}}
{{- $spec := .Values.workload.spec | default dict }}
{{- $containers := $spec.containers | default dict }}
{{- $hasEnabled := false }}
{{- range $name := (keys $containers | sortAlpha) }}
  {{- $container := index $containers $name }}
  {{- if $container.enabled }}{{- $hasEnabled = true }}{{- end }}
{{- end }}
{{- if not $hasEnabled }}
  {{- $errors = append $errors "workload.spec.containers must have at least one enabled container for workload.type=deployment" -}}
{{- end }}
{{- join "\n" $errors -}}
{{- end -}}
{{- end -}}
