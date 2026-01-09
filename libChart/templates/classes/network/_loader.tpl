{{- define "common.class.network" -}}

    {{/* Load Service */}}
    {{- if and .Values.network.services .Values.network.services.enabled -}}
        {{- include "common.class.network.service" . -}}
    {{- end -}}



{{- end -}}