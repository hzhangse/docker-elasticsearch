#!/bin/bash
sudo docker run -d --name es0 --publish 9200:9200 --publish 9300:9300 --net shadownet --ip 172.19.0.30 registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest

sudo docker run -d --name es1 --link es0 -e UNICAST_HOSTS=es0 --net shadownet --ip 172.19.0.31 registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest

sudo docker run -d --name es2 --link es0 -e UNICAST_HOSTS=es0 --net shadownet --ip 172.19.0.32 registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest


sudo docker run -d --name eshead -p 9100:9100 --net shadownet --ip 172.19.0.33 mobz/elasticsearch-head:5
