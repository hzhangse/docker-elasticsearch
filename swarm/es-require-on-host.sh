#!/bin/bash
  ## elasticsearch configuration
  ## https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode
  mkdir -p /etc/security/limits.d
  echo "# elastichsearch 5.5.0 configuration" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* soft nproc 65535" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* hard nproc 65535" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* soft nofile 65535" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* hard nofile 65535" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* soft memlock unlimited" >> /etc/security/limits.d/10-elasticsearch.conf
  echo "* hard memlock unlimited" >> /etc/security/limits.d/10-elasticsearch.conf
  sysctl -w vm.max_map_count=262144
  ulimit -n 65535
  ulimit -l unlimited

  ## increase docker ulimit
  ## ship default at /usr/lib/systemd/system/docker.service
  ## Drop-In put at /etc/systemd/system/
  mkdir /etc/systemd/system/docker.service.d
  echo "[Service]" >> /etc/systemd/system/docker.service.d/increase-ulimit.conf
  echo "LimitMEMLOCK=infinity" >> /etc/systemd/system/docker.service.d/increase-ulimit.conf

  groupadd -f -g 1000 elasticsearch && useradd elasticsearch -ou 1000 -g 1000
  
  ## start docker daemon
  systemctl daemon-reload
  systemctl start docker

