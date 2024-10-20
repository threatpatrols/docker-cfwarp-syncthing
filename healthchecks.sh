#!/bin/bash

/scripts/warp-healthcheck.sh || exit 1
/scripts/syncthing-healthcheck.sh || exit 1

exit 0
