#!/bin/bash
#
# install redis as of http://redis.io/download
#
VERSION="3.0.1"
apt-get install -y wget make gcc unzip
echo "***INSTALLING redis version $VERSION"
cd /tmp/
wget http://download.redis.io/releases/redis-${VERSION}.tar.gz
dwhttp://download.redis.io/redis-${VERSION}.tar.gz
tar xvzf redis-${VERSION}.tar.gz
cd redis-${VERSION}
echo "***MAKING redis version $version"
sudo make
sudo make test
sudo make install
cd /tmp/
sudo rm -rf redis-${VERSION}*
/usr/local/bin/redis-server  --version

