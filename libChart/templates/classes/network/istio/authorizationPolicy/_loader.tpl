{{- define "common.class.network.istio.authorizationPolicy" -}}
    {{ range $name, $policy := . -}}
        {{- if $policy.enabled -}}
            {{- include "common.class.network.istio.RenderAuthorizationPolicy"  (dict "name" $name "policy" $policy) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}