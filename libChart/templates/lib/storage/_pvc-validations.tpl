{{- /*
  PVC validations (size, storageClass) using libChart.validation.size helper.
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.pvc" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.persistence $root.Values.persistence.enabled $root.Values.persistence.claims -}}

  {{- range $claimName, $claim := $root.Values.persistence.claims -}}

    {{- if not $claim.size -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "persistence.claims.%s.size is required. Please specify storage size (e.g., '1Gi', '10Gi', '100Mi')." $claimName)) -}}
    {{- else if eq $claim.size "" -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "persistence.claims.%s.size cannot be empty." $claimName)) -}}
    {{- else if not (include "libChart.validation.size" $claim.size | trim) -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "persistence.claims.%s.size '%s' is invalid. Must match pattern: <number><unit> (e.g., '1Gi', '100Mi')." $claimName $claim.size)) -}}
    {{- end -}}

    {{- if not $claim.storageClass -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "persistence.claims.%s.storageClass is required. Please specify the storage class name." $claimName)) -}}
    {{- else if eq $claim.storageClass "" -}}
      {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "persistence.claims.%s.storageClass cannot be empty." $claimName)) -}}
    {{- end -}}

  {{- end -}}

{{- end -}}

{{- end -}}
