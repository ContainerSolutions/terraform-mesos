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

# set zk connection string
# initialize
ZK="zk://"
# loop
for ((i=0;i<MASTERCOUNT;i++));
do
  # add a master to the string
  ZK+="${CLUSTERNAME}-mesos-master-${i}:2181,"
done
# strip trailing comma
ZK=${ZK::-1}
# add path
ZK+="/mesos"
#put it in the file
sudo sh -c "echo ${ZK} > /etc/mesos/zk"

# set myid
sudo sh -c "echo ${MYID} > /etc/zookeeper/conf/myid"

### MESOS stuff

#quorum
# qourum is number of masters divided by 2, + 1)
QUORUM=$((${MASTERCOUNT}/2+1))
# write the quorum to the file
sudo sh -c "echo ${QUORUM} > /etc/mesos-master/quorum"

#host name
HOSTNAME=`cat /etc/hostname`
sudo sh -c "echo ${HOSTNAME} > /etc/mesos-master/hostname"

#host ip
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`
sudo sh -c "echo ${IP} > /etc/mesos-master/ip"

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
sudo sed -i -e 's/mesos/marathon/' /etc/marathon/conf/zk

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
