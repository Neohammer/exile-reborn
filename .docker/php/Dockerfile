FROM php:8.5-fpm

# Image de développement : Xdebug et display_errors sont activés à dessein.
# Une image de production distincte devra les désactiver (voir
# docs/development/technical-debt.md#xdebug et #opcache).

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        zip \
        libpq-dev \
        libzip-dev \
        libicu-dev \
        $PHPIZE_DEPS \
    && docker-php-ext-install \
        pdo_pgsql \
        intl \
        zip \
    && pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/php \
    && chown www-data:www-data /var/log/php

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY php.ini /usr/local/etc/php/php.ini
COPY conf.d/ /usr/local/etc/php/conf.d/

RUN php --version \
    && composer --version

CMD ["php-fpm"]