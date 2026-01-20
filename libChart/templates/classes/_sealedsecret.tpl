{{- define "libChart.classes.sealedsecret" -}}
{{- if and .Values.secrets .Values.secrets.sealedSecret .Values.secrets.sealedSecret.enabled .Values.secrets.sealedSecret.items }}
{{- range $name, $secret := .Values.secrets.sealedSecret.items }}
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{ $name }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "common.helpers.metadata.labels" $ | nindent 4 }}
    app.kubernetes.io/component: "sealed-secret"
  {{- if $secret.annotations }}
  annotations:
    {{- range $key, $value := $secret.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
spec:
  encryptedData:
    {{- range $key, $value := $secret.data }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  template:
    metadata:
      name: {{ $name }}
      namespace: {{ .Values.global.namespace | default "default" }}
      {{- if $secret.labels }}
      labels:
        {{- range $key, $value := $secret.labels }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}
      {{- end }}
    type: {{ $secret.type | default "Opaque" }}
{{- end }}
{{- end }}
{{- end -}}
