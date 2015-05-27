#!/bin/bash
#
# install nodes.js as of https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
#

# v 0.10=stable, 0.12=dev
VERSION="0.10"

echo "***INSTALLING nodes.js version $VERSION"
#curl -sL https://deb.nodesource.com/setup | sudo bash -
curl -sL "https://raw.githubusercontent.com/nodesource/distributions/master/deb/setup_${VERSION}" > setup_${VERSION}
sudo bash setup_${VERSION}
sudo apt-get install -y nodejs
rm -f setup_${VERSION}

