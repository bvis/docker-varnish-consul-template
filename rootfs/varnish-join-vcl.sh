#!/bin/sh

set -e

export JOINED_VCL_FILE=/tmp/all.vcl
echo "Joining configuration files"
cat $VCL_CONFIG/*.vcl > $JOINED_VCL_FILE
