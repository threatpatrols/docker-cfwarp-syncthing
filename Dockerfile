
# https://hub.docker.com/r/syncthing/syncthing/tags
FROM syncthing/syncthing:latest AS syncthing

RUN \
   /bin/syncthing --version


# https://hub.docker.com/_/debian/tags
FROM debian:stable-slim

# Hello
LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL source="https://github.com/threatpatrols/docker-cfwarp-syncthing"

# copy-install syncthing binary
COPY --from=syncthing /bin/syncthing /usr/local/bin/syncthing

# install prerequisites and cloudflare-warp
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates curl libcap2 tzdata gnupg lsb-release procps && \
    \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp && \
    \
    warp-cli --accept-tos --version && \
    syncthing --version && \
    \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


HEALTHCHECK --interval=45s --timeout=3s --start-period=20s --retries=3 \
  CMD curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1


VOLUME ["/var/syncthing"]
EXPOSE 8384


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
