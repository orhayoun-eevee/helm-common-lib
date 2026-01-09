{{/* Expand the name of the chart */}}
{{- define "common.helpers.chart.names.name" -}}
  {{- $globalNameOverride := get .Values.global "name" -}}
  {{- $name := $globalNameOverride | default .Chart.Name -}}
  {{- $name | toString | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "common.helpers.chart.names.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}