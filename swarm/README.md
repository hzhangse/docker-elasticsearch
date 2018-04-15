Docker Swarm support for elasticsearch
======================================

Automatically configures elasticsearch to connect other nodes inside docker swarm cluster.

## Prerequisites

- setup [virtual box](https://www.virtualbox.org/)
- setup [Vagrant](https://www.vagrantup.com/downloads.html) in your mac os / windows

## Test and run
- gitclone this repo and go to clone folder
- run `vagrant up` then you will get a docker swarm environment
- run `vagrant ssh elastic0`
    - `sudo -u docker docker stack deploy --compose-file /vagrant/docker-prod-stack.yml elasticsearch`
- check the service: `sudo -u docker docker service ls`
- go to http://192.168.100.20:5601/ to see kibana. user/pass is elastic/changeme.
- remove the stack: `sudo -u docker docker stack rm elasticsearch`

## Run nfs service version
- gitclone this repo and go to clone folder
- run `vagrant up` then you will get a docker swarm environment
- run `vagrant ssh elastic0`
    - `sudo -u docker docker stack deploy --compose-file /vagrant/docker-prod-nfs-stack.yml elasticsearch`
- check the service: `sudo -u docker docker service ls`
- go to http://192.168.100.20:5601/ to see kibana. user/pass is elastic/changeme.
- remove the stack: `sudo -u docker docker stack rm elasticsearch`
- nfs server is built on 192.168.100.20:/var/esdata

## Affects elasticsearch parameters:

- `network.host` - an IP address of the container
- `network.publish_host` - an IP address of the container
- `discovery.zen.ping.unicast.hosts` - a list of IP addresses other nodes inside docker swarm service

In order to run docker swarm service from this image it is REQUIRED to set environment variable SERVICE_NAME to the name of service in docker swarm.
Please avoid to manually configure parameters listed above.

Example:

```
docker network create --driver overlay --subnet 10.0.10.0/24 \
  --opt encrypted elastic_cluster

docker service create --name elasticsearch --network=elastic_cluster \
  --replicas 3 \
  --env SERVICE_NAME=elasticsearch \
  --env bootstrap.memory_lock=true \
  --env "ES_JAVA_OPTS=-Xms512m -Xmx512m -XX:-AssumeMP" \
  --publish 9200:9200 \
  --publish 9300:9300 \
  youngbe/docker-swarm-elasticsearch:5.5.0

docker service create --name kibana --network=elastic_cluster \
  --replicas 1 \
  --env ELASTICSEARCH_URL="http://192.168.100.20:9200" \
  --publish 5601:5601 \
  docker.elastic.co/kibana/kibana:5.5.0
```

After started, you can go to http://192.168.100.20:5601/ to see the kibana and connect to elasticsearch cluster http://192.168.100.20:9200.

## Parameters

* "-XX:-AssumeMP" :
If you encountered "-XX:ParallelGCThreads=N" error and stop elasticsearch service, this is because some JavaSDK with -XX:+AssumeMP enabled by default. So, you should turn it off. Reference [issue](https://github.com/elastic/elasticsearch/issues/22245)

* "bootstrap.memory_lock=true" :
Production mode need to lock memory to avoid elasticsearch swap to file. It's will cause performance issue. If you encountered memory lock issue in developing, set "bootstrap.memory_lock=false".

* production mode: max_map_count and ulimit
[elasticsearch docker production mode](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode) requires:
    * vm.max_map_count=262144
    * elasticsearch using uid:gid 1000:1000
    * ulimit for /etc/security/limits.conf
        * nofile  65536 (open file)
        * nproc   65535 (process thread)
        * memlock unlimited (max memory lock)

You need to setup it BEFORE Docker service up. On CentOS7.0, you can reference the script: es-require-on-host.sh.

Since elasticsearch requires vm.max_map_count to be at least 262144 but docker service create does not support sysctl management you have to set 
vm.max_map_count on all your nodes to proper value BEFORE starting service.
On Linux Ubuntu: `sysctl -w "vm.max_map_count=262144"`. Or `echo "vm.max_map_count=262144" >> /etc/sysctl.conf` to set it permanently.

To access elasticsearch cluster connect to any docker swarm node to port 9200 using default credentials: `curl http://elastic:changeme@my-es-node.mydomain.com:9200`.

To change default elasticsearch parameters use environment variables. See https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html for more details.

## Search Chinese

* run `curl --user elastic:changeme -XPUT "http://192.168.100.20:9200/product" -H 'Content-Type: application/json' -d @./product_mapping.json;echo`

* run `curl --user elastic:changeme -XPOST "http://192.168.100.20:9200/_bulk" -H 'Content-Type: application/json' --data-binary @./productsData.json;echo`

* in kibana devtool run 
```
GET product/goods/_search
{
  "query": {
    "match": {
      "GOOD_NM": "單機身"
    }
  },
  "highlight" : {
    "pre_tags" : ["<tag1>", "<tag2>"],
    "post_tags" : ["</tag1>", "</tag2>"],
    "fields" : {
        "GOOD_NM" : {}
    }
  }
}
```

* credit ik chinese search to [medcl](https://github.com/medcl/elasticsearch-analysis-ik)

##### update dictionary

  after update the dictionary at the folder plugins/ik/config/custom/zhTW. Need to restart the plugins and [rebuild index](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html) to get effects. Suggest use the [index aliases](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html) to smoothly change the reindex process.

  ```
  sudo bin/elasticsearch-plugin remove ik
  sudo bin/elasticsearch-plugin install ik
  ```

## Elasticsearch Design Priciples

### It's search engine so keep "approximation" in mind.

It's a search engine not the sql engine. When you "select count(*)", MUST keep in mind "it is approximate". MUST read this article [Document counts are approximate](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html#search-aggregations-bucket-terms-aggregation-approximate-counts) to avoid some stupid error.

### [Modeling Your Data](https://www.elastic.co/guide/en/elasticsearch/guide/master/modeling-your-data.html)

  In SQL world, it is very easy to use statement join. But, in elasticsearch no-sql world, you have to use the following four common techniques to handle relational data:

  - [Application-side joins](https://www.elastic.co/guide/en/elasticsearch/guide/master/application-joins.html)
  - [Data denormalization](https://www.elastic.co/guide/en/elasticsearch/guide/master/denormalization.html)
  - [Nested objects](https://www.elastic.co/guide/en/elasticsearch/guide/master/nested-objects.html)
  - [Parent/child relationships](https://www.elastic.co/guide/en/elasticsearch/guide/master/parent-child.html)

MUST read [Handle relations](https://www.elastic.co/guide/en/elasticsearch/guide/master/relations.html) and [Designing for Scale](https://www.elastic.co/guide/en/elasticsearch/guide/master/scale.html)

### Date search in Elasticsearch

  In Elasticsearch, the date format is ISO8601, which is datetime with time zone (yyyy-mm-ddThh:mm:ss.nnnnnn+|-hh:mm) eg. `2017-08-04T10:30:00+08:00`. Elasticsearch provides very useful range search for the date. Must make sure your data mapping format is "date".

  For exmaple:
  ```
  PUT test/campaign/1
  {
    "campaignID": 1,
    "startTime": "2017-08-04T10:30:00+08:00",
    "endTime": "2017-08-05T10:30:00+08:00"
  }
  ```

  When you check the mapping `GET test/campaign/_mapping`, you will get
  ```
  { 
    "test": {
      "mappings": {
        "campaign": {
          "properties": {
            "campaignID": {
              "type": "long"
            },
            "endTime": {
              "type": "date"
            },
            "startTime": {
              "type": "date"
            }
          }
        }
      }
    }
  }
  ```
  
  You can use the "range" and "bool" to get the current running campaign:
  For exmaple:
  ```
  GET test/campaign/_search
  {
    "query": {
      "bool": {
        "must": [
          {
            "range": {
              "startTime": {
                "lte": "now" 
              }
            }
          },
          {
            "range": {
              "endTime": {
                "gte": "now"
              }
            }
          }
        ]
      }
    }
  }
  ```

  The detail information, please reference the 

  - [date math](https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html#date-math)
  - [date range](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/query-dsl-range-query.html#ranges-on-dates)
