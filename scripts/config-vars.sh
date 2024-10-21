#!/bin/bash

set -e

# Start
# =============================================================================
printf "cfwarp-syncthing: %s\n" "$(date -u -Iseconds)"


# Syncthing
# =============================================================================

# Set default Syncthing values
if [ -n "${PUID}" ]; then
  export STUID=${PUID}  # support for legacy PUID variable name
else
  export STUID=${STUID:=1000}
fi

if [ -n "${PGID}" ]; then
  export STGID=${PGID}  # support for legacy PGID variable name
else
  export STGID=${STGID:=1000}
fi

export STBASEDIR="${STBASEDIR:="/var/syncthing"}"
export STDATADIR="${STDATADIR:="${STBASEDIR}/data"}"
export STCONFDIR="${STCONFDIR:="${STBASEDIR}/config"}"
export STSHARESDIR="${STSHARESDIR:="${STBASEDIR}/shares"}"
export STGUIADDRESS="${STGUIADDRESS:="0.0.0.0:8384"}"

# Output ST configs
env | grep "^ST"


# Global
# =============================================================================
export DEBUG=${DEBUG:=}

# Output DEBUG configs
env | grep "^DEBUG"


# Cloudflare Warp
# =============================================================================
export WARP_START_DELAY=${WARP_START_DELAY:=5}
export WARP_CONNECT_RETRY_MAX=${WARP_CONNECT_RETRY_MAX:=20}
export WARP_CONNECT_RETRY_SLEEP=${WARP_CONNECT_RETRY_SLEEP:=5}
export WARP_LICENSE_KEY=${WARP_LICENSE_KEY:=}
export WARP_HEALTHCHECK_PING=${WARP_HEALTHCHECK_PING:=1.1.1.1}
export WARP_SYSTEM_STATUS_DELAY=${WARP_SYSTEM_STATUS_DELAY:=90}

if [ -n "${CLOUDFLAREWARP_ORGANIZATION}" ]; then
  export WARP_ORGANIZATION=${CLOUDFLAREWARP_ORGANIZATION}  # support for legacy WARP_ORGANIZATION variable name
else
  export WARP_ORGANIZATION=${WARP_ORGANIZATION:=}
fi

if [ -n "${CLOUDFLAREWARP_CLIENT_ID}" ]; then
  export WARP_CLIENT_ID=${CLOUDFLAREWARP_CLIENT_ID}  # support for legacy WARP_CLIENT_ID variable name
else
  export WARP_CLIENT_ID=${WARP_CLIENT_ID:=}
fi

if [ -n "${CLOUDFLAREWARP_CLIENT_SECRET}" ]; then
  export WARP_CLIENT_SECRET=${CLOUDFLAREWARP_CLIENT_SECRET}  # support for legacy WARP_CLIENT_SECRET variable name
else
  export WARP_CLIENT_SECRET=${WARP_CLIENT_SECRET:=}
fi

if [ -n "${CLOUDFLAREWARP_CONNECTOR_TOKEN}" ]; then
  export WARP_CONNECTOR_TOKEN=${CLOUDFLAREWARP_CONNECTOR_TOKEN}  # support for legacy WARP_CONNECTOR_TOKEN variable name
else
  export WARP_CONNECTOR_TOKEN=${WARP_CONNECTOR_TOKEN:=}
fi


# Output WARP_ configs
env | grep -v -i -E "secret|key|token" | grep "^WARP_" || true
env | grep -i -E "secret|key|token" | grep "^WARP_" | cut -d'=' -f1 | tr '\n' '~' | sed -r 's/~/=\[redacted\]~/g' | tr '~' '\n'


# End
# =============================================================================
printf "\n"
