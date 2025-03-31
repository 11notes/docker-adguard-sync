${{ image: API.png }}

${{ content_synopsis }} If you want to run [11notes/adguard](https://github.com/11notes/docker-adguard) high-available you need something to synchronize the settings between the two or more instances. [adguardhome-sync](https://github.com/bakito/adguardhome-sync) solves this issue by copying all settings from a master to infinite slaves.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image has no shell since it is 100% distroless, most other images run on a distro like Debian or Alpine with full shell access (security)
${{ github:> }}* This image does not ship with any critical or high rated CVE and is automatically maintained via CI/CD, most other images mostly have no CVE scanning or code quality tools in place
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ title_config }}
```yaml
${{ include: ./rootfs/adguard-sync/etc/config.yaml }}
```

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of the configuration file

${{ content_compose }}

${{ content_defaults }}
| `API login` | admin // adguard | login using default config |

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}

${{ title_caution }}
${{ github:> [!CAUTION] }}
${{ github:> }}* This image comes with a default SSL certificate. If you plan to expose the web interface via HTTPS, please replace the default certificate with your own or use a reverse proxy
${{ github:> }}* This image comes with a default configuration with a default password for the admin account. Please set your own password or provide your own configuration.