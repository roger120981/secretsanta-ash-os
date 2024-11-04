#!/usr/bin/env bash

set -eu

# echo $0

case $1 in
  "migrate")
    exec bin/migrate
    ;;

  *)
    PHX_SERVER=true exec bin/${REL_NAME} "$@"
    ;;
esac
