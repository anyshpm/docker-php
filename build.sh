#!/bin/sh

#PHP_VERSION=
#ALPINE_VERSION=
TAG=$(grep FROM Dockerfile | sed 's/^FROM[ \t]\+php://g' | sed 's/[ \t#].*//g')

#docker build --force-rm -t anyshpm/php:$TAG .
docker buildx build -t anyshpm/php:$TAG --platform linux/amd64,linux/arm64 --push .
