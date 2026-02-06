{{- /*
  ServiceMonitor validations (port, interval, scrapeTimeout) using validation helpers.
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.servicemonitor" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.metrics $root.Values.metrics.enabled $root.Values.metrics.serviceMonitor $root.Values.metrics.serviceMonitor.enabled -}}

  {{- if not $root.Values.metrics.serviceMonitor.port -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "metrics.serviceMonitor.port is required when ServiceMonitor is enabled. Please specify the metrics port number.") -}}
  {{- else -}}
    {{- $port := $root.Values.metrics.serviceMonitor.port | int -}}
    {{- if not (include "libChart.validation.port" $port | trim) -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "metrics.serviceMonitor.port must be between 1 and 65535, got %d" $port)) -}}
    {{- end -}}
  {{- end -}}

  {{- if $root.Values.metrics.serviceMonitor.interval -}}
    {{- if not (include "libChart.validation.duration" $root.Values.metrics.serviceMonitor.interval | trim) -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "metrics.serviceMonitor.interval '%s' is invalid. Must match pattern: <number><unit> (e.g., '10s', '1m')." $root.Values.metrics.serviceMonitor.interval)) -}}
    {{- end -}}
  {{- end -}}

  {{- if $root.Values.metrics.serviceMonitor.scrapeTimeout -}}
    {{- if not (include "libChart.validation.duration" $root.Values.metrics.serviceMonitor.scrapeTimeout | trim) -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "metrics.serviceMonitor.scrapeTimeout '%s' is invalid. Must match pattern: <number><unit> (e.g., '5s', '30s')." $root.Values.metrics.serviceMonitor.scrapeTimeout)) -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{- end -}}
