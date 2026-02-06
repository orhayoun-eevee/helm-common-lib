{{- /*
  Deployment validations - business logic only (schema handles types/format).
  NOTE: "$_ := required 'msg' value" is used so we get fail-fast validation without emitting output;
  "required" returns the value when non-empty; assigning to $_ discards it and suppresses template output.
*/ -}}
{{- define "libChart.validation.deployment" -}}
{{- $enabledList := list }}
{{- range $name, $container := .Values.deployment.containers }}
  {{- if $container.enabled }}
    {{- $enabledList = append $enabledList 1 }}
    {{- /* guard: image map must exist before checking sub-keys with required */ -}}
    {{- if not $container.image }}
      {{- fail (printf "deployment.containers.%s.image is required" $name) }}
    {{- end }}
    {{- $_ := required (printf "deployment.containers.%s.image.repository is required" $name) $container.image.repository -}}
    {{- $_ := required (printf "deployment.containers.%s.image.tag is required" $name) $container.image.tag -}}
  {{- end }}
{{- end }}
{{- if eq (len $enabledList) 0 }}
  {{- fail "deployment.containers must have at least one enabled container" }}
{{- end }}
{{- end -}}
