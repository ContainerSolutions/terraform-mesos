#!/bin/bash

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`
MYID=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/myid"`
# until terraform supports math functions, we need to do this here
((MYID+=1))

#### ZOOKEEPER stuff

# populate zoo.cfg
for ((i=1;i<=MASTERCOUNT;i++));
do
  sudo sh -c "echo server.${i}=${CLUSTERNAME}-mesos-master-((${i}-1)):2888:3888 >> /etc/zookeeper/conf/zoo.cfg"
done

# set myid
sudo sh -c "echo ${MYID} > /etc/zookeeper/conf/myid"

### MESOS stuff

# set zk connection string
ZK="zk://"
for ((i=0;i<MASTERCOUNT;i++));
do
  ZK+="${CLUSTERNAME}-mesos-master-${i}:2181,"
done

ZK+="/mesos"
sudo sh -c "echo ${ZK} > /etc/mesos/zk"

#quorum
QUORUM=$((${MASTERCOUNT}/2+1))
sudo sh -c "echo ${QUORUM} > /etc/mesos-master/quorum"

#host ip

#host name

#### MARATHON stuff
