{{- define "libChart.classes.deployment" -}}
{{- $root := .root | default . -}}
{{- $ctx := .ctx | default dict -}}
{{- $spec := $ctx.spec | default $root.Values.workload.spec | default dict -}}
{{- if $spec.containers }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "libChart.name" $root }}
  namespace: {{ $root.Values.global.namespace | default "default" }}
  labels:
    {{- include "libChart.labelsWithComponent" (dict "root" $root "component" "deployment") | nindent 4 }}
spec:
  replicas: {{ $spec.replicas | default 1 }}
  revisionHistoryLimit: {{ $spec.revisionHistoryLimit | default 3 }}
  strategy:
    type: {{ $spec.strategy.type | default "Recreate" }}
  selector:
    matchLabels:
      {{- include "libChart.selectorLabels" $root | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "libChart.labelsWithComponent" (dict "root" $root "component" "deployment") | nindent 8 }}
        {{- if $spec.podLabels }}
        {{- toYaml $spec.podLabels | nindent 8 }}
        {{- end }}
    spec:
      {{- include "libChart.workload.podSpecCommon" (dict "root" $root "spec" $spec) | nindent 6 }}
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
          {{- else if $spec.defaultContainerSecurityContext }}
          securityContext:
            {{- toYaml $spec.defaultContainerSecurityContext | nindent 12 }}
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
          {{- else if $spec.defaultContainerSecurityContext }}
          securityContext:
            {{- toYaml $spec.defaultContainerSecurityContext | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- if $root.Values.persistence.volumes }}
      volumes:
        {{- toYaml $root.Values.persistence.volumes | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
