{{- define "common.class.network.networkPolicy" -}}
  {{- range $name, $policy := . }}
    {{- /* TODO: validate policy is not null */ -}}
    {{- if $policy.enabled -}}
      {{- /* TODO: Add validations before rendering network policy */ -}}
      {{- include "common.class.network.RenderNetworkPolicy"  (dict "name" $name "policy" $policy) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

