#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/coredge/scripts/nginx-env.sh

/opt/coredge/scripts/nginx/stop.sh
/opt/coredge/scripts/nginx/start.sh
