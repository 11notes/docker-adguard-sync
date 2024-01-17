#!/bin/ash
  if [ -z "${1}" ]; then
    log-json info "starting adguard-sync"
    set -- "adguardhome-sync" \
      run \
      --config ${APP_ROOT}/etc/config.yaml
  fi

  exec "$@"