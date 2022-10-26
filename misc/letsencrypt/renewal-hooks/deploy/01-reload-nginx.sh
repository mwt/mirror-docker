#!/bin/sh
set -e
# reload local nginx
nginx -t -q && systemctl reload nginx
exit 0
