# syntax=docker/dockerfile:1

################################################################
#                                                              #
#  WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY  #
#                                                              #
################################################################

ARG CREATED_AT

FROM alpine:3.21.3 AS downloader

WORKDIR /opt

# Download Open Integration Engine release
RUN apk add --no-cache curl \
    && curl -L \
      -o /opt/engine.tar.gz \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
       https://github.com/OpenIntegrationEngine/engine/releases/download/v4.5.2-tp.1/oie_unix_4_5_2.tar.gz \
    && tar xzf engine.tar.gz \
    && mv /opt/oie /opt/engine \
    && mkdir -p /opt/engine/appdata

WORKDIR /opt/engine
COPY --chmod=755 entrypoint.sh /opt/engine/entrypoint.sh

RUN rm -rf cli-lib manager-lib \
    && rm mirth-cli-launcher.jar oiecommand

RUN chown -R 1000:1000 /opt/engine
FROM eclipse-temurin:17.0.15_6-jre-noble AS ubuntu-jre

ARG CREATED_AT

LABEL \
  "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
  "org.opencontainers.image.created"="${CREATED_AT?:}" \
  "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
  "org.opencontainers.image.licenses"="MPL-2.0" \
  "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
  "org.opencontainers.image.title"="Open Integration Engine" \
  "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
  "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
  "org.opencontainers.image.version"="4.5.2-tp.1"

COPY --from=downloader /opt/engine /opt/engine

RUN apt-get update \
    && apt-get install -y unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupmod --new-name engine ubuntu \
    && usermod -l engine ubuntu \
    && usermod -aG engine engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]

FROM eclipse-temurin:17.0.15_6-jdk-noble AS ubuntu-jdk

ARG CREATED_AT

LABEL \
  "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
  "org.opencontainers.image.created"="${CREATED_AT?:}" \
  "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
  "org.opencontainers.image.licenses"="MPL-2.0" \
  "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
  "org.opencontainers.image.title"="Open Integration Engine" \
  "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
  "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
  "org.opencontainers.image.version"="4.5.2-tp.1"

COPY --from=downloader /opt/engine /opt/engine

RUN apt-get update \
    && apt-get install -y unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupmod --new-name engine ubuntu \
    && usermod -l engine ubuntu \
    && usermod -aG engine engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]

FROM eclipse-temurin:17.0.15_6-jre-alpine AS alpine-jre

ARG CREATED_AT

LABEL \
  "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
  "org.opencontainers.image.created"="${CREATED_AT?:}" \
  "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
  "org.opencontainers.image.licenses"="MPL-2.0" \
  "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
  "org.opencontainers.image.title"="Open Integration Engine" \
  "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
  "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
  "org.opencontainers.image.version"="4.5.2-tp.1"

COPY --from=downloader /opt/engine /opt/engine

RUN apk add --no-cache bash unzip \
    && adduser -D -H -u 1000 engine engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]

FROM eclipse-temurin:17.0.15_6-jdk-alpine AS alpine-jdk

ARG CREATED_AT

LABEL \
  "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
  "org.opencontainers.image.created"="${CREATED_AT?:}" \
  "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
  "org.opencontainers.image.licenses"="MPL-2.0" \
  "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
  "org.opencontainers.image.title"="Open Integration Engine" \
  "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
  "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
  "org.opencontainers.image.version"="4.5.2-tp.1"

COPY --from=downloader /opt/engine /opt/engine

RUN apk add --no-cache bash unzip \
    && adduser -D -H -u 1000 engine engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]
