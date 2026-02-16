{{- define "libChart.classes.sealedsecret" -}}
{{- if and .Values.secrets .Values.secrets.sealedSecret .Values.secrets.sealedSecret.enabled .Values.secrets.sealedSecret.items }}
{{- $items := .Values.secrets.sealedSecret.items -}}
{{- range $name := (keys $items | sortAlpha) }}
{{- $secret := index $items $name }}
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{ $name }}
  namespace: {{ $.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "sealed-secret") | nindent 4 }}
  {{- if $secret.annotations }}
  annotations:
    {{- range $key := (keys $secret.annotations | sortAlpha) }}
    {{ $key }}: {{ (index $secret.annotations $key) | quote }}
    {{- end }}
  {{- end }}
spec:
  encryptedData:
    {{- range $key := (keys $secret.data | sortAlpha) }}
    {{ $key }}: {{ (index $secret.data $key) | quote }}
    {{- end }}
  template:
    metadata:
      name: {{ $name }}
      namespace: {{ $.Values.global.namespace | default "default" }}
      labels:
        {{- include "libChart.labelsWithComponent" (dict "root" $ "component" "sealed-secret") | nindent 8 }}
        {{- if $secret.labels }}
        {{- range $key := (keys $secret.labels | sortAlpha) }}
        {{ $key }}: {{ (index $secret.labels $key) | quote }}
        {{- end }}
        {{- end }}
      {{- if $secret.templateAnnotations }}
      annotations:
        {{- range $key := (keys $secret.templateAnnotations | sortAlpha) }}
        {{ $key }}: {{ (index $secret.templateAnnotations $key) | quote }}
        {{- end }}
      {{- end }}
    type: {{ $secret.type | default "Opaque" }}
{{- end }}
{{- end }}
{{- end -}}
