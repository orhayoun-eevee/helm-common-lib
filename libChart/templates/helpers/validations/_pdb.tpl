{{- /*
  PDB validations - minAvailable and maxUnavailable are mutually exclusive; one required when enabled.
  Uses index + ne nil to reliably detect user-set values (vs YAML null/default).
*/ -}}
{{- define "libChart.validation.pdb" -}}
{{- $pdb := .Values.podDisruptionBudget | default dict }}
{{- if $pdb.enabled }}
  {{- /* index + ne nil: required to distinguish "not set" (null) from 0 -- not suitable for | default dict */ -}}
  {{- $min := index $pdb "minAvailable" }}
  {{- $max := index $pdb "maxUnavailable" }}
  {{- $hasMin := ne $min nil }}
  {{- $hasMax := ne $max nil }}

  {{- if and $hasMin $hasMax }}
    {{- fail "podDisruptionBudget.minAvailable and maxUnavailable are mutually exclusive (set only one)" }}
  {{- end }}

  {{- if not (or $hasMin $hasMax) }}
    {{- fail "podDisruptionBudget requires either minAvailable or maxUnavailable when enabled" }}
  {{- end }}
{{- end }}
{{- end -}}
