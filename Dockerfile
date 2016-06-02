FROM alpine:3.3

MAINTAINER Basilio Vera <basilio.vera@softonic.com>

ENV CONSUL_TEMPLATE_VERSION 0.14.0
ENV VARNISH_VERSION         4.1.2-r1

#------------------------------------
# Consul Template needed for service discovery.
#------------------------------------
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /

RUN apk add --update unzip \
    && unzip /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d / \
    && apk del --purge unzip \
    && mv /consul-template /bin/consul-template \
    && rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
    && mkdir -p /etc/consul-template \
#------------------------------------
# Varnish
#------------------------------------
    && apk add --update varnish=${VARNISH_VERSION}

ENV VCL_CONFIG      /etc/varnish/default.vcl
ENV CACHE_SIZE      64m
ENV VARNISHD_PARAMS -p default_ttl=3600 -p default_grace=3600

ADD rootfs /

EXPOSE 80

ENTRYPOINT ["/start.sh"]
