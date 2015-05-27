#!/bin/bash
#
# install rabitmq as of https://www.rabbitmq.com/install-debian.html
#
VERSION="3.2.4-1"

echo "*** Installing rabitmq version $VERSION"
##TODO check if installation source is allready listed
echo deb http://www.rabbitmq.com/debian/ testing main >>  /etc/apt/sources.list
wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc
sudo apt-get install -y rabbitmq-server=$VERSION

