{{- define "libChart.classes.cronjob" -}}
{{- if and .Values.cronJob .Values.cronJob.containers }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "libChart.cronjobName" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "cronjob") | nindent 4 }}
spec:
  schedule: {{ .Values.cronJob.schedule | quote }}
  {{- if .Values.cronJob.timeZone }}
  timeZone: {{ .Values.cronJob.timeZone | quote }}
  {{- end }}
  {{- if ne .Values.cronJob.suspend nil }}
  suspend: {{ .Values.cronJob.suspend }}
  {{- end }}
  {{- if .Values.cronJob.concurrencyPolicy }}
  concurrencyPolicy: {{ .Values.cronJob.concurrencyPolicy }}
  {{- end }}
  {{- if ne .Values.cronJob.startingDeadlineSeconds nil }}
  startingDeadlineSeconds: {{ .Values.cronJob.startingDeadlineSeconds }}
  {{- end }}
  {{- if ne .Values.cronJob.successfulJobsHistoryLimit nil }}
  successfulJobsHistoryLimit: {{ .Values.cronJob.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if ne .Values.cronJob.failedJobsHistoryLimit nil }}
  failedJobsHistoryLimit: {{ .Values.cronJob.failedJobsHistoryLimit }}
  {{- end }}
  jobTemplate:
    spec:
      {{- if and .Values.cronJob.jobTemplate (ne .Values.cronJob.jobTemplate.backoffLimit nil) }}
      backoffLimit: {{ .Values.cronJob.jobTemplate.backoffLimit }}
      {{- end }}
      {{- if and .Values.cronJob.jobTemplate (ne .Values.cronJob.jobTemplate.ttlSecondsAfterFinished nil) }}
      ttlSecondsAfterFinished: {{ .Values.cronJob.jobTemplate.ttlSecondsAfterFinished }}
      {{- end }}
      template:
        metadata:
          labels:
            {{- include "libChart.labelsWithComponent" (dict "root" . "component" "cronjob") | nindent 12 }}
            {{- if .Values.cronJob.podLabels }}
            {{- toYaml .Values.cronJob.podLabels | nindent 12 }}
            {{- end }}
        spec:
          {{- if .Values.cronJob.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml .Values.cronJob.imagePullSecrets | nindent 12 }}
          {{- end }}
          {{- if ne (index .Values.cronJob "terminationGracePeriodSeconds") nil }}
          terminationGracePeriodSeconds: {{ index .Values.cronJob "terminationGracePeriodSeconds" }}
          {{- end }}
          {{- if .Values.cronJob.podSecurityContext }}
          securityContext:
            {{- toYaml .Values.cronJob.podSecurityContext | nindent 12 }}
          {{- end }}
          {{- if and .Values.serviceAccount .Values.serviceAccount.name }}
          serviceAccountName: {{ .Values.serviceAccount.name }}
          {{- else if and .Values.serviceAccount .Values.serviceAccount.create }}
          serviceAccountName: {{ include "libChart.name" . }}
          {{- end }}
          {{- if .Values.cronJob.affinity }}
          affinity:
            {{- toYaml .Values.cronJob.affinity | nindent 12 }}
          {{- end }}
          {{- if .Values.cronJob.tolerations }}
          tolerations:
            {{- toYaml .Values.cronJob.tolerations | nindent 12 }}
          {{- end }}
          {{- if .Values.cronJob.nodeSelector }}
          nodeSelector:
            {{- toYaml .Values.cronJob.nodeSelector | nindent 12 }}
          {{- end }}
          {{- if .Values.cronJob.topologySpreadConstraints }}
          topologySpreadConstraints:
            {{- toYaml .Values.cronJob.topologySpreadConstraints | nindent 12 }}
          {{- end }}
          {{- if ne .Values.cronJob.hostNetwork nil }}
          hostNetwork: {{ .Values.cronJob.hostNetwork }}
          {{- end }}
          {{- if .Values.cronJob.dnsPolicy }}
          dnsPolicy: {{ .Values.cronJob.dnsPolicy }}
          {{- else if .Values.cronJob.hostNetwork }}
          dnsPolicy: ClusterFirstWithHostNet
          {{- end }}
          {{- if ne .Values.cronJob.automountServiceAccountToken nil }}
          automountServiceAccountToken: {{ .Values.cronJob.automountServiceAccountToken }}
          {{- end }}
          {{- if ne .Values.cronJob.enableServiceLinks nil }}
          enableServiceLinks: {{ .Values.cronJob.enableServiceLinks }}
          {{- end }}
          restartPolicy: {{ .Values.cronJob.restartPolicy | default "OnFailure" }}
          {{- if .Values.cronJob.initContainers }}
          initContainers:
            {{- $initContainers := .Values.cronJob.initContainers -}}
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
              {{- else if $.Values.cronJob.defaultContainerSecurityContext }}
              securityContext:
                {{- toYaml $.Values.cronJob.defaultContainerSecurityContext | nindent 16 }}
              {{- end }}
            {{- end }}
          {{- end }}
          containers:
            {{- $containers := .Values.cronJob.containers -}}
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
              {{- else if $.Values.cronJob.defaultContainerSecurityContext }}
              securityContext:
                {{- toYaml $.Values.cronJob.defaultContainerSecurityContext | nindent 16 }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- if .Values.persistence.volumes }}
          volumes:
            {{- toYaml .Values.persistence.volumes | nindent 12 }}
          {{- end }}
{{- end }}
{{- end -}}
