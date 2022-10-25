#!/bin/bash

set -e

MIRROR_URL="mirror.mwt.me/ctan"

SCRIPT_DIR="$(dirname "$0")"
destination_path="/mnt/mirror/tex-archive"

. "${SCRIPT_DIR}/.secrets/cloudflare"

# Create a tempfile
#
TMPFILE1=$(mktemp /tmp/ctan.XXXXXX)
TMPFILE2=$(mktemp /tmp/ctan.XXXXXX)

####################
# Mirror
####################
rsync -ai --filter 'protect .stfolder' --log-file=$TMPFILE1 --delete rsync://rsync.dante.ctan.org/CTAN "$destination_path"

####################
# Deploy
####################
"$SCRIPT_DIR/tools/deploy.sh" "$destination_path"

####################
# CDN Purge
####################

# Purge the CDN using values from rsync log
cat $TMPFILE1 | grep -E '\] (>f\.|cLc\.t)' | cut -d \  -f 5 | while mapfile -t -n 30 ary && ((${#ary[@]}))
do
    printf '%s\n' "${ary[@]}" | jq -R . | jq -s "{ \"files\" : map(\"https://${MIRROR_URL}/\" + .) }" | tee "$TMPFILE2"
    curl -H "Content-Type:application/json" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" -d "@$TMPFILE2" "https://api.cloudflare.com/client/v4/zones/7344a2687b9c922e211744794188f6e7/purge_cache"
    echo ""
done

####################
# Cleanup
####################

# Remove the tempfiles
rm -f $TMPFILE1
rm -f $TMPFILE2
