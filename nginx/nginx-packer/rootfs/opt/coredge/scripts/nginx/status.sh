#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libnginx.sh
. /opt/coredge/scripts/liblog.sh

# Load NGINX environment variables
. /opt/coredge/scripts/nginx-env.sh

if is_nginx_running; then
    info "nginx is already running"
else
    info "nginx is not running"
fi
