#!/bin/bash

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

#### ZOOKEEPER stuff

# populate zoo.cfg
for ((i=1;i<=MASTERCOUNT;i++));
do
  sudo sh -c "echo server.${i}=${CLUSTERNAME}-mesos-master-((${i}-1)):2888:3888 >> /etc/zookeeper/conf/zoo.cfg"
done

# set zk connection string
ZK="zk://"
for ((i=0;i<MASTERCOUNT;i++));
do
  ZK+="${CLUSTERNAME}-mesos-master-${i}:2181,"
done
ZK+="/mesos"
sudo sh -c "echo ${ZK} > /etc/mesos/zk"

