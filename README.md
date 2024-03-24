# Alpine :: AdGuard-Sync
![size](https://img.shields.io/docker/image-size/11notes/adguard-sync/0.6.3?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/adguard-sync?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/adguard-sync?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-adguard-sync?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-adguard-sync?color=c91cb8)

Run AdGuard-Sync based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Description
With this image you can sync from a master AdGuard server to other AdGuard servers, so you can run AdGuard high available, but control it from  a single instance instead of each one.

## Volumes
* **/adguard-sync/etc** - Directory of config.yaml

## Run
```shell
docker run --name adguard-sync \
  -p 8080:8080/tcp \
  -v .../etc:/adguard-sync/etc \
  -d 11notes/adguard-sync:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /adguard-sync | home directory of user docker |
| `api` | http://${IP}:8080 | endpoint |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

## Parent image
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

## Built with (thanks to)
* [adguardhome-sync](https://github.com/bakito/adguardhome-sync)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)