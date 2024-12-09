#!/usr/bin/env bash

set -eu

case $1 in
  "alpine")
    DOCKERFILE="./Dockerfile.alpine"
    TAG_SUFFIX="alpine"

    echo "Building alpine image..."
    ;;

  *)
    DOCKERFILE="./Dockerfile.debian-slim"
    TAG_SUFFIX="debian-slim"

    echo "Building debian-slim image..."
    ;;
esac

export GIT_VERSION_SHA=$(exec ./minimal-git-sha.sh)

mix compile

PROJECT_VERSION=$(mix santa.print_version | tail -n 1)

echo "Project version: ${PROJECT_VERSION}"

FULL_TAG="ss-api:${PROJECT_VERSION}-${TAG_SUFFIX}"

echo "Building ${FULL_TAG}"

docker build --progress=plain \
  -t "${FULL_TAG}" \
  -f "${DOCKERFILE}" \
  . 2>&1 | tee docker.build.log
