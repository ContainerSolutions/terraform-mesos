#!/bin/bash
#Global variables
NAME=$1
MASTERS=$2
SLAVES=$3
MASTER_INSTALL_SCRIPT="master_install.sh"
SLAVE_INSTALL_SCRIPT="slave_install.sh"
LOGPATH=/tmp/$NAME-`date +%Y%m%d-%H%M%S`
MASTERLOG="masters.json"
SLAVELOG="slaves.json"

FORMAT="json"

#variables for instances
BOOT_DISK_SIZE="50GB"
BOOT_DISK_TYPE="pd-ssd"
DESCRIPTION="mesos cluster for $NAME"
IMAGE="ubuntu-14-04"
MACHINE_TYPE="n1-standard-4"
NETWORK="mesos-$NAME"
ZONE="europe-west1-d"



create_instance() {
  gcloud compute instances create $1 \
  --boot-disk-size $BOOT_DISK_SIZE \
  --boot-disk-type $BOOT_DISK_TYPE \
  --description "$DESCRIPTION" \
  --image $IMAGE \
  --machine-type $MACHINE_TYPE \
  --network $NETWORK \
  --zone $ZONE \
  --format $FORMAT \
  --metadata-from-file startup-script=$2 >> $LOGPATH/$3
}
 
create_network() {
  gcloud compute networks create $1 \
  --format $FORMAT \
  --description "network for $NAME"  > $LOGPATH/network.json
}

create_firewall_rules() {
  gcloud compute firewall-rules create $NETWORK-ssh -q --network $1 --allow tcp:22 --format $FORMAT > $LOGPATH/firewall.json
  gcloud compute firewall-rules create $NETWORK-http -q --network $1 --allow tcp:80 --format $FORMAT >> $LOGPATH/firewall.json
  gcloud compute firewall-rules create $NETWORK-https -q --network $1 --allow tcp:443 --format $FORMAT >> $LOGPATH/firewall.json
}

config_zookeeper() {
  ZKSTRING="zk://"`cat $LOGPATH/$MASTERLOG | jq -r  '.[].networkInterfaces[].networkIP|.+":2181"' | paste -sd "," -`"/mesos"
  ZOOSTRING=`cat $LOGPATH/$MASTERLOG | jq -r  '.[].networkInterfaces[].networkIP|.+":2888:3888"'`

  #masters
  id=1
  for name in `cat $LOGPATH/$MASTERLOG | jq -r  '.[].name'`; do
    echo "Configuring $name:"
    echo "Setting zk uri ..."
    gcloud compute ssh ${name} --zone $ZONE --command "sudo sh -c \"echo $ZKSTRING > /etc/mesos/zk\""
    echo "Setting Zookeerper id ..."
    gcloud compute ssh ${name} --zone $ZONE --command "sudo sh -c \"echo $id > /etc/zookeeper/conf/myid\""
    echo "Done."
    ((id+=1))
  done;
  
  #slaves
  for name in `cat $LOGPATH/$SLAVELOG | jq -r  '.[].name'`; do
    echo "Configuring $name:"
    echo "Setting zk uri ..."
    gcloud compute ssh ${name} --zone $ZONE --command "sudo sh -c \"echo $ZKSTRING > /etc/mesos/zk\""
    echo "Done."
  done;
  
}

put_zk_master_ids() {
  for name in `cat masters.json | jq -r  '.[].name'`; do
  done;
}

###########################
# end of function section #
###########################

# check for jq

# check if a cluster with the same name already exists


# create the log directory
mkdir $LOGPATH

#instance groups

# create the network
if [ -z `gcloud compute networks list --regexp $NETWORK --uri` ]
  then 
    echo "Creating network ..."
    create_network $NETWORK
    echo "Creating firewall rules ..."
    create_firewall_rules $NETWORK $PORTS
  else 
    echo "Network already exists."
fi

# create the masters
for ((i=1;i<=$MASTERS;i++));
do
  masternames+="$NAME-master-$i "
done
echo "Going to create the following master nodes:"
echo $masternames
create_instance "$masternames" $MASTER_INSTALL_SCRIPT $MASTERLOG


# create the slaves
for ((i=1;i<=SLAVES;i++));
do
  slavenames+="$NAME-slave-$i "
done
echo "Going to create the following slave nodes:"
echo $slavenames
create_instance "$slavenames" $SLAVE_INSTALL_SCRIPT $SLAVELOG

#zookeeper
config_zookeeper








#dns
#ssl
#haproxy
# --scopes ?
# --tags
