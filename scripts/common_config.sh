#!/bin/bash

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

### MESOS stuff
# set zk connection string
# initialize
ZK="zk://"
# loop
for ((i=0;i<MASTERCOUNT;i++))
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

