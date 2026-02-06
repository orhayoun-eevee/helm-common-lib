{{- /*
  HTTPRoute validations (host, port, gateway).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.httproute" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.network $root.Values.network.httpRoute $root.Values.network.httpRoute.enabled -}}

  {{- if not $root.Values.network.httpRoute.host -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.host is required when HTTPRoute is enabled. Please specify the hostname (e.g., 'app.example.com').") -}}
  {{- else if eq $root.Values.network.httpRoute.host "" -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.host cannot be empty when HTTPRoute is enabled.") -}}
  {{- end -}}

  {{- if not $root.Values.network.httpRoute.port -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.port is required when HTTPRoute is enabled. Please specify the service port number.") -}}
  {{- end -}}

  {{- if not $root.Values.network.httpRoute.gateway -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.gateway is required when HTTPRoute is enabled. Please specify gateway.name and gateway.namespace.") -}}
  {{- else -}}
    {{- if not $root.Values.network.httpRoute.gateway.name -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.gateway.name is required when HTTPRoute is enabled. Please specify the Gateway name.") -}}
    {{- else if eq $root.Values.network.httpRoute.gateway.name "" -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.gateway.name cannot be empty when HTTPRoute is enabled.") -}}
    {{- end -}}
    {{- if not $root.Values.network.httpRoute.gateway.namespace -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.gateway.namespace is required when HTTPRoute is enabled. Please specify the Gateway namespace.") -}}
    {{- else if eq $root.Values.network.httpRoute.gateway.namespace "" -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.httpRoute.gateway.namespace cannot be empty when HTTPRoute is enabled.") -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{- end -}}
