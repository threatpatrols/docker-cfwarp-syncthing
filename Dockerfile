
# Cloudflare WARP
FROM debian:stable-slim AS cloudflare-warp

# download the cloudflare-warp deb package
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates gnupg lsb-release && \
    \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    \
    mkdir -p /tmp/cloudflare-warp && cd /tmp/cloudflare-warp && \
    \
    apt-get update && \
    apt show cloudflare-warp && \
    apt-get download --print-uris cloudflare-warp && \
    apt-get download cloudflare-warp || true && \
    mv cloudflare-warp_*.deb cloudflare-warp.deb


# https://hub.docker.com/r/syncthing/syncthing/tags
FROM syncthing/syncthing:1.29.3 AS syncthing

RUN \
   /bin/syncthing --version


# https://hub.docker.com/_/debian/tags
FROM debian:stable-slim

# OCI Labels
LABEL org.opencontainers.image.title="Docker Syncthing on CFWarp"
LABEL org.opencontainers.image.authors="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL org.opencontainers.image.source="https://github.com/threatpatrols/docker-cfwarp-syncthing"

# copy-install syncthing binary
COPY --from=syncthing /bin/syncthing /usr/local/bin/syncthing
COPY --from=cloudflare-warp /tmp/cloudflare-warp/cloudflare-warp.deb /tmp/cloudflare-warp/cloudflare-warp.deb

# install prerequisites and cloudflare-warp
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates systemd-resolved sudo procps iputils-ping inetutils-traceroute && \
    apt install -y /tmp/cloudflare-warp/cloudflare-warp.deb && \
    \
    printf " >> %s\n" "$(warp-cli --accept-tos --version)" && \
    printf " >> %s\n" "$(syncthing --version)" && \
    \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# NB: perform these COPY/RUN layers after the RUN layer above so edits/changes have short dev-build times
COPY scripts /scripts
COPY entrypoint.sh healthchecks.sh ./
RUN chmod 755 /entrypoint.sh /healthchecks.sh /scripts/*.sh

VOLUME ["/var/syncthing"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD "/healthchecks.sh"

ENTRYPOINT ["/entrypoint.sh"]
