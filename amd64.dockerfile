# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM golang:1.21.6-alpine3.19 as build
  ENV APP_VERSION=v0.6.3
  ENV BUILD="11notes"
  ENV APP_ROOT=/go/adguardhome-sync

  RUN set -ex; \
    apk add --update --no-cache \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      upx \
      git; \
    git clone https://github.com/bakito/adguardhome-sync.git; \
    cd ${APP_ROOT}; \
    git checkout ${APP_VERSION};

  RUN set -ex; \
    cd ${APP_ROOT}; \
    go build -a -installsuffix cgo -ldflags="-w -s -X github.com/bakito/adguardhome-sync/version.Version=${APP_VERSION} -X github.com/bakito/adguardhome-sync/version.Build=${BUILD}" -o adguardhome-sync . ; \
    upx -q adguardhome-sync;

# :: Header
  FROM 11notes/alpine:stable
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /go/adguardhome-sync/adguardhome-sync /usr/local/bin
  ENV APP_ROOT=/adguard-sync

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc;

  # :: install application
    RUN set -ex; \
      apk --no-cache upgrade;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]