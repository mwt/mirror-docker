#!/bin/bash

set -e

MIRROR_URL="mirror.mwt.me"

SCRIPT_DIR="$(dirname "$0")"
desination_path="/mnt/mirror/apt-mirror"
mirror_path="/mnt/mirror/apt-mirror/mirror"

. "${SCRIPT_DIR}/.secrets/cloudflare"

# Create a tempfile
#
TMPFILE=$(mktemp /tmp/apt-mirror.XXXXXX)

####################
# Mirror
####################
# clean before we mirror (clean deletes InRelease)
"$desination_path/var/clean.sh"
# mirror
apt-mirror
# download missing InRelease file
wget -qNP "$mirror_path/zotero.retorque.re/file/apt-package-archive" "https://zotero.retorque.re/file/apt-package-archive/InRelease"

####################
# Deploy
####################
"$SCRIPT_DIR/tools/deploy.sh" "$desination_path"

####################
# CDN Purge
####################

find "$mirror_path" -type f -regex '.*Release\|.*Packages\.?[^/]*' -mmin -360 -print | sed \
 -e "s|^${mirror_path}/apt.packages.shiftkey.dev/ubuntu|ghd/deb|" \
 -e "s|^${mirror_path}/zotero.retorque.re/file/apt-package-archive|zotero/deb|" | 
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
