#!/bin/bash
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libcoredge.sh
. /opt/coredge/scripts/liblog.sh
. /opt/coredge/scripts/libmemcached.sh

# Load Memcached environment variables
. /opt/coredge/scripts/memcached-env.sh

print_welcome_page

if [[ "$*" = *"/opt/coredge/scripts/memcached/run.sh"* || "$*" = *"/run.sh"* ]]; then
    info "** Starting Memcached setup **"
    /opt/coredge/scripts/memcached/setup.sh
    info "** Memcached setup finished! **"
fi

echo ""
exec "$@"
