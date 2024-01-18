#!/bin/ash
  cURL=$(curl --max-time 5 --silent --output /dev/stderr --write-out "%{http_code}" http://localhost:8080/)
  case "${cURL}" in
    200|401)
      exit 0
    ;;

    *)
      exit 1
    ;;
  esac
