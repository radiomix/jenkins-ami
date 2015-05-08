#!/bin/bash
#
# install redis as of http://redis.io/topics/quickstart
#
apt-get install -y wget make gcc unzip
echo "***INSTALLING redis"
cd /tmp/
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
echo "***MAKING redis"
sudo make
sudo make test
sudo make install
cd /tmp/
sudo rm -rf redis-stable*
