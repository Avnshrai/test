#!/bin/bash
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libkeycloak.sh

# Load keycloak environment variables
. /opt/coredge/scripts/keycloak-env.sh

# Ensure keycloak environment variables are valid
keycloak_validate

# Ensure 'daemon' user exists when running as 'root'
am_i_root && ensure_user_exists "$KEYCLOAK_DAEMON_USER" --group "$KEYCLOAK_DAEMON_GROUP"

# Ensure keycloak is initialized
keycloak_initialize

# keycloak init scripts
keycloak_custom_init_scripts