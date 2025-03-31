# :: Util
  FROM 11notes/util AS util

# :: Build / adguard
  FROM golang:1.24-alpine AS build
  ARG TARGETARCH
  ARG APP_IMAGE
  ARG APP_ROOT
  ARG APP_VERSION
  ENV CGO_ENABLED=0
  ENV BUILD_DIR=/go/adguardhome-sync
  ENV BUILD_BIN=${BUILD_DIR}/adguardhome-sync

  USER root

  COPY --from=util /usr/local/bin/ /usr/local/bin

  RUN set -ex; \
    apk --update --no-cache add \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      upx \
      openssl \
      git;

  RUN set -ex; \
    git clone https://github.com/bakito/adguardhome-sync.git -b v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    go build -ldflags="-extldflags=-static -X github.com/bakito/adguardhome-sync/version.Version=${APP_VERSION} -X github.com/bakito/adguardhome-sync/version.Build=${APP_IMAGE}";

  RUN set -ex; \
    mkdir -p /distroless/usr/local/bin; \
    eleven strip ${BUILD_BIN}; \
    cp ${BUILD_BIN} /distroless/usr/local/bin;

  RUN set -ex; \
    mkdir -p /distroless/${APP_ROOT}/etc/ssl; \
    openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=docker/CN=adguard-sync" \
      -keyout "/distroless/${APP_ROOT}/etc/ssl/default.key" \
      -out "/distroless/${APP_ROOT}/etc/ssl/default.crt" \
      -days 3650 -nodes -sha256 &> /dev/null;

# :: Distroless / adguard-sync
  FROM scratch AS distroless-adguard-sync
  ARG APP_ROOT
  COPY --from=build /distroless/ /


# :: Build / file system
  FROM alpine AS fs
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    mkdir -p ${APP_ROOT}/etc;

  COPY ./rootfs /

# :: Distroless / file system
  FROM scratch AS distroless-fs
  ARG APP_ROOT
  COPY --from=fs ${APP_ROOT} /${APP_ROOT}


# :: Header
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl
  FROM scratch

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

    ENV LOG_FORMAT=json

  # :: multi-stage
    COPY --from=distroless --chown=1000:1000 / /
    COPY --from=distroless-fs --chown=1000:1000 / /
    COPY --from=distroless-curl --chown=1000:1000 / /
    COPY --from=distroless-adguard-sync --chown=1000:1000 / /

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD if [ $(curl http://localhost:8080 -s --write-out "%{http_code}") = "401" ]; then exit 0; else exit 1; fi

# :: Start
  USER docker
  ENTRYPOINT ["adguardhome-sync"]
  CMD ["run", "--config", "/adguard-sync/etc/config.yaml"]