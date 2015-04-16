#!/bin/bash

sudo tee /etc/mesos-dns.conf <<JSON
{
  "masters": ["127.0.0.1:5050"],
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