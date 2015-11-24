#!/bin/bash

# Setup a new docker env if it doesn't exist
docker-machine create -d virtualbox demodev
# Set the environment for the current session
eval "$(docker-machine env demodev)"

# Setup the MongoDB
docker create -v /data/db --name dbdata debian:wheezy /bin/true
docker run -d --name enrolldb --volumes-from dbdata mongo:2.4.14

# Setup 3 instances of the backend app
docker run -d --link enrolldb:mongo --name app-1 -e VIRTUAL_HOST="*/app/*" namehta/enrollment-app:tomcat
docker run -d --link enrolldb:mongo --name app-2 -e VIRTUAL_HOST="*/app/*" namehta/enrollment-app:tomcat
docker run -d --link enrolldb:mongo --name app-3 -e VIRTUAL_HOST="*/app/*" namehta/enrollment-app:tomcat

# Setup 2 instances of the frontend app
docker run -d --name ui-1 -e VIRTUAL_HOST="demoapp.example.com" namehta/enrollment-ui
docker run -d --name ui-2 -e VIRTUAL_HOST="demoapp.example.com" namehta/enrollment-ui

# Setup the proxy
docker run -d -p 80:80 --link app-1:app-1 --link app-2:app-2 --link app-3:app-3 --link ui-1:ui-1 --link ui-2:ui-2 tutum/haproxy

# Add an entry for demoapp.example.com to /etc/hosts
if [ -n "$(grep 'demoapp.example.com' /etc/hosts)" ]
then
    sudo sed -i".bak" "/demoapp.example.com/d" /etc/hosts
fi
sudo sh -c "echo '$(docker-machine ip demodev)  demoapp.example.com' >> /etc/hosts"

# Load the sample data
sleep 15
curl http://demoapp.example.com/app/util/load?numRecords=33
