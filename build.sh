#!/bin/sh

PHP_VERSION=8.0.25
ALPINE_VERSION=alpine3.16
TAG=$PHP_VERSION-fpm-$ALPINE_VERSION

docker build --force-rm -t anyshpm/php:$TAG .
#docker buildx build -t anyshpm/php:$TAG --platform linux/amd64,linux/arm64 --push .
