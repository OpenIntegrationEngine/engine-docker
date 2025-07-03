{{/* Collect all root elements except "versions" into a variable */}}
{{- $config := coll.Omit "versions" . -}}

{{/* Create gomplate specific iteration over versions array */}}
{{- range $version := .versions -}}
  {{- $ctx := dict "config" $config "version" $version }}

  {{/* Define paths to render the Dockerfiles to */}}
  {{- $outPath := printf "dockerfiles/%s/Dockerfile" $version.slug }}

  {{/* Render the inline template defined below */}}
  {{- tmpl.Exec "dockerfile" $ctx | file.Write $outPath }}
{{- end -}}

{{- define "dockerfile" -}}
# syntax=docker/dockerfile:1

################################################################
#                                                              #
#  WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY  #
#                                                              #
################################################################

ARG CREATED_AT

FROM alpine:{{ .config.downloaderTag }} AS downloader

WORKDIR /opt

# Download Open Integration Engine release
RUN apk add --no-cache curl \
    && curl -L \
      -o /opt/engine.tar.gz \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
       {{ .version.releaseUrl }} \
    && tar xzf engine.tar.gz \
    && mv /opt/oie /opt/engine \
    && mkdir -p /opt/engine/appdata

WORKDIR /opt/engine
COPY --chmod=755 entrypoint.sh /opt/engine/entrypoint.sh

RUN rm -rf cli-lib manager-lib \
    && rm mirth-cli-launcher.jar oiecommand

{{- /* Assign current version slug into a variable to carry it into the tags iteration */}}
{{- $slug := dict "slug" .version.slug -}}
{{/* Iterate version tags to generate the final stages */}}
{{- range .version.tags }}
FROM eclipse-temurin:{{ .tag }} AS {{ print .distro "-" .type }}

ARG CREATED_AT

LABEL \
{{/* Render the Labels section to include the slug */}}
{{- tpl $.config.labels $slug | strings.Indent 2 }}

COPY --from=downloader --chown={{ $.config.uid }}:{{ $.config.gid }} /opt/engine /opt/engine
{{ if eq .distro "ubuntu" }}
RUN apt-get update \
    && apt-get install -y unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupmod --new-name engine ubuntu \
    && usermod -l engine ubuntu \
    && usermod -aG engine engine
{{- else if eq .distro "alpine" }}
RUN apk add --no-cache bash unzip \
    && adduser -D -H -u {{ $.config.uid }} engine engine
{{- end }}

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]
{{ end -}}

{{ end }}
