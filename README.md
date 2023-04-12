# About

Docker image for running [Emoncms](https://github.com/emoncms/emoncms). Very much a work in progress built for my own dockerfile/github learnings. Used mostly with an Iotawatt device, any feedback on other compatible devices would be appreciated. 

This image was originally forked from [mattheworres](https://github.com/mattheworres/emoncms-docker) Unraid docker - if using Unraid definitely start there as a template is provided.

The image assumes you already have the following instances running and properly configured if desired: MySQL or MariaDB (required), Redis (optional but recommended), and MQTT (only required if using devices requiring it).

# Quick start

Image works well with the docker setups given by [Marius Hosting](https://mariushosting.com/docker/) for use on a Synology NAS, but should work elsewhere.

The following Enviroment Settings are exposed during creation


| Setting | Function | Default |
| :----: | --- | --- |
|`EMONCMS_DOMAIN`| Default domain of Emoncms, for security |`false`|
|`MYSQL_HOST`| Host of MySQL/Maria | `127.0.0.1` |
|`MYSQL_PORT`| MySQL/MariaDB Port| `3306` |
|`MYSQL_DATABASE`| Name of database inside MySQL/MariaDB |`emoncms`|
|`MYSQL_USER`| Username of Emoncms | `emoncms` |
|`MYSQL_PASSWORD`| MYSQL/MariaDB Password | `YOUR_SECURE_PASSWORD` |
|`MYSQL_RANDOM_ROOT_PASSWORD`| Generate a random root password for MySQL/MariaDB | `yes` |
|`MYSQL_INITDB_SKIP_TZINFO`| Ignore TZ info in MySQL | `true` |
|`REDIS_ENABLED`| Enable Redis support (recommended) |`true`|
|`REDIS_HOST`| Redis Host | `127.0.0.1` |
|`REDIS_PORT`| Redis Port | `6379` |
|`REDIS_PREFIX`| Prefix attached to Redis |`emoncms`|
|`MQTT_ENABLED`| Enable MQTT Support (required only if using OpenEnergyMonitor devices) |`true`|
|`MQTT_HOST`| MQTT Host |`localhost`|
|`MQTT_PORT`| MQTT Port | `1883` |
|`MQTT_USER`| MQTT Username |`YOUR_MQTT_USER`|
|`MQTT_PASSWORD`| MQTT Password |`YOUR_MQTT_PASSWORD`|
|`MQTT_BASETOPIC`| MQTT Topic |`emon`|
|`MQTT_CLIENT`| MQTT Client ID | `emoncms` |
|`MULTI_USER`|Enable multiuser in EmonCMS. Set to false after all users have been made if accessable from the internet as no method exists to disable new signups from EmonCMS|`false`|
|`PASSWORD_RESET`|Allows users to reset their own passwords|`false`|
|`TZ`| Timezone | `America/Toronto` |
|`LOG_LEVEL`| Sets the logging level with 1=INFO, 2=WARN, 3=ERROR | `2` |

As well as presenting a build ARG `VERSION`, if set to `master` this will pull the Emoncms master source as it currently exists; otherwise will grab the latest stable release. All  modules are grabbed as master source regardless of version due to their slower development pace vs. the master course.

Two feed volumes are also capable to being set to persistant to survive docker upgrades, link to wherever you need to store data.

* `/var/opt/emoncms/phpfina/`
* `/var/opt/emoncms/phptimeseries/`

Default Port is 80, recommend setting to something else in order to not interfere with other containers.

Versions are tagged to a version number with an internal release number attached (ie `11.3.0-3`) with the `latest` tag tracking the latest stable release. A `master` tag will be produced at the same time tracking the latest source code revisions but this would be a *very* YMMV and should be avoided unless required.

The easiest way to spin up an instance is to modify and run the following or the included docker-compose.yml

```bash
docker pull mvdungern/emoncms:latest

docker run -d \
    --name emoncms \
    -p port_of_choice:80 \
    -v /local/path/to/phpfina:/var/opt/emoncms/phpfina/ \
    -v /local/path/to/phptimeseries:/var/opt/emoncms/phptimeseries/ \
    -e EMONCMS_DOMAIN=false \ 
    -e MYSQL_HOST=127.0.0.1 \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USER=emoncms \
    -e MYSQL_PASSWORD=my_secure_password \
    -e MYSQL_DATABASE=emoncms \
    -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
    -e REDIS_HOST=127.0.0.1 \
    -e REDIS_ENABLED=yes \
    -e REDIS_PORT=6379 \
    -e REDIS_PREFIX='emoncms' \
    -e MQTT_ENABLED=yes \
    -e MQTT_HOST=127.0.0.1 \
    -e MQTT_PORT=1883 \
    -e MQTT_USER=emoncms \
    -e MQTT_PASSWORD=my_secure_password \
    -e MQTT_BASETOPIC=emon \
    -e MQTT_CLIENT=emoncms \
    -e MULTI_USER=false \
    -e PASSWORD_RESET=false \
    -e TZ=YOUR/TIMEZONE \
    -e LOG_LEVEL=2 \
    mvdungern/emoncms
```
