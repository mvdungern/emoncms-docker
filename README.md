Docker image for running [emoncms](https://github.com/emoncms/emoncms) on [Unraid](https://unraid.net).

This image assumes you already have the following instances handy: MySQL/MariaDB, Redis and MQTT.

# Quick start

Though this image is meant to be used via the [Unraid app template](https://github.com/mattheworres/docker-templates) you could certainly use it to spin up an instance of emoncms, though it would require running instances of MQTT, Redis and MySQL as well. If this seems like a lot of work, it is. Maybe try the [base emoncms docker image](https://github.com/emoncms/emoncms-docker)?

```bash
git clone https://github.com/mattheworres/emoncms-docker
docker pull mattheworres/emoncms:latest

docker run -d \
    --name emoncms \
    -p 127.0.0.1:80:8080/tcp \
    -v /local/path/to/phpfina:/var/opt/emoncms/phpfina/ \
    -v /local/path/to/phptimeseries:/var/opt/emoncms/phptimeseries/ \
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
    mattheworres/emoncms
```

**That's it! Emoncms should now be running in Docker container, browse to [http://localhost:8080](http://localhost:8080)**


#### Customise config

##### MYSQL Database Credentials

For development the default settings in `default.docker.env` are used. For production a `.env` file should be created with secure database Credentials. See Production setup info below.

##### PHP Config

Edit `config/php.ini` to add custom php settings e.g. timezone (default `America/New_York`)

#### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`emon-phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container. See below for how to list and remove docker volumes.

## Building the :latest image
```bash
cd /this/directory
docker build -t mattheworres/emoncms:latest .
```

## Pushing to docker hub 

From: https://docs.docker.com/docker-hub/repos/

```bash
docker login --username=yourhubusername --email=youremail@company.com
docker tag mattheworres/emoncms:latest mattheworres/emoncms:<tag-name>
docker push mattheworres/emoncms:<tag-name>
```

Tag name should be the Emoncms version e.g 11.x.x

Also push the latest version using `latest` tag

```bash
docker tag mattheworres/emoncms:<latest-version>
docker tag mattheworres/emoncms:latest
```
