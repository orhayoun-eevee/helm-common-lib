{{- define "libChart.classes.cronjob" -}}
{{- $root := .root | default . -}}
{{- $ctx := .ctx | default dict -}}
{{- $spec := $ctx.spec | default $root.Values.workload.spec | default dict -}}
{{- if $spec.containers }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "libChart.cronjobName" (dict "root" $root "spec" $spec) }}
  namespace: {{ $root.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $root "component" "cronjob") | nindent 4 }}
spec:
  schedule: {{ $spec.schedule | quote }}
  {{- if $spec.timeZone }}
  timeZone: {{ $spec.timeZone | quote }}
  {{- end }}
  {{- if ne $spec.suspend nil }}
  suspend: {{ $spec.suspend }}
  {{- end }}
  {{- if $spec.concurrencyPolicy }}
  concurrencyPolicy: {{ $spec.concurrencyPolicy }}
  {{- end }}
  {{- if ne $spec.startingDeadlineSeconds nil }}
  startingDeadlineSeconds: {{ $spec.startingDeadlineSeconds }}
  {{- end }}
  {{- if ne $spec.successfulJobsHistoryLimit nil }}
  successfulJobsHistoryLimit: {{ $spec.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if ne $spec.failedJobsHistoryLimit nil }}
  failedJobsHistoryLimit: {{ $spec.failedJobsHistoryLimit }}
  {{- end }}
  jobTemplate:
    spec:
      {{- if and $spec.jobTemplate (ne $spec.jobTemplate.backoffLimit nil) }}
      backoffLimit: {{ $spec.jobTemplate.backoffLimit }}
      {{- end }}
      {{- if and $spec.jobTemplate (ne $spec.jobTemplate.ttlSecondsAfterFinished nil) }}
      ttlSecondsAfterFinished: {{ $spec.jobTemplate.ttlSecondsAfterFinished }}
      {{- end }}
      {{- if and $spec.jobTemplate (ne $spec.jobTemplate.activeDeadlineSeconds nil) }}
      activeDeadlineSeconds: {{ $spec.jobTemplate.activeDeadlineSeconds }}
      {{- end }}
      template:
        metadata:
          labels:
            {{- include "libChart.labelsWithComponent" (dict "root" $root "component" "cronjob") | nindent 12 }}
            {{- if $spec.podLabels }}
            {{- toYaml $spec.podLabels | nindent 12 }}
            {{- end }}
        spec:
          {{- include "libChart.workload.podSpecCommon" (dict "root" $root "spec" $spec) | nindent 10 }}
          restartPolicy: {{ $spec.restartPolicy | default "OnFailure" }}
          {{- if $spec.initContainers }}
          initContainers:
            {{- $initContainers := $spec.initContainers -}}
            {{- range $name := (keys $initContainers | sortAlpha) }}
            {{- $container := index $initContainers $name }}
            - name: {{ $name }}
              {{- if $container.image }}
              image: {{ printf "%s:%s" $container.image.repository $container.image.tag }}
              {{- if $container.image.pullPolicy }}
              imagePullPolicy: {{ $container.image.pullPolicy }}
              {{- end }}
              {{- end }}
              {{- if $container.command }}
              command:
                {{- toYaml $container.command | nindent 16 }}
              {{- end }}
              {{- if $container.args }}
              args:
                {{- toYaml $container.args | nindent 16 }}
              {{- end }}
              {{- if $container.env }}
              env:
                {{- toYaml $container.env | nindent 16 }}
              {{- end }}
              {{- if $container.volumeMounts }}
              volumeMounts:
                {{- toYaml $container.volumeMounts | nindent 16 }}
              {{- end }}
              {{- if $container.resources }}
              resources:
                {{- toYaml $container.resources | nindent 16 }}
              {{- end }}
              {{- if $container.securityContext }}
              securityContext:
                {{- toYaml $container.securityContext | nindent 16 }}
              {{- else if $spec.defaultContainerSecurityContext }}
              securityContext:
                {{- toYaml $spec.defaultContainerSecurityContext | nindent 16 }}
              {{- end }}
            {{- end }}
          {{- end }}
          containers:
            {{- $containers := $spec.containers -}}
            {{- range $name := (keys $containers | sortAlpha) }}
            {{- $container := index $containers $name }}
            {{- if $container.enabled }}
            - name: {{ $name }}
              {{- if $container.image }}
              image: {{ printf "%s:%s" $container.image.repository $container.image.tag }}
              {{- if $container.image.pullPolicy }}
              imagePullPolicy: {{ $container.image.pullPolicy }}
              {{- end }}
              {{- end }}
              {{- if $container.command }}
              command:
                {{- toYaml $container.command | nindent 16 }}
              {{- end }}
              {{- if $container.args }}
              args:
                {{- toYaml $container.args | nindent 16 }}
              {{- end }}
              {{- if $container.env }}
              env:
                {{- toYaml $container.env | nindent 16 }}
              {{- end }}
              {{- if $container.envFrom }}
              envFrom:
                {{- toYaml $container.envFrom | nindent 16 }}
              {{- end }}
              {{- if $container.volumeMounts }}
              volumeMounts:
                {{- toYaml $container.volumeMounts | nindent 16 }}
              {{- end }}
              {{- if $container.resources }}
              resources:
                {{- toYaml $container.resources | nindent 16 }}
              {{- end }}
              {{- if $container.securityContext }}
              securityContext:
                {{- toYaml $container.securityContext | nindent 16 }}
              {{- else if $spec.defaultContainerSecurityContext }}
              securityContext:
                {{- toYaml $spec.defaultContainerSecurityContext | nindent 16 }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- if $root.Values.persistence.volumes }}
          volumes:
            {{- toYaml $root.Values.persistence.volumes | nindent 12 }}
          {{- end }}
{{- end }}
{{- end -}}
