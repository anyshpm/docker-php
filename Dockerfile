FROM php:7.4.33-fpm-alpine3.15

RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.15/main' > /etc/apk/repositories
RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.15/community' >> /etc/apk/repositories

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
    && docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir \
    && docker-php-ext-install -j$(nproc) intl mysqli pdo pdo_mysql bcmath zip gd xml opcache mbstring gmp sodium posix sockets \
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
    && rm -rf /tmp/pear ~/.pearrc
