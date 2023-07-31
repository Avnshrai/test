#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libcoredge.sh
. /opt/coredge/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/coredge/scripts/nginx-env.sh

print_welcome_page

if [[ "$1" = "/opt/coredge/scripts/nginx/run.sh" ]]; then
    info "** Starting NGINX setup **"
    /opt/coredge/scripts/nginx/setup.sh
    info "** NGINX setup finished! **"
fi

echo ""
exec "$@"
