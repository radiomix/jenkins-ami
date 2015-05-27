#!/bin/bash
#
# install packer as of https://dl.bintray.com/mitchellh/packer/packer_$version_linux_amd64.zip
#

VERSION="0.7.5"

echo "***INSTALLING PACKER"
sudo mkdir -p /usr/local/bin
cd /usr/local/bin
curl -L https://dl.bintray.com/mitchellh/packer/packer_${VERSION}_linux_amd64.zip > packer_${VERSION}_linux_amd64.zip
sudo unzip packer_${VERSION}_linux_amd64.zip
sudo rm -f packer_${VERSION}_linux_amd64.zip
which packer
