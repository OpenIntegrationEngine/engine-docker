{{/* Create gomplate specific iteration over versions array */}}
{{- range $version := .versions -}}
  {{- $ctx := dict "latest" $.latest "version" $version }}

  {{/* Define paths to render the Dockerfiles to */}}
  {{- $outPath := printf "dockerfiles/%s/compose.yaml" $version.slug }}

  {{/* Render the inline template defined below */}}
  {{- tmpl.Exec "composefile" $ctx | file.Write $outPath }}
{{- end -}}

{{- define "composefile" -}}
################################################################
#                                                              #
#  WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY  #
#                                                              #
################################################################

name: open-integration-engine

{{/* Assign current version slug into a variable to carry it into the tags iteration */}}
{{- $slug := .version.slug -}}
services:
  {{- range .version.tags }}
    {{ print .distro "-" .type ":" }}
      image: openintegrationengine/engine
      build:
        dockerfile: dockerfiles/{{ $slug }}/Dockerfile
        target: {{ .distro }}-{{ .type }}
        context: ../../
        platforms:
          - linux/amd64
    #      - linux/arm64
        tags:
          - openintegrationengine/engine:{{ $slug }}-{{ .distro }}
          - openintegrationengine/engine:{{ $slug }}-{{ .distro }}-{{ .type }}
          {{- if eq $slug $.latest }}
          - openintegrationengine/engine:latest-{{ .distro }}-{{ .type }}
            {{- if eq .type "jre" }}
          - openintegrationengine/engine:latest-{{ .distro }}
              {{- if eq .distro "alpine" }}
          - openintegrationengine/engine:latest
              {{- end }}
            {{- end }}
          {{- end }}
  {{ end }}
{{- end }}
