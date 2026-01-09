{{- define "common.class.network.service" -}}
    {{- $rootContext := $ -}}

    {{- range $name, $service := .Values.network.services.items -}}

        {{- if $service.enabled -}}
            {{- include "common.class.network.service.RenderService"  (dict "root" $rootContext "name" $name "service" $service) -}}
        {{- end -}}

    {{- end -}}

{{- end -}}