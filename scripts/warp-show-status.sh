#!/bin/bash

printf "\n"

# show the cfwarp uid/gid
printf "cfwarp uid: %s\n" "$(id -u cfwarp)"
printf "cfwarp gid: %s\n" "$(id -g cfwarp)"
printf "\n"

# show the ipv4 addresses
ip -4 addr | grep -v valid_
printf "\n"

# show the ipv6 addresses
ip -6 addr | grep -v valid_
printf "\n"

# show the Cloudflare route tables
ip route show table all | grep -v ':' | grep Cloudflare
printf "\n"

# show connection information from an independent source
curl --silent "https://ipinfo.io/json" || true
printf "\n\n"
