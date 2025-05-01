![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# ADGUARD-SYNC
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-ADGUARD-SYNC)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![size](https://img.shields.io/docker/image-size/11notes/adguard-sync/0.7.5?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/adguard-sync/0.7.5?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/adguard-sync?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-ADGUARD-SYNC?color=7842f5">](https://github.com/11notes/docker-ADGUARD-SYNC/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxwYXRoIGQ9Im0wIDBoMzJ2MzJoLTMyeiIgZmlsbD0iI2YwMCIvPjxwYXRoIGQ9Im0xMyA2aDZ2N2g3djZoLTd2N2gtNnYtN2gtN3YtNmg3eiIgZmlsbD0iI2ZmZiIvPjwvc3ZnPg==)

Sync multiple adguard instances on a schedule for high-availability

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [0.7.5](https://hub.docker.com/r/11notes/adguard-sync/tags?name=0.7.5)
* [stable](https://hub.docker.com/r/11notes/adguard-sync/tags?name=stable)
* [latest](https://hub.docker.com/r/11notes/adguard-sync/tags?name=latest)

# REPOSITORIES ☁️
```
docker pull 11notes/adguard-sync:0.7.5
docker pull ghcr.io/11notes/adguard-sync:0.7.5
docker pull quay.io/11notes/adguard-sync:0.7.5
```

![API](https://github.com/11notes/docker-adguard-sync/blob/master/img/API.png?raw=true)

# SYNOPSIS 📖
**What can I do with this?** If you want to run [11notes/adguard](https://github.com/11notes/docker-adguard) high-available you need something to synchronize the settings between the two or more instances. [adguardhome-sync](https://github.com/bakito/adguardhome-sync) solves this issue by copying all settings from a master to infinite slaves.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! All the other images on the market that do exactly the same don’t do or offer these options:

> [!IMPORTANT]
>* This image runs as 1000:1000 by default, most other images run everything as root
>* This image has no shell since it is 100% distroless, most other images run on a distro like Debian or Alpine with full shell access (security)
>* This image does not ship with any critical or high rated CVE and is automatically maintained via CI/CD, most other images mostly have no CVE scanning or code quality tools in place
>* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
>* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
>* This image works as read-only, most other images need to write files to the image filesystem

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used one.

| image | 11notes/adguard-sync:0.7.5 | lscr.io/linuxserver/adguardhome-sync:v0.7.5-ls136 |
| ---: | :---: | :---: |
| image size on disk | 9.85MB | 44.2MB |
| process UID/GID | 1000/1000 | 0:0 |
| distroless? | ✅ | ❌ |


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
    image: "11notes/adguard-sync:0.7.5"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "etc:/adguard/etc"
    ports:
      - "3000:3000/tcp"
    networks:
      frontend:
    restart: "always"

  adguard-master:
    image: "11notes/adguard:0.107.59"
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
    image: "11notes/adguard:0.107.59"
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
  etc:

networks:
  frontend:
```

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

# SOURCE 💾
* [11notes/adguard-sync](https://github.com/11notes/docker-ADGUARD-SYNC)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates
>* [11notes/distroless:curl](https://github.com/11notes/docker-distroless/blob/master/curl.dockerfile) - app to execute HTTP or UNIX requests

# BUILT WITH 🧰
* [adguardhome-sync](https://github.com/bakito/adguardhome-sync)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# CAUTION ⚠️
> [!CAUTION]
>* This image comes with a default configuration with a default password for the admin account. Please set your own password or provide your own configuration.

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-adguard-sync/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-adguard-sync/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-adguard-sync/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 28.04.2025, 01:13:29 (CET)*