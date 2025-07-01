# syntax=docker/dockerfile:1

ARG BASE_IMAGE_TAG

ARG OIE_RELEASE_VERSION

ARG UID=14285
ARG GID=14285

FROM alpine:3.21.3 AS downloader

ARG UID
ARG GID
ARG OIE_RELEASE_URL

WORKDIR /opt

# Download Open Integration Engine release
RUN apk add --no-cache curl \
    && curl -L \
      -o /opt/engine.tar.gz \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
       ${OIE_RELEASE_URL}\
    && tar xzf engine.tar.gz \
    && mv /opt/oie /opt/engine \
    && mkdir -p /opt/engine/appdata

WORKDIR /opt/engine
COPY --chmod=755 entrypoint.sh /opt/engine/entrypoint.sh

RUN rm -rf cli-lib manager-lib \
    && rm mirth-cli-launcher.jar oiecommand

RUN chown -R ${UID}:${GID} /opt/engine


##########################################
#     Alpine based Images
##########################################
FROM eclipse-temurin:$BASE_IMAGE_TAG AS alpine

ARG UID
ARG GID
ARG OIE_RELEASE_VERSION
ARG CREATED_AT

# Add OCI best-practice labels https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
LABEL "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
      "org.opencontainers.image.created"="${CREATED_AT?:}" \
      "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
      "org.opencontainers.image.licenses"="MPL-2.0" \
      "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
      "org.opencontainers.image.title"="Open Integration Engine" \
      "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
      "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
      "org.opencontainers.image.version"="${OIE_RELEASE_VERSION?:}"

COPY --from=downloader /opt/engine /opt/engine

RUN apk add --no-cache bash unzip \
    && adduser -D -H -u $UID engine engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]

##########################################
#     Ubuntu based Images
##########################################
FROM eclipse-temurin:$BASE_IMAGE_TAG AS ubuntu

ARG UID
ARG GID
ARG OIE_RELEASE_VERSION
ARG CREATED_AT

# Add OCI best-practice labels https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
LABEL "org.opencontainers.image.authors"="The Open Integration Engine Project and contributors" \
      "org.opencontainers.image.created"="${CREATED_AT?:}" \
      "org.opencontainers.image.description"="An open source fork of the now closed-source Mirth Connect" \
      "org.opencontainers.image.licenses"="MPL-2.0" \
      "org.opencontainers.image.source"="https://github.com/OpenIntegrationEngine/engine-docker" \
      "org.opencontainers.image.title"="Open Integration Engine" \
      "org.opencontainers.image.url"="https://github.com/OpenIntegrationEngine/engine" \
      "org.opencontainers.image.vendor"="The Open Integration Engine Project" \
      "org.opencontainers.image.version"="${OIE_RELEASE_VERSION?:}"

COPY --from=downloader /opt/engine /opt/engine

RUN apt-get update \
    && apt-get install -y unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid ${GID} engine \
    && useradd -u ${UID} -g ${GID} -M engine

VOLUME /opt/engine/appdata
VOLUME /opt/engine/custom-extensions

WORKDIR /opt/engine
EXPOSE 8443
USER engine

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./oieserver"]

