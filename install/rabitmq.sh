#!/bin/bash
#
# install rabitmq as of https://www.rabbitmq.com/install-debian.html
#

echo "*** Installing rabitmq"
echo deb http://www.rabbitmq.com/debian/ testing main >>  /etc/apt/sources.list
wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc
sudo apt-get install -y rabbitmq-server

