# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_SRC=bakito/adguardhome-sync.git \
      BUILD_ROOT=/go/adguardhome-sync
  ARG BUILD_BIN=${BUILD_ROOT}/adguardhome-sync

 # :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ADGUARD-SYNC
  FROM 11notes/go:1.24 AS build
  ARG APP_VERSION \
      APP_IMAGE \
      BUILD_SRC \
      BUILD_ROOT \
      BUILD_BIN

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    go build -ldflags="-extldflags=-static -X github.com/bakito/adguardhome-sync/version.Version=${APP_VERSION} -X github.com/bakito/adguardhome-sync/version.Build=${APP_IMAGE}";

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT

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
  HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
    CMD ["/usr/local/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:3000/healthz"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/adguardhome-sync"]
  CMD ["run", "--config", "/adguard-sync/etc/config.yaml"]