#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libnginx.sh
. /opt/coredge/scripts/libos.sh
. /opt/coredge/scripts/liblog.sh

# Load NGINX environment variables
. /opt/coredge/scripts/nginx-env.sh

error_code=0

if is_nginx_not_running; then
    "${NGINX_SBIN_DIR}/nginx" -c "$NGINX_CONF_FILE"
    if ! retry_while "is_nginx_running"; then
        error "nginx did not start"
        error_code=1
    else
        info "nginx started"
    fi
else
    info "nginx is already running"
fi

exit "$error_code"
