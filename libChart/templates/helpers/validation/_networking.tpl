{{- /*
  Port range validation helper (1-65535).
  Usage: include "libChart.validation.port" 8080
  Outputs "true" if valid, empty otherwise.
*/ -}}
{{- define "libChart.validation.port" -}}
{{- $p := . | int -}}
{{- if and (ge $p 1) (le $p 65535) }}true{{- end -}}
{{- end -}}
