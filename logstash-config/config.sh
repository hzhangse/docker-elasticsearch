#!/bin/bash

cat /usr/share/logstash/config/logstash-jdbc.conf.template | sed \
  -e "s|{{jdbc_connection_string}}|${jdbc_connection_string}|g" \
  -e "s|{{jdbc_user}}|${jdbc_user:root}|g" \
  -e "s|{{jdbc_password}}|${jdbc_password:root}|g" \
  -e "s|{{jdbc_page_size}}|${jdbc_page_size}|g" \
  -e "s|{{use_column_value}}|${use_column_value}|g" \
  -e "s|{{tracking_column}}|${tracking_column}|g" \
  -e "s|{{tracking_column_type}}|${tracking_column_type}|g" \
  -e "s|{{elasticsearch_hosts}}|${elasticsearch_hosts}|g" \
  -e "s|{{elasticsearch_index}}|${elasticsearch_index}|g" \
  -e "s|{{elasticsearch_index_type}}|${elasticsearch_index_type}|g" \
  -e "s|{{send_schedule_expression}}|${send_schedule_expression}|g" \
   > /usr/share/logstash/config/logstash-jdbc.conf


cat /usr/share/logstash/config/jdbc/jdbc.sql.template | sed \
  -e "s|{{jdbc_condition_sql}}|${jdbc_condition_sql}|g" \
   > /usr/share/logstash/config/jdbc/jdbc.sql


cat /usr/share/logstash/config/logstash-beats.conf.template | sed \
  -e "s|{{beats_port}}|${beats_port}|g" \
  -e "s|{{beats_grok_expression}}|${beats_grok_expression}|g" \
  -e "s|{{beats_log_time}}|${beats_log_time}|g" \
  -e "s|{{beats_date_pattern}}|${beats_date_pattern}|g" \
  -e "s|{{elasticsearch_hosts}}|${elasticsearch_hosts}|g" \
  -e "s|{{beats_manage_template}}|${beats_manage_template:false}|g" \
  -e "s|{{beats_log_index_name}}|${beats_log_index_name}|g" \
  -e "s|{{beats_elasticsearch_index_type}}|${beats_elasticsearch_index_type}|g" \
   > /usr/share/logstash/config/logstash-beats.conf
