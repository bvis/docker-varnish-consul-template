#!/bin/sh

set -e

# Executing scripts found in the '/docker-entrypoint.d' directory
echo
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done

export JOINED_VCL_FILE=$VCL_CONFIG

if [ -d "$VCL_CONFIG" ]; then
    source varnish-join-vcl.sh
fi

exec varnishd -F \
  -f $JOINED_VCL_FILE \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS

