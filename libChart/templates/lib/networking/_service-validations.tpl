{{- /*
  Service validations (ports required when service enabled).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.service" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.network $root.Values.network.services $root.Values.network.services.enabled $root.Values.network.services.items -}}

  {{- range $serviceName, $service := $root.Values.network.services.items -}}
    {{- if $service.enabled -}}

      {{- if not $service.ports -}}
        {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "network.services.items.%s.ports is required when service is enabled. At least one port must be defined." $serviceName)) -}}
      {{- else if eq (len $service.ports) 0 -}}
        {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "network.services.items.%s.ports cannot be empty. At least one port must be defined." $serviceName)) -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}

{{- end -}}

{{- end -}}
