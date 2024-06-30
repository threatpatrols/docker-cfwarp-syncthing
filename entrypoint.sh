#!/bin/bash

# exit when any command fails
set -e

# create a tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# manually accept the tos
mkdir -p ~/.local/share/warp
printf 'yes' > ~/.local/share/warp/accepted-tos.txt
printf 'yes' > ~/.local/share/warp/accepted-teams-tos.txt

# start the daemon
warp-svc | grep -v DEBUG | grep -v FileNotFound &
warp-cli --version

# sleep to wait for the daemon to start, default 5 seconds
sleep "${WARP_START_DELAY:-5}"

# if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    printf "Registering new Warp client: "
    warp-cli registration new

    # if a license key is provided, register the license
    if [ -n "$WARP_LICENSE_KEY" ]; then
        printf "Registering Warp license: "
        warp-cli set-license "$WARP_LICENSE_KEY"
    fi

    # set warp mode
    printf "Setting Warp DNS families mode off: "
    warp-cli dns families off

else
    printf "Warp client already registered, skipping registration\n"
fi

# connect to the warp server
printf "Connecting Warp client: "
warp-cli connect

# Wait reasonably for warp to become connected
sleep 5
_cfwarp_connected=false
for i in $(seq 1 20); do
  if [[ $(curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -cE "warp=(plus|on)") -gt 0 ]]; then
    _cfwarp_connected=true
    break
  else
    printf 'Waiting for warp connection...\n'
    sleep 5
  fi
done

# Exit if we did not get a _cfwarp_connected=true
if [[ ${_cfwarp_connected} != true ]]; then
  printf "\nERROR: unable to obtain Warp connection!\n"
  exit 1
fi

# Syncthing
# =============================================================================

# Start syncthing
binary=$(which syncthing)
setcap -r "${binary}" 2>/dev/null || true
setcap "$PCAP" "${binary}" 2>/dev/null || true
setcap "CAP_FOWNER=ep" ${binary}

export PUID=${PUID:=1000}
export PGID=${PGID:=1000}
export STBASEDIR="${STBASEDIR:="/var/syncthing"}"

export STDATADIR="${STDATADIR:="${STBASEDIR}/data"}"
export STSHARESDIR="${STSHARESDIR:="${STBASEDIR}/shares"}"
export STCONFDIR="${STCONFDIR:="${STBASEDIR}/config"}"
export STGUIADDRESS="${STGUIADDRESS:="0.0.0.0:8384"}"

# Output some connection info
printf "\n\n"
curl --silent "https://ipinfo.io/json" || true
printf "\n\n"

# Output config info
printf "PUID         : %s\n" "${PUID}"
printf "PGID         : %s\n" "${PGID}"
printf "STDATADIR    : %s\n" "${STDATADIR}"
printf "STCONFDIR    : %s\n" "${STCONFDIR}"
printf "STSHARESDIR  : %s\n" "${STSHARESDIR}"
printf "STGUIADDRESS : %s\n" "${STGUIADDRESS}"
printf "\n"

groupadd --gid "${PGID}" syncgroup || true
useradd --uid "${PUID}" --gid "${PGID}" --no-user-group --home-dir "${STSHARESDIR}" --no-create-home --shell "/bin/bash" syncuser || true

chown syncuser:syncgroup "${HOME}"
mkdir -p "${STDATADIR}" && chown syncuser:syncgroup "${STDATADIR}"
mkdir -p "${STCONFDIR}" && chown syncuser:syncgroup "${STCONFDIR}"
mkdir -p "${STSHARESDIR}" && chown syncuser:syncgroup "${STSHARESDIR}"

# TODO: this sleep-waits are far from ideal, might be improved in a function that performs a liveness test etc.

su syncuser -c """
  set -e

  syncthing \
    --verbose \
    --skip-port-probing \
    --no-restart \
    --no-upgrade \
    --no-default-folder \
    --no-browser \
    &
  sleep 5

  syncthing cli config gui insecure-admin-access set true
  sleep 3

  syncthing cli config gui insecure-skip-host-check set true
  sleep 3

  syncthing cli config gui insecure-allow-frame-loading set false
  sleep 3

  syncthing cli config options local-ann-enabled set false
  sleep 3

  syncthing cli config options announce-lanaddresses set false
  sleep 3

  syncthing cli config options insecure-allow-old-tlsversions set false
  sleep 3

  while true; do
    if [[ \$(pgrep -c syncthing) -lt 1 ]]; then
      echo 'INFO: no syncthing process running, exiting now.'
      exit 0
    fi
    sleep 5
  done

"""
