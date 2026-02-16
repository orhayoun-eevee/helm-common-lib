{{- /*
  Validations - orchestrator. Schema owns structure (types, patterns, enums, conditional-required).
  Templates own business logic that schema cannot express (iteration, zero-value awareness, complex cross-field rules).
  Error aggregation: Each domain returns errors as strings; orchestrator collects and emits all at once.

  Design choice: We use fail() with error aggregation instead of Helm's built-in
  required() function. required() stops at the first missing value; our approach
  collects ALL errors and reports them together, so users can fix everything in
  one pass.
  Ref: https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-required-function

  Pattern notes:
    - "index $map key" + "ne nil" detects presence without treating 0 as empty (preserves explicit zero values).
    - "keys $map | sortAlpha" ensures deterministic map iteration (Go map order is unspecified).
*/ -}}
{{- define "libChart.validations" -}}
{{- $errors := list -}}
{{- $validators := list
    "libChart.validation.deployment"
    "libChart.validation.pdb"
-}}
{{- range $v := $validators }}
  {{- $e := include $v $ -}}
  {{- if $e }}{{- $errors = append $errors $e -}}{{- end -}}
{{- end -}}
{{- if $errors }}
  {{- fail (join "\n" $errors) -}}
{{- end -}}
{{- end -}}
