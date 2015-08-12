#!/bin/bash

HOSTNAME=`hostname`
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`
DOCKER_BRIDGE_IP="172.17.42.1"
MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`

sudo mkdir /tmp/consul

if [ ${HOSTNAME: -1} -eq 0 ]
then
    sudo docker run -d -h node${HOSTNAME: -1} -v /tmp/consul:/data \
        -p ${IP}:8300:8300 \
        -p ${IP}:8301:8301 \
        -p ${IP}:8301:8301/udp \
        -p ${IP}:8302:8302 \
        -p ${IP}:8302:8302/udp \
        -p ${IP}:8400:8400 \
        -p ${IP}:8500:8500 \
        -p ${DOCKER_BRIDGE_IP}:53:53/udp \
        progrium/consul -server -advertise ${IP} -bootstrap-expect ${MASTERCOUNT}
else
    LEADER_HOSTNAME=`sed -e 's/[0-9]*$/0/g' <<< ${HOSTNAME}`
    while ! nc -z ${LEADER_HOSTNAME} 8300
    do
        echo "Consul waiting for ${LEADER_HOSTNAME} to start up."
        sleep 1
    done
    LEADER_IP=`host ${LEADER_HOSTNAME} | awk '/has address/ { print $4 }'`
    sudo docker run -d -h node${HOSTNAME: -1} -v /tmp/consul:/data  \
        -p ${IP}:8300:8300 \
        -p ${IP}:8301:8301 \
        -p ${IP}:8301:8301/udp \
        -p ${IP}:8302:8302 \
        -p ${IP}:8302:8302/udp \
        -p ${IP}:8400:8400 \
        -p ${IP}:8500:8500 \
        -p ${DOCKER_BRIDGE_IP}:53:53/udp \
        progrium/consul -server -advertise ${IP} -join ${LEADER_IP}
fi
