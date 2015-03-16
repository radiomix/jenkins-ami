#!/bin/bash
#
# Installs AWS tools
# https://github.com/Lumida/packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs
# slightly addapted
#


echo "*** INSTALLING AWS TOOLS "
cd /usr/local/
mkdir ami_tools java api_tools ec2
mkdir ec2/bin ec2/lib ec2/etc
export EC2_HOME=/usr/local/ec2/bin
export PATH=$PATH:$EC2_HOME
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.3.zip
unzip ec2-ami-tools-1.5.3.zip
cd ../api_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip
cd ..
mv -v ami_tools/ec2-ami-tools*/bin/* api_tools/ec2-api-tools*/bin/* ec2/bin/
mv -v ami_tools/ec2-ami-tools*/lib/* api_tools/ec2-api-tools*/lib/* ec2/lib/
mv -v ami_tools/ec2-ami-tools*/etc/* api_tools/ec2-api-tools*/etc/* ec2/etc/
echo "EC2_HOME: $EC2_HOME"
