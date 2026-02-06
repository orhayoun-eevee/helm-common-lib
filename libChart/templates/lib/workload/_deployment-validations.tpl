{{- /*
  Deployment configuration validations (containers, image, replicas).
  Context: .root = chart context, .scratch.errors = list to append to.
*/ -}}
{{- define "libChart.validations.deployment" -}}
{{- $root := .root -}}
{{- $scratch := .scratch -}}

{{- if $root.Values.deployment -}}

  {{- if not $root.Values.deployment.containers -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "deployment.containers is required when using deployment. At least one container must be defined.") -}}
  {{- else if eq (len $root.Values.deployment.containers) 0 -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) "deployment.containers cannot be empty. At least one container must be defined.") -}}
  {{- else -}}
    {{- range $containerName, $container := $root.Values.deployment.containers -}}
      {{- if $container.enabled -}}

        {{- if not $container.image -}}
          {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.containers.%s.image is required when container is enabled." $containerName)) -}}
        {{- else -}}
          {{- if not $container.image.repository -}}
            {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.containers.%s.image.repository is required. Please specify the container image repository." $containerName)) -}}
          {{- else if eq $container.image.repository "" -}}
            {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.containers.%s.image.repository cannot be empty. Please specify the container image repository." $containerName)) -}}
          {{- end -}}
          {{- if not $container.image.tag -}}
            {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.containers.%s.image.tag is required. Please specify the image tag (may include @digest)." $containerName)) -}}
          {{- else if eq $container.image.tag "" -}}
            {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.containers.%s.image.tag cannot be empty. Please specify the image tag." $containerName)) -}}
          {{- end -}}
        {{- end -}}

      {{- end -}}
    {{- end -}}
  {{- if and $root.Values.deployment.replicas (lt ($root.Values.deployment.replicas | int) 0) -}}
    {{- $_ := set $scratch "errors" (append (default list $scratch.errors) (printf "deployment.replicas must be >= 0, got %d" ($root.Values.deployment.replicas | int))) -}}
  {{- end -}}
  {{- end -}}

{{- end -}}

{{- end -}}
