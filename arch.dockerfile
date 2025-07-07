# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/go/adguardhome-sync
  ARG BUILD_BIN=${BUILD_ROOT}/adguardhome-sync

  # :: FOREIGN IMAGES
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ADGUARD-SYNC
  FROM golang:1.24-alpine AS build
  COPY --from=util-bin / /
  ARG APP_VERSION \
      APP_IMAGE \
      BUILD_ROOT \
      BUILD_BIN \
      TARGETARCH \
      TARGETPLATFORM \
      TARGETVARIANT \
      CGO_ENABLED=0

  RUN set -ex; \
    apk --update --no-cache add \
      git;

  RUN set -ex; \
    git clone https://github.com/bakito/adguardhome-sync.git -b v${APP_VERSION};

  COPY ./build /

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    go mod tidy; \
    go build -ldflags="-extldflags=-static -X github.com/bakito/adguardhome-sync/version.Version=${APP_VERSION} -X github.com/bakito/adguardhome-sync/version.Build=${APP_IMAGE}";

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
      APP_NAME=${APP_NAME} \
      APP_VERSION=${APP_VERSION} \
      APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-curl / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:3000/healthz"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/adguardhome-sync"]
  CMD ["run", "--config", "/adguard-sync/etc/config.yaml"]