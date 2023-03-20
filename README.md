# About

Docker image for running [Emoncms](https://github.com/emoncms/emoncms). Very much a work in progress built for my own dockerfile/github learnings. Used mostly with an Iotawatt device, any feedback on other compatible devices would be appreciated.

Originally forked from [mattheworres](https://github.com/mattheworres/emoncms-docker) Unraid docker - if using Unraid definitely start there

This image assumes you already have the following instances running and properly configured: MySQL or MariaDB, Redis, and MQTT.

# Quick start

Image was designed to work wth the examples on [Marius Hosting](https://mariushosting.com/docker/) for a Synology NAS, but should work elsewhere with some fine tuning.

The following Enviroment Settings are exposed during creation


| Setting | Function | Default |
| :----: | --- | --- |
|`EMONCMS_DOMAIN`| Default domain of Emoncms, for security |`false`|
|`MYSQL_HOST`| Host of MySQL/Maria | `127.0.0.1` |
|`MYSQL_PORT`| MySQL/MariaDB Port| `3306` |
|`MYSQL_USER`| Username of Emoncms | `emoncms` |
|`MYSQL_PASSWORD`| MYSQL/MariaDB Password | `YOUR_SECURE_PASSWORD` |
|`MYSQL_RANDOM_ROOT_PASSWORD`| Generate a random root password for MySQL/MariaDB | `yes` |
|`MYSQL_INITDB_SKIP_TZINFO`| Ignore TZ info in MySQL | `true` |
|`REDIS_ENABLED`| Enable Redis support (required) |`true`|
|`REDIS_HOST`| Redis Host | `127.0.0.1` |
|`REDIS_PORT`| Redis Port | `6379` |
|`REDIS_PREFIX`| Prefix attached to Redis |`emoncms`|
|`MQTT_ENABLED`| Enable MQTT Support (required if using OpenEnergyMonitor devices) |`true`|
|`MQTT_HOST`| MQTT Host |`localhost`|
|`MQTT_USER`| MQTT Username |`YOUR_MQTT_USER`|
|`MQTT_PASSWORD`| MQTT Password |`YOUR_MQTT_PASSWORD`|
|`MQTT_BASETOPIC`| MQTT Topic |`emon`|
|`PHPFINA_DIR`| phpFina inside dockerfile|`/var/opt/emoncms/phpfina/`|
|`PHPTIMESERIES_DIR`|phpTimeseries inside dockerfile|`/var/opt/emoncms/phptimeseries/`|
|`MULTI_USER`|Enable multiuser in EmonCMS. Set to false after all users have been made if accessable from the internet as no method exists to disable new signups from EmonCMS|`false`|
|`PASSWORD_RESET`|Allows users to reset their own passwords|`false`|
|`TZ`| Timezone | `America/Toronto` |

Two feed volumes are also capable to being set to persistant to survive docker upgrades, link to wherever you need to store data.

* /var/opt/emoncms/phpfina/
* /var/opt/emoncms/phptimeseries/

Default Port is 80, recommend setting to something else (ie 8998) in order to not interfere with other containers.

Easiest way to spin up an instance is to execute the following under a shell or as a scheduled task script.

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
    -e PHPFINA_DIR=/var/opt/emoncms/phpfina/ \
    -e PHPTIMESERIES_DIR=/var/opt/emoncms/phptimeseries/ \
    -e MULTI_USER=false
    -e PASSWORD_RESET=false
    -e TZ=YOUR/TIMEZONE
    mvdungern/emoncms
```