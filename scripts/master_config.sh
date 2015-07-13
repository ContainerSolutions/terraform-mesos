#!/bin/bash

echo "getting metadata"
MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`
MYID=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/myid"`
# until terraform supports math functions, we need to do this here
((MYID+=1))

#### ZOOKEEPER stuff

# populate zoo.cfg
echo "writing /etc/zookeeper/conf/zoo.cfg"
for ((i=1;i<=MASTERCOUNT;i++))
do
  echo "adding server ${i}"
  sudo sh -c "echo server.${i}=${CLUSTERNAME}-mesos-master-$((${i}-1)):2888:3888 >> /etc/zookeeper/conf/zoo.cfg"
done

# set myid
echo "setting myid"
sudo sh -c "echo ${MYID} > /etc/zookeeper/conf/myid"

### MESOS stuff

#quorum
# qourum is number of masters divided by 2, + 1)
QUORUM=$((${MASTERCOUNT}/2+1))
# write the quorum to the file
sudo sh -c "echo ${QUORUM} > /etc/mesos-master/quorum"
#host name
HOSTNAME=`cat /etc/hostname`
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`

sudo sh -c "echo ${IP} > /etc/mesos-master/hostname"
# host ip
sudo sh -c "echo ${IP} > /etc/mesos-master/ip"
# cluster name
sudo sh -c "echo ${CLUSTERNAME} > /etc/mesos-master/cluster"
# logging level
sudo sh -c "echo 'WARNING' > /etc/mesos-master/logging_level"


#### MARATHON stuff
# create the config dir
sudo mkdir -p /etc/marathon/conf
# copy the hostname file from mesos
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
# copy zk file from mesos
sudo cp /etc/mesos/zk /etc/marathon/conf/master
# and again
sudo cp /etc/mesos/zk /etc/marathon/conf
# replace mesos with marathon
sudo sed -i -e 's|mesos$|marathon|' /etc/marathon/conf/zk
# enable the artifact store
sudo mkdir -p /etc/marathon/store
sudo sh -c "echo 'file:///etc/marathon/store' > /etc/marathon/conf/artifact_store"
sudo sh -c "echo 'warn' > /etc/marathon/conf/logging_level"

##### service stuff
# stop mesos slave process, if running
sudo stop mesos-slave
# disable automatic start of mesos slave
sudo sh -c "echo manual > /etc/init/mesos-slave.override"

# restart zookeeper
sudo restart zookeeper

# start mesos master
sudo start mesos-master

# start marathon
sudo start marathon
