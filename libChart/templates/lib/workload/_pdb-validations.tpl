{{- /*
  PodDisruptionBudget validations (minAvailable / maxUnavailable mutual exclusivity).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.pdb" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if and $root.Values.podDisruptionBudget $root.Values.podDisruptionBudget.enabled -}}

  {{- $hasMinAvailable := ne $root.Values.podDisruptionBudget.minAvailable nil -}}
  {{- $hasMaxUnavailable := ne $root.Values.podDisruptionBudget.maxUnavailable nil -}}

  {{- if and $hasMinAvailable $hasMaxUnavailable -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "podDisruptionBudget.minAvailable and podDisruptionBudget.maxUnavailable are mutually exclusive. Please specify only one.") -}}
  {{- end -}}

  {{- if not (or $hasMinAvailable $hasMaxUnavailable) -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "podDisruptionBudget requires either 'minAvailable' or 'maxUnavailable' to be set when enabled.") -}}
  {{- end -}}

{{- end -}}

{{- end -}}
