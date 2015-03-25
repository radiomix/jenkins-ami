# Goal
We run Jenkins on an Instance stored AMI to convert it into an
EBS-backed AMI.
This [article](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ComponentsAMIs.html) explains the difference
between an Instance stored and an EBS stored AMI. 

+ Install and play with Jenkins on an Instance store AMI
+ Backup Jenkins effectively
+ Convert the current Jenkins AMI from an Instance stored AMI into an EBS backed AMI
+ Replay the Jenkins backup to the EBS backed AMI


## AMIs
As source AMIs we use two Ubuntu LTS Server AMIs
 + [ubuntu-precise-12.04-amd64-server](http://thecloudmarket.com/image/ami-a7785897--ubuntu-images-hvm-instance-ubuntu-precise-12-04-amd64-server-20150227) an Ubuntu 12.04 LTS Server x86_64 AMI, instance store for region us-west-2 
 + [ubuntu-trusty-14.04-amd64-server](http://thecloudmarket.com/image/ami-29ebb519--ubuntu-images-hvm-ssd-ubuntu-trusty-14-04-amd64-server-20150123) a Ubuntu 14.04 LTS Server x86_64 AMI, instance store for region us-west-2 

## Converting Instance stored into EBS stored AMI
The [AWS docu]( http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.htm) 
describes how to create and copy an instance stored AMI. We split the
task in two: First we install the AWS tools and check for AWS
credentials. Then we prepare and bundle the AMI. As the scripts depend on
exported environment variables, they have to be called with a period: 
``` bash
$:>. this-script.sh
```

### Files
 + [`aws-tools.sh`](aws-tools.sh) Installs `ec2-api-tools` and `ec2-ami-tools` and neccessary packages (`ruby`, `openjdk-7-jre`) and exports AWS credentials.
 + [`bundle_instance.sh`](bundle_instance.sh)
  - installs packages `gdisk`,`kpartx` and `grub` (legacy)
  - checks for command line kernel parameters and its counterpart in `/boot/grub/menu.lst` and edit them
  - checks for `efi` partitions in `/etc/fstab`
  - check the proper virtualization type with `curl -s http://169.254.169.254/latest/meta-data/profile/ | grep "default-"` returning [default-paravirtual|default-hvm] and set bundle parameters
  - bundles and uploads the image and registers an AMI

## Prerequest
`aws-stools.sh` reads and exports some environment variables:

### AWS
AWS credentials
 + `AWS_ACCESS_KEY="MY-ACCESS-KEY"`
 + `AWS_SECRET_KEY="My-Secret-Key"`
 + `AWS_ACCOUNT_ID="My-Account-Id"`
 + `AWS_REGION="My-Region"`
 + `AWS_ARCHITECTURE=" i386 | x86_6"`
 + `AWS_CERT_PATH="/path/to/my/x509-cert.pem"`
 + `AWS_PK_PATH="/path/to/my/x509-pk.pem"`

### EC2
AWS tools
 + `EC2_AMITOOL_HOME=$ami_tool`
 + `EC2_HOME=$api_tool`
 + `PATH=$PATH:$EC2_AMITOOL_HOME/bin:$EC2_HOME/bin`

### JAVA
Java binaries
 + `JAVA_HOME=$java_home`

### Usage
`bundle_instance.sh` asks several questions. These are parameters:

#### Paravirtual
virtualization type `paravirtual`
 * Is virtualization type:hvm correct? YES
 * --block-device-mapping NO

#### HVM
virtualization type `hvm`
 * Is virtualization type:hvm correct? YES
 * --block-device-mapping YES
 * Select root device [xvda|sda] in device mapping: SDA

## Packer Files
The approach is slightly adapted from [Building Ubuntu 12.04 and 14.04 HVM Instance Store AMIs](https://github.com/Lumida/packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs).
 + [`instance-12.04.json`](instance-12.04.json)  Backes AWS tools needed by the Instance stored AMI to be registerd as an Ubuntu 12.04 AMI.
 + [`instance-14.04.json`](instance-14.04.json)  Backes AWS tools needed by the Instance stored AMI to be registerd as an Ubuntu 14.04 AMI.
 + [`jenkins-12.04.json`](jenkins-12.04.json) This packer file bakes an Instance-stored AMI with jenkins installed on Ubuntu 12.04, serving as a test candidate to be transformed into a EBS-Backed AMI.
 + [`jenkins-14.04.json`](jenkins-14.04.json) This packer file bakes an Instance-stored AMI with jenkins installed on Ubuntu 14.04, serving as a test candidate to be transformed into a EBS-Backed AMI.

### Install Files
 + [`setup_ubuntu_hvm_instance_store_images.sh`](setup_ubuntu_hvm_instance_store_images.sh) This shell script adds JAVA and AWS tools to Ubuntu 14.04
 + [`gopath.sh`](gopath.sh) Adds the Go-Path to `/etc/profiles`
 + [`ec2-tools.sh`](ec2-tools.sh) Installs packages `ec2-api-tools` and `ec2-ami-tools`.

### Packages
We install these tools:
 + lxc-docker
 + curl, wget
 + ssh, vi, git, mosh, lynx, unzip, sudo
 + debconf-utils, emacs
 + python, golang
 + packer, chef
 + open-jdk-7u75-2.5.4-2 

## The Instance stored AMI

### Installing Jenkins on an Instance stored AMI
Packer file [`jenkins-12.04.json`](jenkins-12.04.json) backes an Instance stored AMI, as a playground to convert it into an EBS stored AMI.


### Running Jenkins as a Docker Container
To pull the docker containers 'jenkins' and run it:
```
docker run -p 8080:8080 jenkins:
```

## Changing Jenkins Setup

## EBS vs Instance store
| Characteristics | EBS stored | Instance store stored |
|---|---|---|
|boot  | < 1 min  | < 5 min   |
|persitence  | gets replicated, persists after the instance  | persists only during live of the instance  |
|upgrading  | type,kernel,ram disk, user-data can be changes while instance is stopped  | attributes are fixed   |
|charges  | per instance usage, EBS and snapshot storage | per usage and S3 storage   |
|AMI creation/bundling  | single command/call  | installation of AMI tools  |
|**stopped state**  | **root volume persists while instance is stopped** |  **cannot be stopped, instance runs or terminates (data loss)**  |

