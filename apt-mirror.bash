#!/bin/bash

set -e

MIRROR_URL="mirror.mwt.me"

SCRIPT_DIR="$(dirname "$0")"
desination_path="/mnt/mirror/apt-mirror"
mirror_path="/mnt/mirror/apt-mirror/mirror"

. "${SCRIPT_DIR}/.secrets/cloudflare"

# Create a tempfile
#
TMPFILE=$(mktemp /tmp/ctan.XXXXXX)

####################
# Mirror
####################
apt-mirror

####################
# Deploy
####################
"$SCRIPT_DIR/tools/deploy.sh" "$desination_path"

####################
# CDN Purge
####################

find "$mirror_path" -type f -path '*dist*' -mmin -360 -print | sed \
 -e "s|^${mirror_path}/packagecloud.io/shiftkey/desktop/any|ghd/deb|" \
 -e "s|^${mirror_path}/grimler.se/termux-packages-24|termux/main|" \
 -e "s|^${mirror_path}/grimler.se/termux-root-packages-24|termux/root|" \
 -e "s|^${mirror_path}/grimler.se/x11-packages|termux/x11|" \
 -e "s|^${mirror_path}/apt.retorque.re/file/zotero-apt|zotero/deb|" | 
while mapfile -t -n 30 ary && ((${#ary[@]}))
do
    printf '%s\n' "${ary[@]}" | jq -R . | jq -s "{ \"files\" : map(\"https://${MIRROR_URL}/\" + .) }" | tee "$TMPFILE"
    curl -H "Content-Type:application/json" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" -d "@$TMPFILE" "https://api.cloudflare.com/client/v4/zones/7344a2687b9c922e211744794188f6e7/purge_cache"
    echo ""
done

####################
# Cleanup
####################

# Remove the tempfiles
rm -f $TMPFILE
