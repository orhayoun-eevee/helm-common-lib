{{/* Expand the name of the chart */}}
{{- define "common.helpers.chart.names.name" -}}
  {{- $globalNameOverride := get .Values.global "name" -}}
  {{- $name := $globalNameOverride | default .Chart.Name -}}
  {{- $name | toString | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "common.helpers.chart.names.chart" -}}
  {{- $chartName := .Chart.Name -}}
  {{- $chartVersion := .Chart.Version -}}
  {{- if and .Values.global .Values.global.chart -}}
    {{- if .Values.global.chart.name -}}
      {{- $chartName = .Values.global.chart.name -}}
    {{- end -}}
    {{- if .Values.global.chart.version -}}
      {{- $chartVersion = .Values.global.chart.version -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s-%s" $chartName $chartVersion | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}