{{- /*
  Istio DestinationRule validations (host required).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.destinationrule" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.network $root.Values.network.istio $root.Values.network.istio.enabled $root.Values.network.istio.destinationrule $root.Values.network.istio.destinationrule.enabled -}}

  {{- if not $root.Values.network.istio.destinationrule.host -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.istio.destinationrule.host is required when DestinationRule is enabled. Please specify the destination service hostname (e.g., 'service-name.namespace.svc.cluster.local').") -}}
  {{- else if eq $root.Values.network.istio.destinationrule.host "" -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "network.istio.destinationrule.host cannot be empty when DestinationRule is enabled.") -}}
  {{- end -}}

{{- end -}}

{{- end -}}
