#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libcoredge.sh
. /opt/coredge/scripts/libmongodb.sh

# Load environment
. /opt/coredge/scripts/mongodb-env.sh

print_welcome_page

if [[ "$1" = "/opt/coredge/scripts/mongodb/run.sh" ]]; then
    info "** Starting MongoDB setup **"
    /opt/coredge/scripts/mongodb/setup.sh
    info "** MongoDB setup finished! **"
fi

echo ""
exec "$@"

