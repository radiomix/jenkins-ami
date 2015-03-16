# jenkins-ami
We run Jenkins on an Instance-Backed AMI to convert it into an EBS-Backed AMI.

## Goal
+ Install and play with Jenkins on an Instance backed AMI
+ Backup Jenkins effectively
+ Convert the current Jenkins AMI from an Instance backed AMI into an EBS backed AMI
+ Replay the Jenkins backup to the EBS backed AMI

## Setup

### Tools
We install these tools:
 + lxc-docker
 + curl, wget
 + ssh, vi, git, mosh, lynx, unzip, sudo
 + debconf-utils, emacs
 + python, golang
 + packer, chef
 + open-jdk-7u75-2.5.4-2 

### AMIs
As source AMIs we use two Ubuntu LTS Server AMIs
 + [ubuntu-precise-12.04-amd64-server](http://thecloudmarket.com/image/ami-a7785897--ubuntu-images-hvm-instance-ubuntu-precise-12-04-amd64-server-20150227) an Ubuntu 12.04 LTS Server x86_64 AMI, instance store for region us-west-2 
 + [ubuntu-trusty-14.04-amd64-server](http://thecloudmarket.com/image/ami-29ebb519--ubuntu-images-hvm-ssd-ubuntu-trusty-14-04-amd64-server-20150123) a Ubuntu 14.04 LTS Server x86_64 AMI, instance store for region us-west-2 

### Packer Files
The approach is slightly addapted from [Building Ubuntu 12.04 and 14.04 HVM Instance Store AMIs](https://github.com/Lumida/packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs).
 + [`instance-12.04.json`](instance-12.04.json)  Backes AWS tools needed by the Instance backed AMI to be registerd as an Ubuntu 12.04 AMI.
 + [`instance-14.04.json`](instance-14.04.json)  Backes AWS tools needed by the Instance backed AMI to be registerd as an Ubuntu 14.04 AMI.
 + [`jenkins-12.04.json`](jenkins-12.04.json) This packer file bakes an Instance-Backed AMI with jenkins installed on Ubuntu 12.04, serving as a test candidate to be transformed into a EBS-Backed AMI.
 + [`jenkins-14.04.json`](jenkins-14.04.json) This packer file bakes an Instance-Backed AMI with jenkins installed on Ubuntu 14.04, serving as a test candidate to be transformed into a EBS-Backed AMI.

### Install Files
 + [`setup_ubuntu_hvm_instance_store_images.sh`](setup_ubuntu_hvm_instance_store_images.sh) This shell script adds JAVA and AWS tools to Ubuntu 14.04
 + [`gopath.sh`](gopath.sh) This shell script adds the Go-Path to `/etc/profiles`
 + [`ec2-tools.sh`](ec2-tools.sh) Shell script to install packages `ec2-api-tools` and `ec2-ami-tools`.

## The Instance backed AMI

## Installing Jenkins on an Instance backed AMI
Packer file [`jenkins-12.04.json`](jenkins-12.04.json) backes an Instance backed AMI, as a playground to convert it into an EBS backed AMI.

### Installing Jenkins as a package
As of [Installing Jenkins on Ubunut](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu) 
we ad the jenkins key to our installation sources and install the package:
```
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get installi -y jenkins
```
### What does this package do?
 + Jenkins will be launched as a daemon up on start. See /etc/init.d/jenkins for more details.
 + The 'jenkins' user is created to run this service.
 + Log file will be placed in /var/log/jenkins/jenkins.log. Check this file if you are troubleshooting Jenkins.
 + /etc/default/jenkins will capture configuration parameters for the launch like e.g JENKINS_HOME
 + By default, Jenkins listen on port 8080. Access this port with your browser to start configuration

### Running Jenkins as a Docker Container
To pull the docker containers 'jenkins' and run it:
```
docker run -p 8080:8080 jenkins:
```

## Changing Jenkins Setup

## Converting Instance backed into EBS backed AMI

