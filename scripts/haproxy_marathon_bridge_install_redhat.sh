#!/bin/bash -e

# get go
sudo yum -y install git golang 
export GOPATH=/tmp/gopath 
mkdir $GOPATH
export PACKAGE=github.com/ContainerSolutions/marathon-haproxy-subdomain-bridge
go get $PACKAGE

# copy files to the right locations, install cron job
sudo cp $GOPATH/bin/marathon-haproxy-subdomain-bridge /usr/local/bin/haproxy-marathon-bridge
sudo cp $GOPATH/src/$PACKAGE/refresh-haproxy /usr/local/bin/refresh-haproxy
DOMAIN=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/domain"`
sudo sed -n -e "s/<domain>/$DOMAIN/" -e 'w /etc/cron.d/haproxycron' $GOPATH/src/$PACKAGE/haproxycron

# clean up
sudo rm -rf $GOPATH
