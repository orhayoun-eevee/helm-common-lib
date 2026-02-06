{{- /*
  SealedSecret validations (data required per item).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.sealedsecret" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.secrets $root.Values.secrets.enabled $root.Values.secrets.sealedSecret $root.Values.secrets.sealedSecret.enabled $root.Values.secrets.sealedSecret.items -}}

  {{- range $secretName, $secret := $root.Values.secrets.sealedSecret.items -}}

    {{- if not $secret.data -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "secrets.sealedSecret.items.%s.data is required. Please provide sealed secret data." $secretName)) -}}
    {{- else if eq (len $secret.data) 0 -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "secrets.sealedSecret.items.%s.data cannot be empty. At least one key-value pair must be defined." $secretName)) -}}
    {{- end -}}

  {{- end -}}

{{- end -}}

{{- end -}}
