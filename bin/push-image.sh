#!/usr/bin/env bash
docker login && \
docker push "$DOCKERHUB_USERNAME"/esp8266-sdk-build:0.0.1
