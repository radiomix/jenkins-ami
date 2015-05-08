#!/bin/bash
#
# install nodes.js as of https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
#

echo "***INSTALLING nodes.js"
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install nodejs
