FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.3
MAINTAINER ryan Zhang <rainbow954@163.com>
ARG ES_VERSION=6.2.3
ENV ES_HOME=/usr/share/elasticsearch 

USER root

RUN yum install -y bind-utils

# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html
RUN echo "elasticsearch - memlock unlimited" >> /etc/security/limits.conf

# configuring system settings
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setting-system-settings.html#limits.conf
RUN ulimit -n 65536



COPY installPlugin /installPlugin

RUN chmod a+x /installPlugin
RUN /installPlugin

COPY /swarm/es-docker /usr/share/elasticsearch/bin/
USER elasticsearch


