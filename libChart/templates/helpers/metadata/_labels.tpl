{{- define "common.helpers.metadata.labels" -}}
{{- $chartName := include "common.helpers.chart.names.chart" . -}}
{{- $appName := include "common.helpers.chart.names.name" . -}}
{{- $appVersion := .Chart.AppVersion -}}
{{- if and .Values.global .Values.global.chart .Values.global.chart.appVersion -}}
  {{- $appVersion = .Values.global.chart.appVersion -}}
{{- end -}}
{{- $labels := dict 
    "helm.sh/chart" $chartName
    "app.kubernetes.io/name" $appName
    "app.kubernetes.io/instance" .Release.Name
    "app.kubernetes.io/version" ($appVersion | quote)
    "app.kubernetes.io/managed-by" .Release.Service
-}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.partOf -}}
  {{- $_ := set $labels "app.kubernetes.io/part-of" .Values.global.labels.partOf -}}
{{- end -}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.overrides -}}
  {{- range $key, $value := .Values.global.labels.overrides -}}
    {{- $_ := set $labels $key $value -}}
  {{- end -}}
{{- end -}}
{{- toYaml $labels -}}
{{- end -}}

{{- define "common.helpers.metadata.selectorLabels" -}}
{{- $appName := include "common.helpers.chart.names.name" . -}}
{{- $selector := dict 
    "app.kubernetes.io/name" $appName
    "app.kubernetes.io/instance" .Release.Name
-}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.overrides -}}
  {{- if hasKey .Values.global.labels.overrides "app.kubernetes.io/name" -}}
    {{- $_ := set $selector "app.kubernetes.io/name" (get .Values.global.labels.overrides "app.kubernetes.io/name") -}}
  {{- end -}}
  {{- if hasKey .Values.global.labels.overrides "app.kubernetes.io/instance" -}}
    {{- $_ := set $selector "app.kubernetes.io/instance" (get .Values.global.labels.overrides "app.kubernetes.io/instance") -}}
  {{- end -}}
{{- end -}}
{{- toYaml $selector -}}
{{- end -}}
