{{- define "common.class.network.istio" -}}
    {{/* TODO: authorizationPolicy */}}
    {{- if and .authorizationPolicies .authorizationPolicies.enabled -}}
        {{- include "common.class.network.istio.authorizationPolicy"  .authorizationPolicies.policies -}}
    {{- end -}}

    {{- /* TODO: circuitBreaker */ -}}
    {{- /* TODO: DestinationRule */ -}}
{{- end -}}