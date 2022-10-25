#!/bin/bash

set -e

MIRROR_URL="mirror.mwt.me"

SCRIPT_DIR="$(dirname "$0")"
desination_path="$HOME/apt-mirror"

. "${SCRIPT_DIR}/.secrets/cloudflare"

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

find "$APT_MIRROR_DIR" -type f -path '*dist*' -mmin -360 -print | sed \
 -e "s|^${APT_MIRROR_DIR}/packagecloud.io/shiftkey/desktop/any|ghd/deb|" \
 -e "s|^${APT_MIRROR_DIR}/grimler.se/termux-packages-24|termux/main|" \
 -e "s|^${APT_MIRROR_DIR}/grimler.se/termux-root-packages-24|termux/root|" \
 -e "s|^${APT_MIRROR_DIR}/grimler.se/x11-packages|termux/x11|" \
 -e "s|^${APT_MIRROR_DIR}/apt.retorque.re/file/zotero-apt|zotero/deb|" | 
| while mapfile -t -n 30 ary && ((${#ary[@]}))
do
    printf '%s\n' "${ary[@]}" | jq -R . | jq -s "{ "files" : map("https://${MIRROR_URL}/" + .) }" | tee "$TMPFILE2"
    curl -H "Content-Type:application/json" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" -d "@$TMPFILE2" "https://api.cloudflare.com/client/v4/zones/7344a2687b9c922e211744794188f6e7/purge_cache"
    echo ""
done

