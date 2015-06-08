#!/bin/bash

sudo apt-get -y install haproxy

HOSTNAME=`cat /etc/hostname`
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`
MESOSVERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mesosversion"`
ZK_CLIENT_PORT=2181

ZK="zk://"
for ((i=0;i<MASTERCOUNT;i++))
do
  ZK+="${CLUSTERNAME}-mesos-master-${i}:${ZK_CLIENT_PORT},"
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
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /usr/bin/docker:/usr/bin/docker \
 -v /sys:/sys:ro \
 --net=host \
 mesosphere/mesos-slave:${MESOSVERSION}
