{{- define "libChart.classes.deployment" -}}
{{- if .Values.deployment.containers }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "libChart.name" . }}
  namespace: {{ .Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" . "component" "deployment") | nindent 4 }}
spec:
  replicas: {{ .Values.deployment.replicas | default 1 }}
  revisionHistoryLimit: {{ .Values.deployment.revisionHistoryLimit | default 3 }}
  strategy:
    type: {{ .Values.deployment.strategy.type | default "Recreate" }}
  selector:
    matchLabels:
      {{- include "libChart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "libChart.labelsWithComponent" (dict "root" . "component" "deployment") | nindent 8 }}
        {{- if .Values.deployment.podLabels }}
        {{- toYaml .Values.deployment.podLabels | nindent 8 }}
        {{- end }}
    spec:
      {{- if .Values.deployment.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .Values.deployment.imagePullSecrets | nindent 8 }}
      {{- end }}
      {{- if .Values.deployment.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ .Values.deployment.terminationGracePeriodSeconds }}
      {{- end }}
      {{- if .Values.deployment.podSecurityContext }}
      securityContext:
        {{- toYaml .Values.deployment.podSecurityContext | nindent 8 }}
      {{- end }}
      {{- if and .Values.serviceAccount .Values.serviceAccount.create }}
      serviceAccountName: {{ .Values.serviceAccount.name | default (include "libChart.name" .) }}
      {{- end }}
      {{- if .Values.deployment.affinity }}
      affinity:
        {{- toYaml .Values.deployment.affinity | nindent 8 }}
      {{- end }}
      {{- if .Values.deployment.tolerations }}
      tolerations:
        {{- toYaml .Values.deployment.tolerations | nindent 8 }}
      {{- end }}
      {{- if .Values.deployment.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.deployment.nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .Values.deployment.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml .Values.deployment.topologySpreadConstraints | nindent 8 }}
      {{- end }}
      {{- if .Values.deployment.dnsPolicy }}
      dnsPolicy: {{ .Values.deployment.dnsPolicy }}
      {{- end }}
      {{- if ne .Values.deployment.automountServiceAccountToken nil }}
      automountServiceAccountToken: {{ .Values.deployment.automountServiceAccountToken }}
      {{- end }}
      {{- if ne .Values.deployment.enableServiceLinks nil }}
      enableServiceLinks: {{ .Values.deployment.enableServiceLinks }}
      {{- end }}
      {{- if .Values.deployment.initContainers }}
      initContainers:
        {{- $initContainers := .Values.deployment.initContainers -}}
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
            {{- toYaml $container.command | nindent 12 }}
          {{- end }}
          {{- if $container.args }}
          args:
            {{- toYaml $container.args | nindent 12 }}
          {{- end }}
          {{- if $container.env }}
          env:
            {{- toYaml $container.env | nindent 12 }}
          {{- end }}
          {{- if $container.volumeMounts }}
          volumeMounts:
            {{- toYaml $container.volumeMounts | nindent 12 }}
          {{- end }}
          {{- if $container.resources }}
          resources:
            {{- toYaml $container.resources | nindent 12 }}
          {{- end }}
          {{- if $container.securityContext }}
          securityContext:
            {{- toYaml $container.securityContext | nindent 12 }}
          {{- else if $.Values.deployment.defaultContainerSecurityContext }}
          securityContext:
            {{- toYaml $.Values.deployment.defaultContainerSecurityContext | nindent 12 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- $containers := .Values.deployment.containers -}}
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
          {{- if $container.ports }}
          ports:
            {{- range $container.ports }}
            - name: {{ .name }}
              containerPort: {{ .containerPort }}
              {{- if .protocol }}
              protocol: {{ .protocol }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- if $container.command }}
          command:
            {{- toYaml $container.command | nindent 12 }}
          {{- end }}
          {{- if $container.args }}
          args:
            {{- toYaml $container.args | nindent 12 }}
          {{- end }}
          {{- if $container.env }}
          env:
            {{- toYaml $container.env | nindent 12 }}
          {{- end }}
          {{- if $container.envFrom }}
          envFrom:
            {{- toYaml $container.envFrom | nindent 12 }}
          {{- end }}
          {{- if $container.volumeMounts }}
          volumeMounts:
            {{- toYaml $container.volumeMounts | nindent 12 }}
          {{- end }}
          {{- if $container.resources }}
          resources:
            {{- toYaml $container.resources | nindent 12 }}
          {{- end }}
          {{- if $container.livenessProbe }}
          livenessProbe:
            {{- toYaml $container.livenessProbe | nindent 12 }}
          {{- end }}
          {{- if $container.readinessProbe }}
          readinessProbe:
            {{- toYaml $container.readinessProbe | nindent 12 }}
          {{- end }}
          {{- if $container.startupProbe }}
          startupProbe:
            {{- toYaml $container.startupProbe | nindent 12 }}
          {{- end }}
          {{- if $container.lifecycle }}
          lifecycle:
            {{- toYaml $container.lifecycle | nindent 12 }}
          {{- end }}
          {{- if $container.securityContext }}
          securityContext:
            {{- toYaml $container.securityContext | nindent 12 }}
          {{- else if $.Values.deployment.defaultContainerSecurityContext }}
          securityContext:
            {{- toYaml $.Values.deployment.defaultContainerSecurityContext | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- if .Values.persistence.volumes }}
      volumes:
        {{- toYaml .Values.persistence.volumes | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
