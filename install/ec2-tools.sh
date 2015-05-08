#!/bin/bash
#
# prepare the source list to get apt-get install ec2-ami-tools and ec2-api-tools
#
echo "*** INSTALLING EC2 TOOLS"
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
apt-get update
apt-get install -y --force-yes ec2-api-tools 
apt-get install -y --force-yes ec2-ami-tools
