#!/bin/bash
sudo docker run -d --name es60 --publish 9200:9200 --publish 9300:9300 --net shadownet --ip 172.19.0.40 -e PLUGINS='https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.2.3/elasticsearch-analysis-ik-6.2.3.zip' registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest

sudo docker run -d --name es61 --link es0 -e UNICAST_HOSTS=es0 --net shadownet --ip 172.19.0.41 registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest

sudo docker run -d --name es2 --link es0 -e UNICAST_HOSTS=es0 --net shadownet --ip 172.19.0.42 registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest


sudo docker run -d --name eshead -p 9100:9100 --net shadownet --ip 172.19.0.33 mobz/elasticsearch-head:5
