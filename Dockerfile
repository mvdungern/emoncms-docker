# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
FROM php:8.1-apache

# Set ARG for build version
ARG VERSION=stable

# Set PHP extension versions to allow finer control of versions selected during build, mosquitto being grabbed from a fork so we'll use the current git
ARG EXT_REDIS_VERSION=5.3.7
ARG EXT_MOSQUITTO_VERSION=1.8.0

# Variable for Emoncms domain host, enable for additional security if required 
ENV EMONCMS_DOMAIN=false

# Set mySQL ENVs
ENV MYSQL_HOST=127.0.0.1
ENV MYSQL_PORT=3306
ENV MYSQL_DATABASE='emoncms'
ENV MYSQL_USER='emoncms'
ENV MYSQL_PASSWORD=YOUR_SECURE_PASSWORD
ENV MYSQL_RANDOM_ROOT_PASSWORD=yes
ENV MYSQL_INITDB_SKIP_TZINFO=true

# Set Redis ENVs
ENV REDIS_ENABLED=true
ENV REDIS_HOST=127.0.0.1
ENV REDIS_PORT=6379
# At the moment Docker doesn't honour the REDIS_AUTH variable, so it will always be passwordless
# REDIS_AUTH=
ENV REDIS_PREFIX='emoncms'

# Set MQTT ENVs
ENV MQTT_ENABLED=true
ENV MQTT_HOST='localhost'
ENV MQTT_PORT=1883
ENV MQTT_USER=YOUR_MQTT_USER
ENV MQTT_PASSWORD=YOUR_MQTT_PASSWORD
ENV MQTT_BASETOPIC='emon'
ENV MQTT_CLIENT='emoncms'

# Set Emoncms interface option ENVs
ENV MULTI_USER=false
ENV PASSWORD_RESET=true

#Set Emoncms logging level, usful during debugging
ENV LOG_LEVEL=2

# Set Timezone ENV
ENV TZ=America/Toronto

# Install deps
RUN apt-get update && apt-get install -y \
              libcurl4-openssl-dev \
              libmosquitto-dev \
              gettext \
              git-core \
              supervisor

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysqli gettext

# RUN docker-php-source extract &&\
#    docker-php-ext-get redis ${EXT_REDIS_VERSION} &&\
#    docker-php-ext-install redis

RUN docker-php-source extract \
    # grab and install nismoryco/Mosquitto-PHP fork; mgdm/Mosquitto-PHP appears to be abondonware and doesn't support PHP 8.x
    && mkdir -p /usr/src/php/ext/ \
    && mkdir /usr/src/php/mosquitto-php \
    && git clone https://github.com/nismoryco/Mosquitto-PHP.git /usr/src/php/ext/mosquitto-php \
    && docker-php-ext-install mosquitto-php \
    # grab and install redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/${EXT_REDIS_VERSION}.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-install redis \
    && docker-php-source delete

# Removing pecl installation, building from source
# RUN pecl install redis \
#    \ && docker-php-ext-enable redis

# Mosquitto pecl doesn't support PHP 8+, swapped to nismoryco fork
# RUN pecl install Mosquitto-beta \
#     \ && docker-php-ext-enable mosquitto

RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/php.ini

# Add custom Apache config
COPY config/apache.emoncms.conf /etc/apache2/sites-available/emoncms.conf
RUN a2dissite 000-default.conf
RUN a2ensite emoncms

# Clone in stable Emoncms repo & modules - overwritten in development with local FS files. Use stable repo unless build-arg set to master

RUN mkdir /var/www/emoncms

# Pull from stable or master branch based on VERSION build ARG and echo the decision

RUN if [ ${VERSION} = "master" ]; then \
    git clone https://github.com/emoncms/emoncms.git /var/www/emoncms ; \
  else \
    git clone --single-branch --branch stable https://github.com/emoncms/emoncms.git /var/www/emoncms ; \
  fi
RUN echo "Building from ${VERSION} branch"

# Commment old tar.gz pull to grab stable tree instead
# wget -c https://github.com/emoncms/emoncms/archive/refs/tags/11.3.0.tar.gz -O - | tar -xz --strip-components=1 -C /var/www/emoncms \

RUN git clone https://github.com/emoncms/dashboard.git /var/www/emoncms/Modules/dashboard
RUN git clone https://github.com/emoncms/graph.git /var/www/emoncms/Modules/graph
RUN git clone https://github.com/emoncms/app.git /var/www/emoncms/Modules/app
RUN git clone https://github.com/emoncms/device.git /var/www/emoncms/Modules/device

# Make the default directory 'safe' for git, cleans up the dubious ownership issue in apache logs

# RUN git config --global --add safe.directory /var/www/emoncms
# RUN git config --global --add safe.directory '*'

# Add custom emoncms config
COPY config/emoncms.settings.ini /var/www/emoncms/settings.ini

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/opt/emoncms
RUN mkdir /var/opt/emoncms/phpfina
RUN mkdir /var/opt/emoncms/phptimeseries
RUN chown www-data:root /var/opt/emoncms/phpfina
RUN chown www-data:root /var/opt/emoncms/phptimeseries

# Create Emoncms logfile
RUN mkdir /var/log/emoncms
RUN touch /var/log/emoncms/emoncms.log
RUN chmod 666 /var/log/emoncms/emoncms.log

# To start Apache and emoncms_mqtt from supervisord; from jamesfidells push to the offical emoncms-docker repo but fixed to prevent "Error: positional arguments are not supported"
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/runsupervisord.sh /usr/local/runsupervisord.sh
ENTRYPOINT [ "bash", "/usr/local/runsupervisord.sh" ]