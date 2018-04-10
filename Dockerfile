FROM registry.cn-hangzhou.aliyuncs.com/rainbow954/ubuntu-tools
MAINTAINER ryan Zhang <rainbow954@163.com>


ARG ES_VERSION=6.2.2
# avoid conflicts with debian host systems when mounting to host volume
ARG DEFAULT_ES_USER_UID=1100

ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz /tmp
# need to adapt to both Docker's new remote-unpack-ADD behavior and the old behavior
RUN cd /usr/share && \
  if [ -f /tmp/elasticsearch-$ES_VERSION.tar.gz ]; then \
    tar xf /tmp/elasticsearch-$ES_VERSION.tar.gz; \
    else mv /tmp/elasticsearch-${ES_VERSION} /usr/share; \
    fi && \
  rm -f /tmp/elasticsearch-$ES_VERSION.tar.gz

EXPOSE 9200 9300

HEALTHCHECK --timeout=5s CMD wget -q -O - http://$HOSTNAME:9200/_cat/health

ENV ES_HOME=/usr/share/elasticsearch-$ES_VERSION \
    DEFAULT_ES_USER=elasticsearch \
    DEFAULT_ES_USER_UID=$DEFAULT_ES_USER_UID \
    ES_JAVA_OPTS="-Xms512m -Xmx512m"

#RUN adduser -S -s /bin/sh -u $DEFAULT_ES_USER_UID $DEFAULT_ES_USER
# 添加测试用户admin，密码admin，并且将此用户添加到sudoers里  
RUN groupadd $DEFAULT_ES_USER && mkdir -p /home/$DEFAULT_ES_USER
RUN useradd -d /home/$DEFAULT_ES_USER -g $DEFAULT_ES_USER $DEFAULT_ES_USER && chown -R $DEFAULT_ES_USER:$DEFAULT_ES_USER /home/$DEFAULT_ES_USER
RUN echo $DEFAULT_ES_USER:$DEFAULT_ES_USER | chpasswd  
RUN echo $DEFAULT_ES_USER"   ALL=(ALL)       ALL" >> /etc/sudoers  

VOLUME ["/data","/conf"]

WORKDIR $ES_HOME

COPY java.policy /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/
COPY start /start
COPY installPlugin /installPlugin
COPY log4j2.properties $ES_HOME/config/
RUN chmod a+x /start
RUN chmod a+x /installPlugin
RUN /installPlugin
CMD ["/start"]
