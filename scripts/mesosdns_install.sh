#!/bin/bash

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

MASTERS_JSON+="[\"${CLUSTERNAME}-mesos-master-0:5050\""
for ((i=1;i<MASTERCOUNT;i++))
do
 MASTERS_JSON+=",\""
 MASTERS_JSON+=`host ${CLUSTERNAME}-mesos-master-${i}| grep ^${HOSTNAME}| awk '{print $4}'`
 MASTERS_JSON+=":5050\""
done
MASTERS_JSON+=']'

sudo tee /etc/mesos-dns.conf <<JSON
{
  "masters": $MASTERS_JSON,
  "refreshSeconds": 60,
  "ttl": 60,
  "domain": "mesos",
  "port": 53,
  "resolvers": ["8.8.8.8"],
  "timeout": 5,
  "listener": "0.0.0.0",
  "email": "root.mesos-dns.mesos"
}
JSON

sudo docker run -d --restart=always --name mesosdns -p 53:53 -p 53:53/udp -v /etc/mesos-dns.conf:/config.json mwldk/mesos-dns:0.1.1-srvfix mesos-dns -config=/config.json -v=2