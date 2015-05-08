## jenkins-ami
Install Jenkins via `packer`


###Source AMI

As source AMIs we use Ubuntu 14.04 LTS Server x86_64 EBS-SSD AMI region
us-west-2 
 + [ubuntu-trusty-14.04-amd64](http://cloud-images.ubuntu.com/locator/ec2/) 

###Usage

```
$ packer build jenkins-ebs-14.04.json
```

###Packages
We install these tools/packages on the AMIs:
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

