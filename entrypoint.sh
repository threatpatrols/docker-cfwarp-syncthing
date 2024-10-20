#!/bin/bash

# exit when any command fails
set -e

source /scripts/config-vars.sh

if [ -n "${DEBUG}" ]; then
  set -x
fi

/scripts/warp-connect.sh
/scripts/warp-show-status.sh
/scripts/syncthing-start.sh

while true; do
  if [ $(pgrep -c syncthing) -lt 1 ]; then
    echo 'INFO: syncthing process not running, exiting now.'
    exit 1
  fi
  if [ $(pgrep -c warp-svc) -lt 1 ]; then
    echo 'INFO: warp-svc process not running, exiting now.'
    exit 1
  fi
  sleep 10
done
