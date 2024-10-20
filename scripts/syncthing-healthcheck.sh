#!/bin/bash

curl -fsS "http://127.0.0.1:8384/rest/noauth/health" | grep -qE "OK" || exit 1
exit 0
