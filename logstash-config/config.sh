#!/bin/bash

cat /usr/share/logstash/config/logstash-jdbc.conf.template | sed \
  -e "s|{{jdbc_connection_string}}|${jdbc_connection_string}|g" \
  -e "s|{{jdbc_user}}|${jdbc_user:root}|g" \
  -e "s|{{jdbc_password}}|${jdbc_password:root}|g" \
  -e "s|{{elasticsearch.hosts}}|${elasticsearch.hosts}|g" \
  -e "s|{{elasticsearch.index}}|${elasticsearch.index}|g" \
  -e "s|{{elasticsearch.index.type}}|${elasticsearch.index.type}|g" \
   > /usr/share/logstash/config/logstash-jdbc.conf



cat /usr/share/logstash/config/jdbc/jdbc.sql.template | sed \
  -e "s|{{jdbc.condition.sql}}|${jdbc.condition.sql}|g" \
   > /usr/share/logstash/config/jdbc/jdbc.sql


