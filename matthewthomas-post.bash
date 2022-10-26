#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$0")"
desination_path="/mnt/mirror/matthewthomas/site"

"$SCRIPT_DIR/tools/deploy.sh" "$desination_path"
