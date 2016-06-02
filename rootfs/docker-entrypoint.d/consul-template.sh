#!/bin/bash
CONSUL_TEMPLATE=/bin/consul-template

# start consul-template
${CONSUL_TEMPLATE} \
    -config /etc/consul-template/config.d/init.cfg -log-level info &
