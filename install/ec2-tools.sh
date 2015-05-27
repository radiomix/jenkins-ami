#!/bin/bash
#
# prepare the source list to get apt-get install ec2-ami-tools and ec2-api-tools
#

AMI_TOOL_VERSION="1.4.0.9-0ubuntu2"
API_TOOL_VERSION="1.6.12.0-0ubuntu1"
echo "*** INSTALLING EC2 TOOLS"
##TODO check if installation source is allready listed
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
apt-get update
echo "*** INSTALLING API TOOLS version $API_TOOL_VERSION"
apt-get install -y --force-yes ec2-api-tools=$API_TOOL_VERSION
echo "*** INSTALLING AMI TOOLS version $AMI_TOOL_VERSION"
apt-get install -y --force-yes ec2-ami-tools=$AMI_TOOL_VERSION
