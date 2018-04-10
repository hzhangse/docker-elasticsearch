#!/bin/bash


#set up es-head console
#sudo docker run -d --name eshead -p 9100:9100 --net shadownet --ip 172.19.0.33 mobz/elasticsearch-head:5

#sudo docker run -d --name kibana6 --net shadownet --ip 172.19.0.43 docker.elastic.co/kibana/kibana:6.2.3

#pull docker.elastic.co/kibana/kibana:6.2.3

# setup master node
#sudo docker run -d --name es60-master --publish 9200:9200 --publish 9300:9300 --net shadownet --ip 172.19.0.40 \
#    -v /home/ryan/work/esData/master:/data  \
#    -e PLUGINS=https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.2.3/elasticsearch-analysis-ik-6.2.3.zip \
#    -e NODE_NAME=es6-master \
#    -e CLUSTER=es6-cluster \
#    -e TYPE=NON_DATA \
#    registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest /start

sudo docker run -d --name es60-master --publish 9200:9200 --publish 9300:9300 --net shadownet --ip 172.19.0.40 \
    -v /home/ryan/work/esData/master:/data  \
    -e NODE_NAME=es6-master \
    -e CLUSTER=es6-cluster \
    -e TYPE=NON_DATA \
     registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest /start


# setup node 1
sudo docker run -d --name es61 --link es60-master --net shadownet --ip 172.19.0.41 \
        -v /home/ryan/work/esData/es1:/data  \
        -e NODE_NAME=es6-1 \
        -e CLUSTER=es6-cluster \
        -e TYPE=DATA  \
        -e UNICAST_HOSTS=es60-master  \
        registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest /start

# setup node 2
sudo docker run -d --name es62 --link es60-master --net shadownet --ip 172.19.0.42 \
        -v /home/ryan/work/esData/es2:/data  \
        -e NODE_NAME=es6-2 \
        -e CLUSTER=es6-cluster \
        -e TYPE=DATA  \
        -e UNICAST_HOSTS=es60-master  \
        registry.cn-hangzhou.aliyuncs.com/rainbow954/elasticsearch:latest /start
