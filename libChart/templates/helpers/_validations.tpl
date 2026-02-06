{{- /*
  Validations - orchestrator. Schema owns structure (types, patterns, enums).
  Templates own business logic (conditional requirements, cross-field rules).
*/ -}}
{{- define "libChart.validations" -}}
{{- include "libChart.validation.deployment" . -}}
{{- include "libChart.validation.network" . -}}
{{- include "libChart.validation.security" . -}}
{{- include "libChart.validation.pdb" . -}}
{{- end -}}
