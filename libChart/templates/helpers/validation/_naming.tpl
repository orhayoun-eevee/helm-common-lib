{{- /*
  DNS-1123 naming validation helper.
  Usage: include "libChart.validation.dns1123" "my-name"
  Outputs "true" if valid, empty otherwise.
*/ -}}
{{- define "libChart.validation.dns1123" -}}
{{- if and . (regexMatch "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$" (toString .)) }}true{{- end -}}
{{- end -}}
