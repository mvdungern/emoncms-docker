# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
FROM php:8.1-apache

# Set ARG for build version
ARG VERSION=stable

# Hardcoded variable for Emoncms domain, enable for security if required 
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
ENV MQTT_USER=YOUR_MQTT_USER
ENV MQTT_PASSWORD=YOUR_MQTT_PASSWORD
ENV MQTT_BASETOPIC='emon'


# Set feed engine ENVs
ENV PHPFINA_DIR=/var/opt/emoncms/phpfina/
ENV PHPTIMESERIES_DIR=/var/opt/emoncms/phptimeseries/

# Set Emoncms interface option ENVs
ENV MULTI_USER=false
ENV PASSWORD_RESET=false

# Set Timezone ENV
ENV TZ=America/Toronto

# Install deps
RUN apt-get update && apt-get install -y \
              libcurl4-openssl-dev \
              libmosquitto-dev \
              gettext \
              nano \
              git-core

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysqli gettext
RUN pecl install redis \
    \ && docker-php-ext-enable redis
    
# Mosquitto appears to be broken; removing PHP support until fixed
# RUN pecl install Mosquitto-beta \
#     \ && docker-php-ext-enable mosquitto

RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# Add custom Apache config
COPY config/apache.emoncms.conf /etc/apache2/sites-available/emoncms.conf
RUN a2dissite 000-default.conf
RUN a2ensite emoncms

# Clone in stable Emoncms repo & modules - overwritten in development with local FS files. Use stable repo unless build-arg set to master

RUN mkdir /var/www/emoncms
RUN if [ "$VERSION" = "master" ]; then \
    git clone https://github.com/emoncms/emoncms.git /var/www/emoncms \
    && echo "building from master"; \
  else \
    git clone --single-branch --branch stable https://github.com/emoncms/emoncms.git /var/www/emoncms \
    && echo "building 11.3.0 stable"; \
  fi
# Commment old tar.gz pull to grab stable tree instead
# wget -c https://github.com/emoncms/emoncms/archive/refs/tags/11.3.0.tar.gz -O - | tar -xz --strip-components=1 -C /var/www/emoncms \
RUN git clone https://github.com/emoncms/dashboard.git /var/www/emoncms/Modules/dashboard
RUN git clone https://github.com/emoncms/graph.git /var/www/emoncms/Modules/graph
RUN git clone https://github.com/emoncms/app.git /var/www/emoncms/Modules/app
RUN git clone https://github.com/emoncms/device.git /var/www/emoncms/Modules/device

# Add custom emoncms config
COPY docker.settings.ini /var/www/emoncms/settings.ini

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