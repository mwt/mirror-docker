#!/bin/sh

case "$RENEWED_DOMAINS" in
	*matthewthom.as*) 	;;
	*)					exit 0 ;;
esac

cp "$RENEWED_LINEAGE/fullchain.pem" /srv/gemini/certs/default.crt
cp "$RENEWED_LINEAGE/privkey.pem" /srv/gemini/certs/default.key
