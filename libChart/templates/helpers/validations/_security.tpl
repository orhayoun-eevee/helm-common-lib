{{- /*
  Security validations - SealedSecret items must have non-empty data.
  Schema requires the data key; template enforces it is not empty (minProperties also added to schema).
*/ -}}
{{- define "libChart.validation.security" -}}
{{- $secrets := .Values.secrets | default dict }}
{{- $ss := $secrets.sealedSecret | default dict }}
{{- if and $secrets.enabled $ss.enabled $ss.items }}
  {{- range $name, $secret := $ss.items }}
    {{- if not $secret.data }}
      {{- fail (printf "secrets.sealedSecret.items.%s.data is required and must not be empty" $name) }}
    {{- end }}
    {{- range $key, $val := $secret.data }}
      {{- if not $val }}
        {{- fail (printf "secrets.sealedSecret.items.%s.data.%s must not be empty" $name $key) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
