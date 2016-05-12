#!/bin/bash -e
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`
sudo docker run -d -e PORTS=80 --name=marathon-lb --restart=always --net=host mesosphere/marathon-lb sse --marathon http://${CLUSTERNAME}-mesos-master-0:8080 --group external
