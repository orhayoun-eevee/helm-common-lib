{{- define "common.class.network.RenderNetworkPolicy" -}}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .name }}
  labels:
    {{/* TODO: Get labels from application context */}}
    helm.sh/chart: application-v2-0.2.0
    app.kubernetes.io/name: radarr
    app.kubernetes.io/instance: radarr
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: network-policy
  annotations:
  {{/* TODO: Get annotations from application context */}}
    argocd.argoproj.io/sync-wave: "1"
spec:
  podSelector:
    {{/* TODO: Get podSelector From application context */}}
    matchLabels:
      app.kubernetes.io/name: radarr
      app.kubernetes.io/instance: radarr
  egress: 
  {{- toYaml .policy.egress | nindent 4 }}  
  ingress: 
  {{- toYaml .policy.ingress | nindent 4 }}
  policyTypes: 
  {{- toYaml .policy.policyTypes | nindent 4 }}
{{ end }}