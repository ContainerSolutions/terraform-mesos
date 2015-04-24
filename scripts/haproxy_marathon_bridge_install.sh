#!/bin/bash

# get go
sudo apt-get install -y wget
wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz
tar -xf go1.4.2.linux-amd64.tar.gz && sudo mv go /opt/ && sudo mkdir /opt/gopkg
export GOPATH="/opt/gopkg" 
export GOROOT="/opt/go"
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# get marathon-haproxy-subdomain-bridge
mkdir -p /tmp/bridge && cd /tmp/bridge
ls -la
git clone https://github.com/ContainerSolutions/marathon-haproxy-subdomain-bridge.git .

# set domain name
DOMAIN=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/domain"`
sudo sed -i "s/<domain>/$DOMAIN/" haproxycron

# build the bridge tool
go build bridge.go

# copy files to the right locations, install cron job
sudo cp bridge /usr/local/bin/haproxy-marathon-bridge
sudo cp refresh-haproxy /usr/local/bin/refresh-haproxy
sudo cp haproxycron /etc/cron.d/haproxycron

# clean up
sudo rm -rf /tmp/bridge
