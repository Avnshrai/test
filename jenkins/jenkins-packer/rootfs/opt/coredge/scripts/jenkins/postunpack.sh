#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/coredge/scripts/libjenkins.sh
. /opt/coredge/scripts/libfs.sh
. /opt/coredge/scripts/libos.sh

# Load Jenkins environment
. /opt/coredge/scripts/jenkins-env.sh

# Ensure required directories exist
chmod g+rwX "$JENKINS_BASE_DIR"
for dir in "$JENKINS_VOLUME_DIR" "$JENKINS_HOME" "${JENKINS_BASE_DIR}/plugins" "$JENKINS_TMP_DIR" "$JENKINS_LOGS_DIR"; do
    ensure_dir_exists "$dir"
    configure_permissions_ownership "$dir" -d "775" -f "664"
done
