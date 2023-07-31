#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/liblog.sh
. /opt/coredge/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/coredge/scripts/nginx-env.sh
# sudo chown -R core:root /opt/*
# sudo chmod -R 777 /opt/*
sudo ls -lrtR /opt/
cat "$NGINX_CONF_FILE"
# # sudo ldd "${NGINX_SBIN_DIR}/nginx"
# # sudo apt update && sudo apt install -y file 
# file "${NGINX_SBIN_DIR}/nginx" 
info "** Starting NGINX **"
exec "${NGINX_SBIN_DIR}/nginx" -c "$NGINX_CONF_FILE" -g "daemon off;"