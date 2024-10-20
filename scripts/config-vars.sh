#!/bin/bash

set -e

# Start
# =============================================================================
printf "cfwarp-syncthing config-vars\n===\n"


# Global
# =============================================================================
export DEBUG=${DEBUG:=}

# Output Global configs
printf "DEBUG=%s\n" "${DEBUG}"


# Cloudflare Warp
# =============================================================================
export WARP_START_DELAY=${WARP_START_DELAY:=5}
export WARP_CONNECT_RETRY_MAX=${WARP_CONNECT_RETRY_MAX:=20}
export WARP_CONNECT_RETRY_SLEEP=${WARP_CONNECT_RETRY_SLEEP:=5}
# export WARP_FIX_NFT_TABLES=${WARP_FIX_NFT_TABLES:=}

# Output WARP_ configs
printf "WARP_START_DELAY=%s\n" "${WARP_START_DELAY}"
printf "WARP_CONNECT_RETRY_MAX=%s\n" "${WARP_CONNECT_RETRY_MAX}"
printf "WARP_CONNECT_RETRY_SLEEP=%s\n" "${WARP_CONNECT_RETRY_SLEEP}"
# printf "WARP_FIX_NFT_TABLES=%s\n" "${WARP_FIX_NFT_TABLES}"


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

# Output Syncthing configs
printf "STUID=%s\n" "${STUID}"
printf "STGID=%s\n" "${STGID}"
printf "STBASEDIR=%s\n" "${STBASEDIR}"
printf "STDATADIR=%s\n" "${STDATADIR}"
printf "STCONFDIR=%s\n" "${STCONFDIR}"
printf "STSHARESDIR=%s\n" "${STSHARESDIR}"
printf "STGUIADDRESS=%s\n" "${STGUIADDRESS}"


# End
# =============================================================================
printf "\n"
