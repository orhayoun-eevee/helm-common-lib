{{- define "common.main" -}}

    {{- if and .Values.network .Values.network.enabled -}}
        {{- include "common.class.network" . -}}
    {{- end -}}

{{- end -}}