#!/bin/bash
#
# install redis as of http://redis.io/topics/quickstart
#

echo "***INSTALLING redis"
cd /usr/local/
wget http://download.redis.io/redis-stable.tar.gz
sudo tar xvzf redis-stable.tar.gz
cd redis-stable
echo "***MAKING redis"
sudo make
sudo make test
sudo make install
sudo rm redis-stable.tar.gz
