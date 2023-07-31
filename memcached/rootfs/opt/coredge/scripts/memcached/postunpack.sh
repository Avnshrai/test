#!/bin/bash
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libmemcached.sh
. /opt/coredge/scripts/libfs.sh

# Load Memcached environment variables
. /opt/coredge/scripts/memcached-env.sh

# Ensure directories used by Memcached exist and have proper ownership and permissions
for dir in "$MEMCACHED_CONF_DIR" "$SASL_CONF_PATH"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done
