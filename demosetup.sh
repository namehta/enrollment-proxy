#!/bin/bash

# Setup a new docker env if it doesn't exist
docker-machine create -d virtualbox demodev
# Set the environment for the current session
eval "$(docker-machine env demodev)"

#Start the docker containers via docker-compose
docker-compose up -d

#Scale up the web and app containers
docker-compose scale app=3 ui=2

#Have to run this for HAProxy to pick up the new containers.  It's a docker-compose bug
docker-compose up --force-recreate -d

# Add an entry for demoapp.example.com to /etc/hosts
if [ -n "$(grep 'demoapp.example.com' /etc/hosts)" ]
then
    sudo sed -i".bak" "/demoapp.example.com/d" /etc/hosts
fi
sudo sh -c "echo '$(docker-machine ip demodev)  demoapp.example.com' >> /etc/hosts"

# Load the sample data
sleep 15
curl http://demoapp.example.com/app/util/load?numRecords=33
