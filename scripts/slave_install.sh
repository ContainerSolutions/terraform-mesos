#!/bin/bash

# sudo apt-get -y install haproxy

HOSTNAME=`cat /etc/hostname`
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

ZK="zk://"
for ((i=0;i<MASTERCOUNT;i++))
do
  ZK+="${CLUSTERNAME}-mesos-master-${i}:2181,"
done
ZK=${ZK::-1}
ZK+="/mesos"

sudo docker run -d \
 -e MESOS_LOG_DIR=/var/log/mesos \
 -e MESOS_MASTER=${ZK} \
 -e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=5mins \
 -e MESOS_HOSTNAME=${HOSTNAME} \
 -e MESOS_ISOLATOR=cgroups/cpu,cgroups/mem \
 -e MESOS_CONTAINERIZERS=docker,mesos \
 -e MESOS_PORT=5051 \
 -e MESOS_IP=${IP} \
 -e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=5mins \
 --net=host \
 mesosphere/mesos-slave:0.22.1-1.0.ubuntu1404
