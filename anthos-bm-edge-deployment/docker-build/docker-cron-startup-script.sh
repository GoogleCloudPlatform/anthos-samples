#!/bin/bash

## This script is used to setup the docker image for Consumer Edge installation and ensure
##     This script is referenced by `crontab` running every minute

if ! grep -q "AUTO-GENERATED-CONSUMER-EDGE" "/etc/hosts"; then
    # Only apply IF the file does not contain AUTO-GENERATED
    /var/consumer-edge-install/scripts/gce-status.sh true >> /etc/hosts

    # If the file "add-hosts" exists, add these to the bottom of the /etc/hosts file (usually used for physical machines)
    if [ -f "/var/consumer-edge-install/build-artifacts/add-hosts" ]; then
        echo "" >> /etc/hosts
        cat /var/consumer-edge-install/build-artifacts/add-hosts >> /etc/hosts
    fi
fi