#!/usr/bin/env bash

set -eu

case $2 in
  "alpine")
    TAG_SUFFIX="alpine"
    ;;

  *)
    TAG_SUFFIX="debian-slim"
    ;;
esac

DATABASE_CONTAINER_NAME=${3:-psql-elixir}
DATABASE_URL=${2:-ecto://postgres:postgres@${DATABASE_CONTAINER_NAME}/secret_santa_prod}

COMMAND=${1:-start}
IMAGE_NAME="ss-api:$(mix santa.print_version | tail -n 1)-${TAG_SUFFIX}"

HOST_PORT="8000"
PHX_HOST="secretsanta.simpers.codes"
PORT="8000"
SENDER_EMAIL="noreply@${PHX_HOST}"
SECRET_KEY_BASE="rI1uld0iD9ZcQ+kEnQ/O6IdvI28gxuebSzCc1QGLkLg+AKjPBXHdD/WW9w7ZCDH9"

docker run -d \
  -e DATABASE_URL=${DATABASE_URL} \
  -e PORT=${PORT} \
  -e PHX_HOST=${PHX_HOST} \
  -e SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  -e SENDER_EMAIL=${SENDER_EMAIL} \
  -p ${HOST_PORT}:${PORT} \
  --link ${DATABASE_CONTAINER_NAME} \
  --name ss-api \
  ${IMAGE_NAME} ${COMMAND}
