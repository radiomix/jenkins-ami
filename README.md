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
   ack-grep
 + default-jre
 + ec2 tools, ec2 api
 + docker, packer
 + golang, phyton, ruby, rake
 + chefjdk
 + rabitmq-server
 + redis
 + nodes.js
 + etcd

