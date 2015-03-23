#!/bin/bash
# Bundle Instance backed AMI, which was configured, to be registered as a new AMI
#  http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.htm
#
# Prerequests:
#    THE FOLLOWING IS USUMED:
#   - X509-cert-key-file.pem on the machine assuming under: /tmp/cert/, file path will be exported as AWS_CERT_PATH
#   - X509-pk-key-file.pem on the machine assuming under: /tmp/cert/, file path will be exported as AWS_PK_PATH
#   - AWS_ACCESS_KEY, AWS_SECRET_KEY and AWS_ACCOUNT_ID as enironment variables 
#   - AWS API/AMI tools installed and in $PATH
########## ALL THIS IS DONE BY SCRIPT prepare-aws-tools.sh ###################
#   - we need the instance ID we want to convert $as aws_instance_id
#   - some commands need sudo rights
# What we do
#   - install grub legacy version 0.9x or smaller
#   - install gdisk, kpartx to partition
#   - adjust kernel command line parameters in /boot/grub/menu.lst
#   - bundle the AMI locally (is there enough space on this machine?)
#   - upload the AMI
#   - register the AMI
#   - delete the local bundle

#######################################
## config variables
# access key from env variable, needed for authentification
aws_access_key=$AWS_ACCESS_KEY

# secrete key from env variable, needed for authentification
aws_secret_key=$AWS_SECRET_KEY

# region
aws_region=us-west-2

# descriptions
aws_ami_description="Intermediate AMI snapshot, to be deleted after completion"
date_fmt=$(date '+%F-%H-%M')
aws_ami_name="Ubuntu LTS 12.04 Jenkins-Server as of $date_fmt"

# bundle directory, should be on a partition with lots of space
bundle_dir="/mnt/image/"
if [[ ! -d $bundle_dir ]]; then
  sudo mkdir $bundle_dir
fi
if [[ ! -d $bundle_dir ]]; then
  echo " ERROR: directory $bundle_dir to bundle the image is not writable!! "
  exit -11
fi

# AWS S3 Bucket 
s3_bucket="im7-ami/images/copied/"

# x509 cert/pk file
if [[ "$AWS_PK_PATH" == "" ]]; then
  echo " ERROR: X509 private key file \"$AWS_PK_PATH\" not found!! "
  exit -21
fi
if [[ "$AWS_CERT_PATH" == "" ]]; then
  echo " ERROR: X509 cert key file \"$AWS_CERT_PATH\" not found!! "
  exit -22
fi

# image file prefix
prefix="copied"

## config variables

######################################
## packages needed anyways
echo "*** Installing packages 'gdisk kpartx'"
## packages needed anyways
#sudo apt-get update
sudo apt-get install -y gdisk kpartx

#######################################
## find root device to check grub version
echo "*** Checking for grub version"
lsblk
### read the root device
echo -n "Enter the root device: /dev/"
read _device
root_device="/dev/$_device"
## check for root defice
sudo fdisk -l $root_device
sudo file -s $root_device | grep "part /$"

#######################################
## check grub version, we need grub legacy
sudo grub-install --version
echo  "to be shure, we install grub verions 0.9x"
sudo apt-get install -y grub
grub_version=$(grub --version)
echo "We got grub version:$grub_version."

#######################################
### show boot cmdline parameter and adjust /boot/grub/menu.lst
echo "*** Checking for boot parameters"
echo "Next line holds boot command line parameters:"
cat /proc/cmdline
echo
echo "Next line holds kernel parameters in /boot/grub/menu.lst:"
grep ^kernel /boot/grub/menu.lst
echo
echo  "Do you want to adjust kernel parameter in /boot/grub/menu.list "
echo -n "to reflect command line? [y|N]:"
read edit
if  [[ "edit" == "y" ]]; then
  sudo vi /boot/grub/menu.lst
fi
#######################################
### remove evi entries in /etc/fstab if exist
echo "*** Checking for efi/uefi partitions in /etc/fstab"
efi=$(grep -i efi /etc/fstab)
if [[ "$efi" != "" ]]; then
  echo "Please delete these UEFI/EFI partition entries \"$efi\" in /etc/fstab"
  read -t 20
  sudo vi /etc/fstab
fi

#######################################
### do we need --block-device-mapping to bundle?
echo "Do you want to bundle with parameter \"--block-device-mapping \"? [y|N]:"
blockDevice=""
read blockDevice
if  [[ "$blockDevice" == "y" ]]; then
  echo "Root device is set to \"$root_dev\. Select root device [sda|xvda] in device mapping:[s|X]" 
  if  [[ "$blockDevice" == "s" ]]; then
    blockDevice="  --block-device-mapping ami=sda,root=/dev/sda1 "
    prefix=$prefix"-sda"
  else
    blockDevice="  --block-device-mapping ami=xvda,root=/dev/xvda1 "
    prefix=$prefix"-xvda"
  fi
  echo "Using \"$blockDevice\"  "
fi

#######################################
## on hvm AMI we need mbr/hvm parameters
echo "Is this AMI of virtualization type \"hvm\"? [y|N]:"
partition=""
virtual_type="--virtualization-type paravirtual"
read partition
if  [[ "$partition" == "y" ]]; then
  partition="  --partition mbr "
  virtual_type="--virtualization-type hvm"
  echo "Using --partition mbr "
  echo "Using --virtualization-type hvm "
  sleep 5
fi

#######################################
### this is bundle-work
sudo -E $EC2_HOME/bin/ec2-version
##FIXME ami name not properly set (check date function)
echo "*** Bundleing AMI, this may take several minutes "
sudo -E $EC2_AMITOOL_HOME/bin/ec2-bundle-vol -k $AWS_PK_PATH -c $AWS_CERT_PATH -u $AWS_ACCOUNT_ID -r x86_64 -e /tmp/cert/ -d $bundle_dir -p $prefix$date_fmt  $blockDevice $partition --batch
##TODO adjust ami name to ec2-bundle-vol command
echo "*** Uploading AMI bundle to $s3_bucket "
ec2-upload-bundle -b $s3_bucket -m $bundle_dir/$prefix$date_fmt.manifest.xml -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --region $aws_region
echo "*** Registering images"
ec2-register   $s3_bucket/$prefix$date_fmt.manifest.xml -v $virtual_type -n "$aws_ami_name" -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region $aws_region
echo "*** "
echo "*** PARAMETER USED:"
echo "*** Root device:$root_device"
echo "*** Grub version:"$(grub --version)
echo "*** Bundle folder:$bundle_dir"
echo "*** Block device mapping:$blockDevice"
echo "*** Partition flag:$partition"
echo "*** Virtualisation:$virtual_type"
echo "*** S3 Bucket:$s3_bucket"
echo "*** Region:$aws_region"
echo "*** AMI name:$aws_ami_name"
echo "*** "
echo "*** FINISHED BUNDLING THE AMI"

