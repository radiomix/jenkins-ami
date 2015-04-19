#!/bin/bash
#
# convert an Instance backed AMI into an EBS backed AMI
# http://sebastiandahlgren.se/2014/01/16/convert-an-aws-instance-store-ami-to-an-ebs-backed-ami/
# http://think-devops.blogspot.de/2013/09/convert-instance-store-ami-to-ebs.html
#
# Prerequests: 
#   - we need the the X509-cert-key-file.pem on the machine assuming under:
#        /tmp/cert/X509-cert-key-file.pem
#   - we need to export our $AWS_ACCESS_KEY and $AWS_SECRET_KEY as enironment variables like:
#       export AWS_ACCESS_KEY=your_access_key_id
#       export AWS_SECRET_KEY=your_secret_access_key
#   - we need the instance ID we want to convert $as aws_instance_id
#   - some commands need sudo rights
#

#######################################
## config variables

# bundle directory
bundle_dir="/tmp/bundle"
if [[ ! -d $bundle_dir ]]; then
  sudo mkdir $bundle_dir
fi
result=$(sudo test -w $bundle_dir && echo yes)
if [[ $result == yes ]]; then
  echo " ERROR: directory $bundle_dir to bundle the image is not writable!! "
  return -11
fi

# access key from env variable, needed for authentification
aws_access_key=$AWS_ACCESS_KEY

# secrete key from env variable, needed for authentification
aws_secret_key=$AWS_SECRET_KEY

# device and mountpoint of the new volume; we put our new AMI onto this device(aws_volume)
aws_ebs_device=/dev/xvdx
aws_ebs_mount_point=/mnt/ebs
if [[ ! -d $aws_ebs_mount_point ]]; then
  sudo mkdir $aws_ebs_mount_point
fi
result=$(sudo test -w $aws_ebs_mount_point && echo yes)
if [[ $result == yes ]]; then
  echo " ERROR: directory $aws_ebs_mount_point to mount the image is not writable!! "
  return -12
fi

# descriptions
aws_snapshot_description="Intermediate AMI snapshot, to be deleted after completion"
date=$(date)
aws_ami_name="Ubuntu LTS 12.04 Jenkins-Server as of $date"

# aws availability zone
aws_avail_zone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)

## instance id
aws_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)

# base AMI the instance was launched off, needed to get kernel, virtual. type etc
aws_ami_id=$AWS_AMI_ID
if [[ "$aws_ami_id" == "" ]]; then
  echo " ERROR: No AWS_AMI_ID given!! "
  exit -1
fi
echo "Using AMI id :$aws_ami_id"

# region
aws_region=$AWS_REGION
if [[ "$aws_region" == "" ]]; then
  echo " ERROR: No AWS_REGION given!! "
  exit -2
fi
echo "Using region: $aws_region"

# architecture
aws_architecture=$AWS_ARCHITECTURE
if [[ "$aws_architecture" == "" ]]; then
  echo " ERROR: No AWS_ARCHITECTURE given!! "
  exit -3
fi
echo "Using: architechture: $aws_architecture"


# x509 cert/pk file
if [[ "$AWS_PK_PATH" == "" ]]; then
  echo " ERROR: X509 private key file \"$AWS_PK_PATH\" not found!! "
  exit -21
fi
if [[ "$AWS_CERT_PATH" == "" ]]; then
  echo " ERROR: X509 cert key file \"$AWS_CERT_PATH\" not found!! "
  exit -22
fi

####TODO ### check for proper S3 bucket and manifest file
# AWS S3 Bucket 
s3_bucket=$AWS_S3_BUCKET
manifest=$AWS_MANIFEST


## config variables

######################################
## creating ebs volume to be bundle root dev
command=$(sudo -E $EC2_AMITOOL_HOME/bin/ec2-create-volume --size 10 --region $aws_region --availability-zone $aws_avail_zone)
rest=${command/VOLUME/""}
aws_volume_id=${rest:0:13}
echo "AWS-Volume created:$aws_volume_id"

######################################
## attache volume
sudo -u $EC2_AMITOOL_HOME/bin/ec2-attache-volume $aws_volume_id -i $aws_instance_id --device $aws_ebs_device --region $aws_region

######################################
## download and unbundle instance store based AMI
$EC2_AMITOOL_HOME/bin/ec2-download-bundle -b  $s3_bucket -m $manifest  -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --privatekey $AWS_PK_PATH -d $bundle_dir
cd $bundle_dir
$EC2_AMITOOL_HOME/bin/ec2-unbundle -m $manifest --privatekey $AWS_PK_PATH 

######################################
## copy image to EBS volume
sudo dd if=$bundle_dir/image of=$aws_ebs_device bs=1M
sudo partprobe $aws_ebs_device

######################################
## list block devices and mount EBS volume
lsblk
sudo mount $aws_ebs_device $aws_ebs_mount_point

######################################
## edit /etc/fstab to remove ephimeral partitions
echo "Edit /etc/fstab to remove ephimeral partitions"
grep ephimeral /etc/fstab
sleep 5
sudo vi /etc/fstab

######################################
## unmount EBS volume
sudo umount $aws_ebs_volume
$EC2_AMITOOL_HOME/bin/ec2-detach-volume $aws_volume_id --region $aws_region

#######################################
## create a snapshot and verify it
output=$($EC2_AMITOOL_HOME/bin/ec2-create-snapshot --region $aws_region -d $aws_snapshot_description -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY $aws_volume_id)
rest=${output/VOLUME/""}
aws_snapshot_id=${rest:0:13}
echo "Created snapshot:$aws_snapshot_id"

#######################################
## wait until snapshot is compleeted
completed=""
while [[ "$completed" == "" ]]
do
    completed=$($EC2_AMITOOL_HOME/bin/ec2-describe-snapshot --region $aws_region $aws_snapshot_id | grep completed)
    echo -n ". "
    sleep 3
done 

#######################################
## get processor architecture, virtualization type, and the kernel image (aki) 
## we might not get the proper description from the base image, if it was bundled
## without a description 
#command=$($EC2_AMITOOL_HOME/bin/ec2-describe-images --region $aws_region $aws_ami_id)
## but we can select a proper kernel for our region.
source select_pvgrub_kernel.sh

#######################################
## register a new AMI from the snapshot
aws_registerd_ami_id=$($EC2_AMITOOL_HOME/bin/ec2-register -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region $aws_region -n $aws_ami_name -s $aws_snapshot_id -a $AWS_ARCHITECTURE --kernel $AWS_KERNEL)
 

#######################################
## and delete the volume
## ec2-delete-volume $aws_volume_id 
#######################################

