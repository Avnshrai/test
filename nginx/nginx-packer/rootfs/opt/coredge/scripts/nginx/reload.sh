#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libnginx.sh
. /opt/coredge/scripts/liblog.sh

# Load NGINX environment
. /opt/coredge/scripts/nginx-env.sh

info "** Reloading NGINX configuration **"
exec "${NGINX_SBIN_DIR}/nginx" -s reload
