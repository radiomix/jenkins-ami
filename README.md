## jenkins-ami
Install Jenkins and build tools on Ubuntu 14.04 via `packer`


###Source AMI

As source AMI we use Ubuntu 14.04 LTS Server x86_64 EBS-SSD AMI region
us-west-2
 + [ubuntu-trusty-14.04-amd64 (ami-3189b801)](http://cloud-images.ubuntu.com/locator/ec2/)

###Usage

```
$ packer build jenkins-ebs-14.04.json
```

###Packages
We install these tools/packages on the AMI:
 + curl, wget, git, mosh, lynx, unzip, gcc, make, build-essentials,
   ack-grep, tree, htop
 + default-jre
 + ec2 tools, ec2 api
 + docker, packer
 + golang, phyton, ruby, rake
 + chefjdk
 + jenkins
 + rabbitmq-server
 + redis
 + nodes.js
 + etcd

The services installed under `install/service.sh` are versioned by a
variable inside the shell script.

###Services
Services `jenkins`,`etcd` and  `rabbitmq-server` are not enabled at
boot time by default. We expect a `chef-client` run to enable these
services running: 
`:$ sudo update-rc.d SERVICE start 19 2 3 4 5 . stop 19 0 1 6 .`
