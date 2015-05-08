#!/bin/bash
#
# install packer as of https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip
#

echo "***INSTALLING PACKER"
sudo mkdir -p /usr/local/bin
cd /usr/local/bin
curl -L https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip > packer_0.7.5_linux_amd64.zip
sudo unzip packer_0.7.5_linux_amd64.zip
sudo rm -f packer_0.7.5_linux_amd64.zip
which packer
