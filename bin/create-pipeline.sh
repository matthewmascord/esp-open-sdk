#!/usr/bin/env bash
PROJECT=esp-open-sdk
if [ -z "${CIRCLE_TOKEN}" ]; then
  echo "CIRCLE_TOKEN not set"
  exit 1
fi
if [ -z "${GITHUB_USERNAME}" ]; then
  echo "GITHUB_USERNAME not set"
  exit 1
fi
if [ -z "${DOCKERHUB_USERNAME}" ]; then
  echo "DOCKERHUB_USERNAME not set"
  exit 1
fi
if [ -z "${DOCKERHUB_TOKEN}" ]; then
  echo "DOCKERHUB_TOKEN not set"
  exit 1
fi
ENDPOINT=https://circleci.com/api/v1.1/project/github/"$GITHUB_USERNAME"/$PROJECT
curl -X POST \
  "$ENDPOINT"/follow?circle-token="$CIRCLE_TOKEN" && \
curl -X POST \
  --header "Content-Type: application/json" \
  -d '{"name":"DOCKERHUB_USERNAME", "value":"'"$DOCKERHUB_USERNAME"'"}' \
  "$ENDPOINT"/envvar?circle-token="$CIRCLE_TOKEN"
curl -X POST \
  --header "Content-Type: application/json" \
  -d '{"name":"DOCKERHUB_TOKEN", "value":"'"$DOCKERHUB_TOKEN"'"}' \
  "$ENDPOINT"/envvar?circle-token="$CIRCLE_TOKEN"