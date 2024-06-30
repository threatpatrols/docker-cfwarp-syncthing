# Syncthing via Cloudflare WARP on Docker

## Usage

Run an instance of [Syncthing](https://syncthing.net/) in Docker with traffic via Cloudflare WARP
using a `docker-compose.yml` similar to the one provided below.

```yaml
services:
  syncthing:
    image: threatpatrols/cfwarp-syncthing:latest
    
    hostname: example01
    container_name: syncthing-example01

    cap_add:
      # required for Cloudflare WARP
      - NET_ADMIN

    sysctls:
      # required for Cloudflare WARP
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1

    ports:
      # Make >>VERY<< sure this binding is via 127.0.0.1 as shown else you will expose the Syncthing GUI interface 
      - 127.0.0.1:8384:8384

    volumes:
      # Required: Mount /var/syncthing to some local path that suits  
      - /some/local/path:/var/syncthing
      # Optional: Mount /var/lib/cloudflare-warp somewhere allowing Cloudflare WARP to maintain device-account between restarts 
      - var-lib-cloudflare-warp:/var/lib/cloudflare-warp

volumes:
  var-lib-cloudflare-warp:

```

Bring it up with a standard `docker-compose up` command.

### Notes
- This sample `docker-compose.yml` should be modified to suit your situation, in particular the `/some/local/path` mount. 
- The container requires root privileges to enable the creation of a tunnel-interface (`/dev/net/tun`) required for Cloudflare WARP to bind to.
- The container does not confirm to the do-one-thing doctrine since it starts both a Cloudflare WARP daemon and a Syncthing process, this is managed using a HEALTHCHECK to test for health of the Cloudflare WARP tunnel with an `exit 1` if down; together with loop that checks for the existence of `syncthing` that terminates when missing.  
- The Syncthing process is started as a regular unprivileged user, adjust the `PUID` and `PGUID` to adjust the apparent user. 
- The container enforces the Syncthing option `local-ann-enabled=false` that prevents local network discovery, all connections therefore occur via external relay server(s) via the Cloudflare WARP tunnel.  
- DNS is also tunneled to prevent local DNS query traffic leaks.


## Configuration

The following environment variables are available for configuration:

- `PUID`: user-id to run the Syncthing process

- `PGID`: group-id to run the Syncthing process
  
- `STBASEDIR`: Base directory for the Syncthing directory paths, by default `/var/syncthing`; this is the path you should volume-mount; this is __not__ a standard Syncthing variable.

- `STDATADIR`: Path for Syncthing data files, by default `${STBASEDIR}/data`; this is a standard Syncthing variable.

- `STSHARESDIR`: Path for Syncthing shares, by default `${STSHARESDIR}/shares`; this is __not__ a standard Syncthing variable.

- `STCONFDIR`: Path for Syncthing config files, by default `${STSHARESDIR}/config`; this is a standard Syncthing variable.

- `STGUIADDRESS`: IP-address and port for Syncthing to listen, by default `0.0.0.0:8384`; this is a standard Syncthing variable; Pay special attention to ensure any port-binding to expose this is via `127.0.0.1` else you will expose the Syncthing GUI interface which will have very negative security outcomes. 
  

## Repos
* Github: https://github.com/threatpatrols/docker-cfwarp-syncthing
* DockerHub: https://hub.docker.com/r/threatpatrols/cfwarp-syncthing