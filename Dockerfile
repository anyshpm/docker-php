FROM php:8.0.30-fpm-alpine3.16

#RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.17/main' > /etc/apk/repositories
#RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.17/community' >> /etc/apk/repositories

RUN set -x \
    && apk update \
    && apk add  --no-cache --virtual .phpize-deps \
               libtool \
               $PHPIZE_DEPS \
               icu-dev \
               libzip-dev \
               libpng-dev \
               libjpeg-turbo-dev \
               libxml2-dev \
               oniguruma-dev \
               gmp-dev \
               libsodium-dev \
               freetype-dev \
               imagemagick-dev \
               linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg\
    && docker-php-ext-install -j$(nproc) intl mysqli pdo pdo_mysql bcmath zip gd xml opcache mbstring gmp sodium posix pcntl sysvsem sockets \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del .phpize-deps \
    && apk add --no-cache --virtual .php-runtime-deps \
               git \
               sudo \
               icu-libs \
               libzip \
#               libpng \
#               libxml2 \
#               oniguruma \
#               gmp \
#               libsodium \
#               freetype \
               libgomp \
               imagemagick \
    && rm -rf /tmp/pear ~/.pearrc \
    && curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
