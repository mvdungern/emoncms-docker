Docker image for running [emoncms](https://github.com/emoncms/emoncms). Very much a work in progress built for my own dockerfile learnings. Forked from [mattheworres](https://github.com/mattheworres/emoncms-docker) Unraid docker.

This image assumes you already have the following instances running: MySQL/MariaDB, Redis and MQTT.

# Quick start

Image works with the excellent [Marius Hosting](https://mariushosting.com/docker/) docker images for Synology, but will work with many other systems with some fine tuning. Easiest way to spin up a version is to execute teh following under a shell or as a scheduled task script.

```bash
docker pull mvdungern/emoncms:latest

docker run -d
    --name emoncms
    -p 127.0.0.1:80:8998/tcp \
    -v /local/path/to/phpfina:/var/opt/emoncms/phpfina/
    -v /local/path/to/phptimeseries:/var/opt/emoncms/phptimeseries/
    -e MYSQL_HOST=127.0.0.1
    -e MYSQL_PORT=3306
    -e MYSQL_USER=emoncms
    -e MYSQL_PASSWORD=my_secure_password
    -e MYSQL_DATABASE=emoncms
    -e MYSQL_RANDOM_ROOT_PASSWORD=yes
    -e REDIS_ENABLED=yes
    -e REDIS_PORT=6379
    -e REDIS_PREFIX='emoncms'
    -e MQTT_ENABLED=yes
    -e MQTT_HOST=127.0.0.1
    -e MQTT_PORT=1883
    -e MQTT_USER=emoncms
    -e MQTT_PASSWORD=my_secure_password
    -e MQTT_BASETOPIC=emon
    -e PHPFINA_DIR=/var/opt/emoncms/phpfina/
    -e PHPTIMESERIES_DIR=/var/opt/emoncms/phptimeseries/
    emoncms
```

Emoncms should now be running in Docker container, browse to [http://localhost:8998](http://localhost:8998)**


#### Customise config

##### MYSQL Database Credentials

For development the default settings in `default.docker.env` are used. For production a `.env` file should be created with secure database Credentials. See Production setup info below.

##### PHP Config

Edit `config/php.ini` to add custom php settings e.g. timezone (default `America/New_York`)

#### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`emon-phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container. See below for how to list and remove docker volumes.
