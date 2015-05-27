#!/bin/bash
#
# install chef as of https://www.chef.io/download-chef-client/
#
VERSION="0.6.0-1_amd64"

echo "***INSTALLING Chef"
#curl -L https://www.opscode.com/chef/install.sh | sudo bash
curl -L https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_${VERSION}.deb > chefdk_${VERSION}.deb
# Install Chef
ls -l  chefdk_${VERSION}.deb
sudo dpkg -i chefdk_${VERSION}.deb
rm -f  chefdk_${VERSION}.deb

which chef
