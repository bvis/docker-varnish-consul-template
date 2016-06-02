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

JOINED_VCL_FILE=$VCL_CONFIG

if [ -d "$VCL_CONFIG" ]; then
  JOINED_VCL_FILE=/tmp/all.vcl
  echo "Joining configuration files"
  cat $VCL_CONFIG/*.vcl >> $JOINED_VCL_FILE
fi

exec varnishd -F \
  -f $JOINED_VCL_FILE \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS
