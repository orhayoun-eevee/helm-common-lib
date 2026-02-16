{{- define "libChart.labels" -}}
{{- $chartName := include "libChart.chartLabel" . -}}
{{- $appName := include "libChart.name" . -}}
{{- $appVersion := .Chart.AppVersion -}}
{{- if and .Values.global .Values.global.chart .Values.global.chart.appVersion }}
  {{- $appVersion = .Values.global.chart.appVersion -}}
{{- end -}}
{{- $labels := dict
    "helm.sh/chart" $chartName
    "app.kubernetes.io/name" $appName
    "app.kubernetes.io/instance" .Release.Name
    "app.kubernetes.io/managed-by" .Release.Service
-}}
{{- if $appVersion }}
  {{- $_ := set $labels "app.kubernetes.io/version" $appVersion -}}
{{- end -}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.partOf }}
  {{- $_ := set $labels "app.kubernetes.io/part-of" .Values.global.labels.partOf -}}
{{- end -}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.component }}
  {{- $_ := set $labels "app.kubernetes.io/component" .Values.global.labels.component -}}
{{- end -}}
{{- if and .Values.global .Values.global.labels .Values.global.labels.overrides }}
  {{- $overrides := .Values.global.labels.overrides -}}
  {{- if or (hasKey $overrides "app.kubernetes.io/name") (hasKey $overrides "app.kubernetes.io/instance") }}
    {{- fail "global.labels.overrides cannot override selector labels: app.kubernetes.io/name, app.kubernetes.io/instance" -}}
  {{- end -}}
  {{- range $key, $value := $overrides }}
    {{- $_ := set $labels $key $value -}}
  {{- end -}}
{{- end -}}
{{- toYaml $labels -}}
{{- end -}}

{{/*
Helper to generate labels with resource-specific component override.
The resource component always takes priority over global.labels.component.
Usage: include "libChart.labelsWithComponent" (dict "root" . "component" "deployment")
*/}}
{{- define "libChart.labelsWithComponent" -}}
{{- $labels := include "libChart.labels" .root | fromYaml -}}
{{- $_ := set $labels "app.kubernetes.io/component" .component -}}
{{- toYaml $labels -}}
{{- end -}}

{{- define "libChart.selectorLabels" -}}
{{- $appName := include "libChart.name" . -}}
app.kubernetes.io/name: {{ $appName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
