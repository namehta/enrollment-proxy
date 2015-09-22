#!/bin/bash

# Setup a new docker env if it doesn't exist
docker-machine create -d virtualbox demodev
eval "$(docker-machine env demodev)"

# Setup the MongoDB
docker create -v /data/db --name dbdata debian:wheezy /bin/true
docker run -d --name enrolldb --volumes-from dbdata mongo:2.4.14

# Setup the backend app
docker run -d --link enrolldb:mongo --name app namehta/enrollment-app:tomcat

# Setup the frontend app
docker run -d --name ui namehta/enrollment-ui

# Setup the proxy
docker run -d -p 80:80 --link ui:ui --link app:app --name enrollment-proxy namehta/enrollment-proxy

# Add an entry for demoapp.example.com to /etc/hosts
if [ -n "$(grep 'demoapp.example.com' /etc/hosts)" ]
then
    sudo sed -i".bak" "/demoapp.example.com/d" /etc/hosts
fi
sudo sh -c "echo '$(docker-machine ip demodev)  demoapp.example.com' >> /etc/hosts"

# Load the sample data
sleep 20
curl http://demoapp.example.com/app/util/load?numRecords=33
