{{- /*
  Kubernetes quantity format validation (e.g. 1Gi, 100Mi).
  Usage: include "libChart.validation.size" "1Gi"
  Outputs "true" if valid, empty otherwise.
*/ -}}
{{- define "libChart.validation.size" -}}
{{- if and . (regexMatch "^[0-9]+(Ei|Pi|Ti|Gi|Mi|Ki|E|P|T|G|M|K)$" (toString .)) }}true{{- end -}}
{{- end -}}
