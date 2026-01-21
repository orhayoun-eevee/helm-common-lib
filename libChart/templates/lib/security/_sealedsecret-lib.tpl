{{- define "libChart.lib.sealedsecret" -}}
{{- if and .Values.secrets .Values.secrets.enabled .Values.secrets.sealedSecret .Values.secrets.sealedSecret.enabled .Values.secrets.sealedSecret.items }}
{{ include "libChart.classes.sealedsecret" . }}
{{- end }}
{{- end -}}
