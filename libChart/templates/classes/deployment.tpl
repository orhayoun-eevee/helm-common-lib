{{- define "libChart.classes.deployment" -}}
{{- if .Values.deployment.containers }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.helpers.chart.names.name" . }}
  labels:
    {{- include "common.helpers.metadata.labels" . | nindent 4 }}
    app.kubernetes.io/component: deployment
spec:
  replicas: {{ .Values.deployment.replicas | default 1 }}
  revisionHistoryLimit: {{ .Values.deployment.revisionHistoryLimit | default 3 }}
  strategy:
    type: {{ .Values.deployment.strategy.type | default "Recreate" }}
  selector:
    matchLabels:
      {{- include "common.helpers.metadata.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.helpers.metadata.labels" . | nindent 8 }}
        {{- $defaultLabels := dict "app.kubernetes.io/component" "deployment" }}
        {{- $podLabels := $defaultLabels }}
        {{- if .Values.deployment.podLabels }}
          {{- $podLabels = merge (deepCopy .Values.deployment.podLabels) $defaultLabels }}
        {{- end }}
        {{- toYaml $podLabels | nindent 8 }}
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
      serviceAccountName: {{ .Values.serviceAccount.name | default (include "common.helpers.chart.names.name" .) }}
      {{- end }}
      {{- if .Values.deployment.initContainers }}
      initContainers:
        {{- range $name, $container := .Values.deployment.initContainers }}
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
        {{- range $name, $container := .Values.deployment.containers }}
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
          {{- if $container.securityContext }}
          securityContext:
            {{- toYaml $container.securityContext | nindent 12 }}
          {{- else if $.Values.deployment.defaultContainerSecurityContext }}
          securityContext:
            {{- toYaml $.Values.deployment.defaultContainerSecurityContext | nindent 12 }}
          {{- end }}
        {{- end }}
      {{- if .Values.persistence.volumes }}
      volumes:
        {{- range .Values.persistence.volumes }}
        - {{- toYaml . | nindent 10 }}
        {{- end }}
      {{- end }}
{{- end }}
{{- end -}}

