{{- define "common.class.network.istio.RenderAuthorizationPolicy" -}}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ .name }}
  labels:
    helm.sh/chart: application-v2-0.2.0
    app.kubernetes.io/name: radarr
    app.kubernetes.io/instance: radarr
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: authorization-policy
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: radarr
      app.kubernetes.io/instance: radarr
  action: ALLOW
  rules:
  {{- toYaml .policy.rules | nindent 4 }}
{{ end }}