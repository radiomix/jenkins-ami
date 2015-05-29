#!/bin/bash
#
# install jenkins as of https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu
#

VERSION="1.615"

echo "***INSTALLING JENKINS VERSION $VERSION"
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins=$VERSION
# disable service jenkins on boot
# service should be enabled by chef-client run
sudo update-rc.d  jenkins disable
sudo service jenkins stop
