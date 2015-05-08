#!/bin/bash
#
# install tools needed for redis, jenkins, rabitmq
#
echo ***INSTALLING TOOL
lsblk
df -h
sleep 2
sudo apt-get update
sudo apt-get install -y --force-yes curl wget git mosh gcc make lynx unzip docker.io build-essential phyton golang
which lynx mosh git vi wget unzip docker
echo ***INSTALLING JAVA 
sleep 2
sudo apt-get install -y default-jre
java -version
echo ***INSTALLING PACKAGES FOR VIM EXTENSION
sleep 2
sudo apt-get install -y ruby-dev rake exuberant-ctags ack-grep
#cd
#curl -Lo- https://bit.ly/janus-bootstrap | bash
df -h
sleep 2
