#!/bin/bash

# Setup a new docker env if it doesn't exist
docker-machine create -d virtualbox demodev
eval "$(docker-machine env demodev)"

# Setup the MongoDB
docker create -v /data/db --name dbdata debian:wheezy /bin/true
docker run -d --name enrolldb --volumes-from dbdata mongo:2.4.14

# Setup the backend app
docker run -d --link enrolldb:mongo --name enrollment-app namehta/enrollment-demo:tomcat

# Setup the frontend app
docker run -d --name enrollment-ui namehta/enrollment-ui

# Setup the proxy
docker run -d -p 80:80 --link enrollment-ui:ui --link enrollment-app:app --name enrollment-proxy namehta/enrollment-proxy

# Load the sample data
sleep 20
curl http://demoapp.example.com/app/util/load?numRecords=33

sudo sh -c "echo '$(docker-machine ip demodev)  demoapp.example.com' >> /etc/hosts"
