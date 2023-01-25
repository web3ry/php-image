ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm
LABEL name="Webery PHP-FPM ${PHP_VERSION}"

ARG upload_max_filesize
ARG timezone

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

## Install default OS packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
      curl \
      vim \
      librabbitmq-dev

# Install PHP extensions
RUN install-php-extensions \
      bcmath \
      bz2 \
      gd \
      intl \
      zip \
      xml \
      mbstring \
      pdo \
      pdo_mysql \
      imagick

# Add Upload max file to PHP
RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = ${upload_max_filesize};" >> /usr/local/etc/php/conf.d/uploads.ini

# Add Timezone PHP Config
RUN printf "[PHP]\ndate.timezone = ${timezone}\n" > /usr/local/etc/php/conf.d/tzone.ini

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && docker-php-ext-enable apcu \
    && pecl clear-cache

## PHP AMQP install
RUN pecl install amqp \
    && docker-php-ext-enable amqp \
    && pecl clear-cache

#OS Timezone Settings
RUN ln -snf /usr/share/zoneinfo/${timezone} /etc/localtime && echo ${timezone} > /etc/timezone

# Worddir set
WORKDIR /app
# Change www-data user home dir
RUN usermod -d /app www-data

#Create var dir
RUN mkdir var

# Default Permission and User
RUN chown www-data:www-data -R /app
USER www-data
