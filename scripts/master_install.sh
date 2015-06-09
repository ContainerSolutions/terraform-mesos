#!/bin/bash

sudo apt-get -y install haproxy marathon

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`
MESOSVERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mesosversion"`
MARATHONVERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/marathonversion"`
MYID=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/myid"`
ZK_CLIENT_PORT=2181

# until terraform supports math functions, we need to do this here
((MYID+=1))

# Zookeeper

if [ $MYID -eq 1 ]
then
	sudo docker run -d -p ${ZK_CLIENT_PORT}:${ZK_CLIENT_PORT} containersol/zookeeper ${MYID}
	echo "Zookeeper container started (${MYID})"
else
	FIRST_NODE="${CLUSTERNAME}-mesos-master-0"
	while ! nc -z ${FIRST_NODE} ${ZK_CLIENT_PORT}
	do
		echo "Zookeeper waiting for ${FIRST_NODE} to start up."
		sleep 1
	done
	sudo docker run -d -p ${ZK_CLIENT_PORT}:${ZK_CLIENT_PORT} containersol/zookeeper ${MYID} ${FIRST_NODE}
	echo "Zookeeper container started (${MYID} ${FIRST_NODE})"
fi

# Mesos (master)

QUORUM=$((${MASTERCOUNT}/2+1))

ZK="zk://"
for ((i=0;i<MASTERCOUNT;i++))
do
  ZK+="${CLUSTERNAME}-mesos-master-${i}:${ZK_CLIENT_PORT},"
done
ZK=${ZK::-1}
# ZK+="/mesos"

sudo docker run -d \
 -e MESOS_QUORUM=${QUORUM} \
 -e MESOS_WORK_DIR=/var/lib/mesos \
 -e MESOS_LOG_DIR=/var/log \
 -e MESOS_CLUSTER=${CLUSTERNAME} \
 -e MESOS_ZK=${ZK}/mesos \
 --net=host \
 mesosphere/mesos-master:${MESOSVERSION}

# Marathon

sudo docker run -d \
 -p 8080:8080 \
 -p 5051:5051 \
 mesosphere/marathon:${MARATHONVERSION} \
 --master ${ZK}/mesos \
 --zk ${ZK}/marathon
