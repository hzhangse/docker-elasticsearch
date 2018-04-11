#!/bin/bash

cat /usr/share/logstash/config/logstash-jdbc.conf.template | sed \
  -e "s|{{jdbc_connection_string}}|${jdbc_connection_string}|g" \
  -e "s|{{jdbc_user}}|${jdbc_user:root}|g" \
  -e "s|{{jdbc_password}}|${jdbc_password:root}|g" \
  -e "s|{{elasticsearch_hosts}}|${elasticsearch_hosts}|g" \
  -e "s|{{elasticsearch_index}}|${elasticsearch_index}|g" \
  -e "s|{{elasticsearch_index_type}}|${elasticsearch_index_type}|g" \
   > /usr/share/logstash/config/logstash-jdbc.conf



cat /usr/share/logstash/config/jdbc/jdbc.sql.template | sed \
  -e "s|{{jdbc_condition_sql}}|${jdbc_condition_sql}|g" \
   > /usr/share/logstash/config/jdbc/jdbc.sql


