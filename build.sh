#!/bin/sh

PHP_VERSION=7.3.33
ALPINE_VERSION=alpine3.15
TAG=$PHP_VERSION-fpm-$ALPINE_VERSION

#docker build --force-rm -t anyshpm/php:$TAG .
docker buildx build -t anyshpm/php:$TAG --platform linux/amd64,linux/arm64 --push .
