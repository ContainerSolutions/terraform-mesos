#!/bin/bash

HOSTNAME=`hostname`

while ! nc -z ${HOSTNAME} 8300
do
    echo "Vault waiting for Consul to start up."
    sleep 1
done

sudo docker run -d -h vault-${HOSTNAME: -1} \
    -v /tmp/consul.hcl:/config/consul.hcl \
    -p 8200:8200 \
    --cap-add IPC_LOCK \
    --name vault \
    --link consul:consul \
    sjourdan/vault -config=/config/consul.hcl
