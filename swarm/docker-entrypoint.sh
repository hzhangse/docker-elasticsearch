#!/bin/bash
set -e

# Files created by Elasticsearch should always be group writable too
umask 0002





es_opts=''

if [ -z ${SERVICE_NAME} ];then
    >&2 echo "Environment variable SERVICE_NAME not set. You MUST set it to name of docker swarm service"
    exit 3
fi

# Delay to let hostname to be published to swarm DNS service
sleep 15

echo "Discovering other nodes in cluster..."
# Docker swarm's DNS resolves special hostname "tasks.<service_name" to IP addresses of all containers inside overlay network
SWARM_SERVICE_IPs=$(dig tasks.${SERVICE_NAME} +short)
echo "Nodes of service ${SERVICE_NAME}:"
echo "$SWARM_SERVICE_IPs"

HOSTNAME=$(hostname)
MY_IP=$(dig ${HOSTNAME} +short)
echo "My IP: ${MY_IP}"

OTHER_NODES=""

for NODE_IP in $SWARM_SERVICE_IPs
do
    if [ "${NODE_IP}" == "${MY_IP}" ];then
        continue;
    fi
    OTHER_NODES="${OTHER_NODES}${NODE_IP},"
done


if [ -n "${MY_IP}" ];then
    echo "Setting network.publish_host=${MY_IP}"
    es_opt="-Enetwork.publish_host=${MY_IP}"
    es_opts+=" ${es_opt}"
    echo "Setting network.host=0.0.0.0"
    es_opt="-Enetwork.host=0.0.0.0"
    es_opts+=" ${es_opt}"
    echo "Setting network.bind_host=0.0.0.0"
    es_opt="-Enetwork.bind_host=0.0.0.0"
    es_opts+=" ${es_opt}"
fi

if [ -n "$OTHER_NODES" ];then
    echo "Setting discovery.zen.ping.unicast.hosts=${OTHER_NODES%,}"
    es_opt="-Ediscovery.zen.ping.unicast.hosts=${OTHER_NODES%,}"
    es_opts+=" ${es_opt}"
else
    echo "There is no another nodes in cluster. I am alone!"
fi

#Configuring elasticsearch using environment variables
while IFS='=' read -r envvar_key envvar_value
do
    # Elasticsearch env vars need to have at least two dot separated lowercase words, e.g. `cluster.name`
    if [[ "$envvar_key" =~ ^[a-z]+\.[a-z]+ ]]
    then
        if [[ ! -z $envvar_value ]]; then
          es_opt="-E${envvar_key}=${envvar_value}"
          es_opts+=" ${es_opt}"
        fi
    fi
done < <(env)

# The virtual file /proc/self/cgroup should list the current cgroup
# membership. For each hierarchy, you can follow the cgroup path from
# this file to the cgroup filesystem (usually /sys/fs/cgroup/) and
# introspect the statistics for the cgroup for the given
# hierarchy. Alas, Docker breaks this by mounting the container
# statistics at the root while leaving the cgroup paths as the actual
# paths. Therefore, Elasticsearch provides a mechanism to override
# reading the cgroup path from /proc/self/cgroup and instead uses the
# cgroup path defined the JVM system property
# es.cgroups.hierarchy.override. Therefore, we set this value here so
# that cgroup statistics are available for the container this process
# will run in.
export ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ $ES_JAVA_OPTS"





# Determine if x-pack is enabled
if bin/elasticsearch-plugin list -s | grep -q x-pack; then
    # Setting ELASTIC_PASSWORD is mandatory on the *first* node (unless
    # LDAP is used). As we have no way of knowing if this is the first
    # node at this step, we can't enforce the presence of this env
    # var.
    if [[ -n "$ELASTIC_PASSWORD" ]]; then
        [[ -f /usr/share/elasticsearch/config/elasticsearch.keystore ]] || (run_as_other_user_if_needed elasticsearch-keystore create)
        (run_as_other_user_if_needed echo "$ELASTIC_PASSWORD" | elasticsearch-keystore add -x 'bootstrap.password')
    fi
fi

if [[ "$(id -u)" == "0" ]]; then
    # If requested and running as root, mutate the ownership of bind-mounts
    if [[ -n "$TAKE_FILE_OWNERSHIP" ]]; then
        chown -R 1000:0 /usr/share/elasticsearch/{data,logs}
    fi
fi

echo "Launching command: bin/elasticsearch ${es_opts}"
exec bin/elasticsearch ${es_opts}


