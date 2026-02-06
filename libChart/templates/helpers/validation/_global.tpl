{{- /*
  Global configuration validations (name, namespace).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.global" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if not $root.Values.global.name -}}
  {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "global.name is required and cannot be empty. Please set 'global.name' to a valid DNS-1123 name (lowercase alphanumeric with dashes).") -}}
{{- else if eq $root.Values.global.name "" -}}
  {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "global.name is required and cannot be empty. Please set 'global.name' to a valid DNS-1123 name (lowercase alphanumeric with dashes).") -}}
{{- else -}}
  {{- if not (include "libChart.validation.dns1123" $root.Values.global.name | trim) -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "global.name '%s' is invalid. Must be DNS-1123 compliant: lowercase letters, numbers, and dashes only, start/end with alphanumeric." $root.Values.global.name)) -}}
  {{- end -}}
  {{- if gt (len $root.Values.global.name) 63 -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "global.name '%s' is too long (%d chars). Maximum length is 63 characters." $root.Values.global.name (len $root.Values.global.name))) -}}
  {{- end -}}
{{- end -}}

{{- if not $root.Values.global.namespace -}}
  {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "global.namespace is required and cannot be empty. Please set 'global.namespace' to a valid Kubernetes namespace name.") -}}
{{- else if eq $root.Values.global.namespace "" -}}
  {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "global.namespace is required and cannot be empty. Please set 'global.namespace' to a valid Kubernetes namespace name.") -}}
{{- end -}}

{{- end -}}
