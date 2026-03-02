{{- /*
  HTTPRoute validations - enforce effective hostname availability when enabled.
  Schema handles structure/types; template handles cross-field fallback semantics.
*/ -}}
{{- define "libChart.validation.httproute" -}}
{{- $errors := list -}}
{{- $network := .Values.network | default dict -}}
{{- $httpRoute := $network.httpRoute | default dict -}}
{{- if $httpRoute.enabled }}
  {{- $host := $httpRoute.host | default "" -}}
  {{- $hasLegacyHost := ne $host "" -}}
  {{- $hosts := $httpRoute.hosts | default list -}}
  {{- $hasTopHosts := gt (len $hosts) 0 -}}
  {{- $routes := $httpRoute.routes | default list -}}
  {{- $hasRouteHostnames := false -}}
  {{- range $idx, $route := $routes }}
    {{- if $route.enabled }}
      {{- $routeName := $route.name | default (printf "index-%d" $idx) -}}
      {{- $routeHosts := index $route "hostnames" -}}
      {{- if ne $routeHosts nil }}
        {{- if gt (len $routeHosts) 0 }}
          {{- $hasRouteHostnames = true -}}
        {{- else }}
          {{- $errors = append $errors (printf "network.httpRoute.routes[%s].hostnames must not be empty when set" $routeName) -}}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if not (or $hasLegacyHost $hasTopHosts $hasRouteHostnames) }}
    {{- $errors = append $errors "network.httpRoute requires at least one hostname source when enabled (route.hostnames, httpRoute.hosts, or legacy httpRoute.host)" -}}
  {{- end }}
{{- end }}
{{- join "\n" $errors -}}
{{- end -}}
