# jenkins-ami
Use packer to bake an AMI to run the jenkins docker container

## Tools
We install your tools such as:
 + lxc-docker
 + curl
 + wget
 + ssh
 + vi
 + git
 + mosh
 + lynx
 + unzip
 + sudo
 + debconf-utils
 + emacs
 + python
 + packer
 + open-jdk-7u75-2.5.4-2 
 + chef

## Docker Container
We pull the docker container "ubuntu 14.04" and "jenkins"

## Files
shell-rights.json
This packer file explanes who to set sudo rights to a script as a provisioner.
We assume standard user ubuntu uses password ubuntu and use `execute_command` parameter.
This example is take from [Packer](https://www.packer.io/docs/provisioners/shell.html)
