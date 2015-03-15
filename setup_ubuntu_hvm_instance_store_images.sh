#!/bin/bash
#
# Installs AWS tools and JAVA
# https://github.com/Lumida/packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs
# slightly addapted
#

echo "*** PREPAIRING "
DEBIAN_FRONTEND=noninteractive
UCF_FORCE_CONFFNEW=true
export UCF_FORCE_CONFFNEW DEBIAN_FRONTEND

apt-get update
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" install ruby1.9.3
apt-get clean

echo "*** INSTALLING GRUB "
# ec2-bundle-vol requires legacy grub and there should be no console setting
apt-get -y install grub
sed -i 's/console=hvc0/console=ttyS0/' /boot/grub/menu.lst
# the above is sufficient to fix 12.04 but 14.04 also needs the following
sed -i 's/LABEL=UEFI.*//' /etc/fstab

echo "*** INSTALLING JAVA ***"
cd /usr/local/
mkdir ami_tools java api_tools ec2
mkdir ec2/bin ec2/lib ec2/etc
export EC2_HOME=/usr/local/ec2/bin
export JAVA_HOME=/usr/local/java/jdk1.8.0_05/bin
export PATH=$PATH:$EC2_HOME:$JAVA_HOME
apt-get -y install unzip kpartx
wget --progress=bar -nv --no-cookies --no-check-certificate --header "Cookie: gpw_e24=h; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u5-b13/server-jre-8u5-linux-x64.tar.gz -O /tmp/server-jre-8u5-linux-x64.tar.gz
mv /tmp/server-jre-8u5-linux-x64.tar.gz java/
cd java
tar -xzvf server-jre-8u5-linux-x64.tar.gz
cd ../ami_tools

echo "*** INSTALLING AWS TOOLS "
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.3.zip
unzip ec2-ami-tools-1.5.3.zip
cd ../api_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip
cd ..
mv -v ami_tools/ec2-ami-tools*/bin/* api_tools/ec2-api-tools*/bin/* ec2/bin/
mv -v ami_tools/ec2-ami-tools*/lib/* api_tools/ec2-api-tools*/lib/* ec2/lib/
mv -v ami_tools/ec2-ami-tools*/etc/* api_tools/ec2-api-tools*/etc/* ec2/etc/

passwd -d ubuntu
rm /home/ubuntu/.ssh/authorized_keys
echo "*** FINISHED "
