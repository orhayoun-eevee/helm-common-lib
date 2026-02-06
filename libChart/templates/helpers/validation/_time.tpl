{{- /*
  Time duration format validation (e.g. 10s, 1m).
  Usage: include "libChart.validation.duration" "10s"
  Outputs "true" if valid, empty otherwise.
*/ -}}
{{- define "libChart.validation.duration" -}}
{{- if and . (regexMatch "^[0-9]+(ms|s|m|h)$" (toString .)) }}true{{- end -}}
{{- end -}}
