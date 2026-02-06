{{- /*
  Validation orchestrator: runs all validations and emits warnings.
  Context: scratch.errors is a list; each validation appends to it.
  
  NOTE: Currently in WARNING-ONLY mode (non-breaking).
  Validations emit YAML comments instead of failing.
  TODO: In a future version, change to fail-fast mode.
*/ -}}
{{- define "libChart.validations.run" -}}
{{- $scratch := dict "errors" (list) -}}
{{- $ctx := dict "root" . "scratch" $scratch -}}

{{- include "libChart.validations.global" $ctx -}}
{{- include "libChart.validations.deployment" $ctx -}}
{{- include "libChart.validations.httproute" $ctx -}}
{{- include "libChart.validations.service" $ctx -}}
{{- include "libChart.validations.destinationrule" $ctx -}}
{{- include "libChart.validations.pvc" $ctx -}}
{{- include "libChart.validations.servicemonitor" $ctx -}}
{{- include "libChart.validations.sealedsecret" $ctx -}}
{{- include "libChart.validations.pdb" $ctx -}}

{{- if $scratch.errors -}}
# ==========================================
# ⚠️  VALIDATION WARNINGS (Non-Breaking)
# ==========================================
# The following validation issues were detected.
# These are currently WARNINGS ONLY and will not prevent deployment.
# In a future version, these will become blocking errors.
# Please fix these issues to ensure compatibility with future releases.
#
{{- range $scratch.errors }}
# - {{ . }}
{{- end }}
# ==========================================
{{- end -}}
{{- end -}}
