## jenkins-ami
Install Jenkins via `packer`


## AMIs

As source AMIs we use two Ubuntu LTS Server AMIs
 + [ubuntu-precise-12.04-amd64-server](http://thecloudmarket.com/image/ami-a7785897--ubuntu-images-hvm-instance-ubuntu-precise-
   12-04-amd64-server-20150227) 
an Ubuntu 12.04 LTS Server x86_64 AMI, instance store for region
us-west-2 
 + [ubuntu-trusty-14.04-amd64-server](http://thecloudmarket.com/image/ami-29ebb519--ubuntu-images-hvm-ssd-ubuntu-trusty-14-04-
   amd64-server-20150123) 
an Ubuntu 14.04 LTS Server x86_64 AMI, instance store for region
us-west-2 

## Packer Files
The approach is slightly adapted from [Building Ubuntu 12.04 and 14.04
HVM Instance Store AMIs](https://github.com/Lumida/
packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs).
All AMIs are Instance Stored.
 + [`instance-12.04.json`](instance-12.04.json) backes an AMI with AWS tools 
on an instance stored AMI under Ubuntu 12.04
AMI.
 + [`instance-14.04.json`](instance-14.04.json) backes an AMI AWS tools 
on an instance stored AMI under Ubuntu 14.04 AMI.
 + [`jenkins-12.04.json`](jenkins-12.04.json) bakes 
an AMI with jenkins installed under Ubuntu 12.04
 + [`jenkins-14.04.json`](jenkins-14.04.json) bakes 
an AMI with jenkins installed under Ubuntu 14.04

### Install Files
 + [`setup_ubuntu_hvm_instance_store_images.sh`](setup_ubuntu_hvm_instance_store_images.sh) 
This shell script adds JAVA and AWS tools to Ubuntu 14.04
 + [`gopath.sh`](gopath.sh) Adds the Go-Path to `/etc/profiles`
 + [`ec2-tools.sh`](ec2-tools.sh) Installs packages `ec2-api-tools` and
   `ec2-ami-tools`.

### Packages
We install these tools on jenkins AMIs:
 + lxc-docker
 + curl, wget
 + ssh, vi, git, mosh, lynx, unzip, sudo
 + debconf-utils, emacs
 + python, golang
 + packer, chef
 + default-jre (jdk 6 or 7)

