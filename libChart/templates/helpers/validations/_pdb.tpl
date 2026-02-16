{{- /*
  PDB validations - minAvailable and maxUnavailable are mutually exclusive; one required when enabled.
  Uses index + ne nil to reliably detect user-set values (vs YAML null/default).
  Returns error messages as newline-delimited string (empty string if valid).
  Schema cross-ref: values.schema.json -> $.properties.podDisruptionBudget (oneOf)
*/ -}}
{{- define "libChart.validation.pdb" -}}
{{- $errors := list -}}
{{- $pdb := .Values.podDisruptionBudget | default dict }}
{{- if $pdb.enabled }}
  {{- /* index + ne nil: Go templates treat 0, false, "", and nil as "empty" in conditionals and | default.
       "| default" would silently replace minAvailable:0 with the default, losing the user's intent.
       index returns nil for absent keys, so "ne nil" reliably means "user explicitly set this value".
       Ref: https://pkg.go.dev/text/template#hdr-Actions (empty values definition) */ -}}
  {{- $min := index $pdb "minAvailable" }}
  {{- $max := index $pdb "maxUnavailable" }}
  {{- $hasMin := ne $min nil }}
  {{- $hasMax := ne $max nil }}

  {{- if and $hasMin $hasMax }}
    {{- $errors = append $errors "podDisruptionBudget.minAvailable and maxUnavailable are mutually exclusive (set only one)" -}}
  {{- end }}

  {{- if not (or $hasMin $hasMax) }}
    {{- $errors = append $errors "podDisruptionBudget requires either minAvailable or maxUnavailable when enabled" -}}
  {{- end }}
{{- end }}
{{- join "\n" $errors -}}
{{- end -}}
