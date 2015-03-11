# jenkins-ami
Use packer to bake an AMI to run the jenkins docker container

## Tools
We install our tools:
 + lxc-docker
 + curl, wget
 + ssh, vi, git, mosh, lynx, unzip, sudo
 + debconf-utils, emacs
 + python, golang
 + packer, chef
 + open-jdk-7u75-2.5.4-2 


## Files
 + `shell-rights.json` This packer file explanes who to set sudo rights to a script as a provisioner.
We assume standard user ubuntu uses password ubuntu and use `execute_command` parameter.
This example is take from [Packer](https://www.packer.io/docs/provisioners/shell.html)
 + `ubuntu-14.04-lts-jenkins-ami.json` This packer file bakes our jenkins docker AMI.
 + `gopath.sh` This is the shell script adding the Go-Path to `/etc/profiles`

## Installing Jenkins
As of [Installing Jenkins on Ubunut](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu) 
we ad the jenkins key to our installation sources and install the package:
```
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```
## What does this package do?
 + Jenkins will be launched as a daemon up on start. See /etc/init.d/jenkins for more details.
 + The 'jenkins' user is created to run this service.
 + Log file will be placed in /var/log/jenkins/jenkins.log. Check this file if you are troubleshooting Jenkins.
 + /etc/default/jenkins will capture configuration parameters for the launch like e.g JENKINS_HOME
 + By default, Jenkins listen on port 8080. Access this port with your browser to start configuration

## Running Jenkins as a Docker Container
We pull the docker containers "ubuntu 14.04" and "jenkins" and run the container:
```docker run -p 8080:8080 jenkins```

