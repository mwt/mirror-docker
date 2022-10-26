#!/bin/sh
rsync -avxHAX --delete /etc/letsencrypt/ second:/etc/letsencrypt
ssh second 'nginx -t -q && systemctl reload nginx'

rsync -avxHAX --delete /etc/letsencrypt/ mirror-lu-p:/etc/letsencrypt
ssh mirror-lu-p 'nginx -t -q && systemctl reload nginx'

rsync -avxHAX --delete /etc/letsencrypt/ mirror-lu-s:/etc/letsencrypt
ssh mirror-lu-s 'nginx -t -q && systemctl reload nginx'
