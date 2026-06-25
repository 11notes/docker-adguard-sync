![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# ADGUARD-SYNC
![size](https://img.shields.io/badge/image_size-21MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/adguard-sync?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-adguard-sync?color=7842f5">](https://github.com/11notes/docker-adguard-sync/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

run adguard-sync rootless and distroless.

# INTRODUCTION 📢

Synchronize AdGuard Home config to replicas

![API](https://github.com/11notes/docker-adguard-sync/blob/master/img/API.png?raw=true)

# SYNOPSIS 📖
**What can I do with this?** If you want to run [11notes/adguard](https://github.com/11notes/docker-adguard) high-available you need something to synchronize the settings between the two or more instances. [adguardhome-sync](https://github.com/bakito/adguardhome-sync) solves this issue by copying all settings from a master to infinite slaves. This image provides this functionality to you, [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md).

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/adguard-sync | 21MB | 1000:1000 | ✅ | amd64, arm64, armv7 |
| linuxserver/adguardhome-sync | 49MB | 0:0 | ❌ | amd64, arm64 |

# DEFAULT CONFIG 📑
```yaml
cron: "*/15 * * * *"
runOnStart: true
continueOnError: false

origin:
  url: http://adguard-master:3000
  username: admin
  password: adguard

replicas:
  - url: http://adguard-slave:3000
    username: admin
    password: adguard

api:
  port: 3000
  username: admin
  password: adguard
  darkMode: true
  metrics:
    enabled: true
    scrapeInterval: 10s
    queryLogLimit: 10000

features:
  generalSettings: true
  queryLogConfig: true
  statsConfig: true
  clientSettings: true
  services: true
  filters: true
  dhcp:
    serverConfig: true
    staticLeases: true
  dns:
    serverConfig: true
    accessLists: true
    rewrites: true
```

# VOLUMES 📁
* **/adguard-sync/etc** - Directory of the configuration file

# COMPOSE ✂️
```yaml
name: "adguard-sync"
services:
  adguard-sync:
    depends_on:
      adguard-master:
        condition: "service_healthy"
        restart: true
      adguard-slave:
        condition: "service_healthy"
        restart: true
    image: "11notes/adguard-sync:0.9.2"
    read_only: true
    security_opt:
      no-new-privileges: true
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "adguard-sync.etc:/adguard-sync/etc"
    ports:
      - "3000:3000/tcp"
    networks:
      frontend:
    restart: "always"

  adguard-master:
    image: "11notes/adguard:0.107.63"
    environment:
      TZ: "Europe/Zurich"
    ports:
      - "1053:53/udp"
      - "1053:53/tcp"
      - "3001:3000/tcp"
    networks:
      frontend:
    restart: "always"

  adguard-slave:
    image: "11notes/adguard:0.107.63"
    environment:
      TZ: "Europe/Zurich"
    ports:
      - "2053:53/udp"
      - "2053:53/tcp"
      - "3002:3000/tcp"
    networks:
      frontend:
    restart: "always"

volumes:
 adguard-sync.etc:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /adguard-sync | home directory of user docker |
| `API login` | admin // adguard | login using default config |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [0.9.2](https://hub.docker.com/r/11notes/adguard-sync/tags?name=0.9.2)
* [0.9.2-unraid](https://hub.docker.com/r/11notes/adguard-sync/tags?name=0.9.2-unraid)
* [0.9.2-nobody](https://hub.docker.com/r/11notes/adguard-sync/tags?name=0.9.2-nobody)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:0.9.2``` you can use ```:0``` or ```:0.9```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/adguard-sync:0.9.2
docker pull ghcr.io/11notes/adguard-sync:0.9.2
docker pull quay.io/11notes/adguard-sync:0.9.2
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000.

# NOBODY VERSION 👻
This image supports nobody by default. Simply add **-nobody** to any tag and the image will run as 65534:65534 instead of 1000:1000.

# SOURCE 💾
* [11notes/adguard-sync](https://github.com/11notes/docker-adguard-sync)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates, nothing else
>* [11notes/distroless:curl](https://github.com/11notes/docker-distroless/blob/master/curl.dockerfile) - app to execute HTTP requests

# BUILT WITH 🧰
* [adguardhome-sync](https://github.com/bakito/adguardhome-sync)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# CAUTION ⚠️
> [!CAUTION]
>* This image comes with a default configuration with a default password for the admin account. Please set your own password or provide your own configuration

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-adguard-sync/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-adguard-sync/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-adguard-sync/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 25.06.2026, 06:03:32 (CET)*