#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$0")"
desination_path="/mnt/mirror/dnf-reposync"

####################
# Mirror
####################
/usr/bin/dnf reposync --repoid=shiftkey -p "$desination_path/" --download-metadata --remote-time --releasever 11

####################
# Deploy
####################
"$SCRIPT_DIR/tools/deploy.sh" "$desination_path"
