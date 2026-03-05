{{/* Expand the name of the chart */}}
{{- define "libChart.name" -}}
  {{- $globalNameOverride := get .Values.global "name" -}}
  {{- $name := $globalNameOverride | default .Chart.Name -}}
  {{- $name | toString | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
CronJob names are limited to 52 chars because the controller appends 11 chars
when creating Job names, and Jobs are capped at 63 chars.
*/}}
{{- define "libChart.cronjobName" -}}
  {{- $root := . -}}
  {{- $spec := dict -}}
  {{- if kindIs "map" . }}
    {{- if hasKey . "root" }}
      {{- $root = .root -}}
    {{- end }}
    {{- if hasKey . "spec" }}
      {{- $spec = .spec -}}
    {{- end }}
  {{- end }}
  {{- $base := include "libChart.name" $root -}}
  {{- if and $spec $spec.nameOverride }}
    {{- $base = $spec.nameOverride -}}
  {{- else if and $root.Values.workload $root.Values.workload.spec $root.Values.workload.spec.nameOverride }}
    {{- $base = $root.Values.workload.spec.nameOverride -}}
  {{- end -}}
  {{- $base | toString | trunc 52 | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "libChart.chartLabel" -}}
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
{{- printf "%s-%s" $chartName $chartVersion | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
