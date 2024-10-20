#!/bin/bash

set -e

# Syncthing
# =============================================================================

# Start syncthing
binary=$(which syncthing)
setcap -r "${binary}" 2>/dev/null || true
setcap "$PCAP" "${binary}" 2>/dev/null || true
setcap "CAP_FOWNER=ep" "${binary}"

groupadd --gid "${STGID}" syncgroup
useradd --uid "${STUID}" --gid "${STGID}" --no-user-group --home-dir "${STSHARESDIR}" --no-create-home --shell "/bin/bash" syncuser

mkdir -p "${STDATADIR}" && chown syncuser:syncgroup "${STDATADIR}"
mkdir -p "${STCONFDIR}" && chown syncuser:syncgroup "${STCONFDIR}"
mkdir -p "${STSHARESDIR}" && chown syncuser:syncgroup "${STSHARESDIR}"
chown -R syncuser:syncgroup "${STBASEDIR}"

export _verbose_option=""
if [ -n "${DEBUG}" ]; then
  export _verbose_option="--verbose"
fi

# TODO: the sleep-waits below are far from ideal, might be improved using a function that performs a liveness test etc.
export _config_sleep_interval=3

su syncuser -c """
  set -e

  syncthing \
    ${_verbose_option} \
    --skip-port-probing \
    --no-restart \
    --no-upgrade \
    --no-default-folder \
    --no-browser \
    &
  sleep 5

  syncthing cli config gui insecure-admin-access set true
  sleep ${_config_sleep_interval}

  syncthing cli config gui insecure-skip-host-check set true
  sleep ${_config_sleep_interval}

  syncthing cli config gui insecure-allow-frame-loading set false
  sleep ${_config_sleep_interval}

  syncthing cli config options local-ann-enabled set false
  sleep ${_config_sleep_interval}

  syncthing cli config options announce-lanaddresses set false
  sleep ${_config_sleep_interval}

  syncthing cli config options insecure-allow-old-tlsversions set false
  sleep ${_config_sleep_interval}

"""

