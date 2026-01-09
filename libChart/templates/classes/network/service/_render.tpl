{{- define "common.class.network.service.RenderService" -}}
    {{ 
        $labels :=  (include "common.helpers.metadata.labels" .root | fromYaml)
    }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
    {{- toYaml $labels | nindent 4 }}
  annotations:
    description: Radarr media center HTTP service
    prometheus.io/scrape: "false"
spec:
  type: {{ toYaml .service.type }}
  ports:
    {{- toYaml .service.ports | nindent 4 }}
  selector:
    app.kubernetes.io/name: radarr
    app.kubernetes.io/instance: radarr
{{ end }}