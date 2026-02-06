{{- /*
  Network validations - HTTPRoute, Service, DestinationRule (business logic only; schema handles format).
  Uses | default dict + intermediate variables for safe nil traversal and clarity.
  NOTE: "$_ := required 'msg' value" discards the return value so we get fail-fast validation without output.
*/ -}}
{{- define "libChart.validation.network" -}}
{{- $net := .Values.network | default dict }}

{{- /* HTTPRoute: when enabled, host, port, gateway.name, gateway.namespace required */ -}}
{{- $httpRoute := $net.httpRoute | default dict }}
{{- if $httpRoute.enabled }}
  {{- $_ := required "network.httpRoute.host is required when HTTPRoute is enabled" $httpRoute.host -}}
  {{- $_ := required "network.httpRoute.port is required when HTTPRoute is enabled" $httpRoute.port -}}
  {{- $gw := $httpRoute.gateway | default dict }}
  {{- $_ := required "network.httpRoute.gateway.name is required when HTTPRoute is enabled" $gw.name -}}
  {{- $_ := required "network.httpRoute.gateway.namespace is required when HTTPRoute is enabled" $gw.namespace -}}
{{- end }}

{{- /* Service: when enabled, must have ports; individual port properties (port, protocol) are enforced by JSON schema */ -}}
{{- $svcItems := ($net.services | default dict).items | default dict }}
{{- range $name, $service := $svcItems }}
  {{- if $service.enabled }}
    {{- $ports := $service.ports | default dict }}
    {{- if not $ports }}
      {{- fail (printf "network.services.items.%s.ports is required when service is enabled" $name) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- /* DestinationRule: when enabled, host required */ -}}
{{- $istio := $net.istio | default dict }}
{{- $dr := $istio.destinationrule | default dict }}
{{- if $dr.enabled }}
  {{- $_ := required "network.istio.destinationrule.host is required when DestinationRule is enabled" $dr.host -}}
{{- end }}

{{- end -}}
