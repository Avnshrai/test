#!/bin/bash

# shellcheck disable=SC1090,SC1091

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
#set -xv
# Ensure Jenkins environment variables are valid
jenkins_validate

if am_i_root; then
    info "Creating Jenkins daemon user"
    ensure_user_exists "$JENKINS_DAEMON_USER" --group "$JENKINS_DAEMON_GROUP" --home "$JENKINS_HOME" --system
fi

# Ensure Jenkins is initialized
jenkins_initialize

# Allow running custom initialization scripts
jenkins_custom_init_scripts

#set +xv
