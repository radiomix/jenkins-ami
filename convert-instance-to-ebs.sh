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

# access key from env variable, needed for authentification
aws_access_key=$AWS_ACCESS_KEY

# secrete key from env variable, needed for authentification
aws_secret_key=$AWS_SECRET_KEY

# base AMI the instance was launched off, needed to get kernel, virtual. type etc
aws_ami_id=ami-bdab868d

# device and mountpoint of the new volume, we put our new AMI onto this device(aws_volume)
aws_device=/dev/xvdx
aws_mount_point=/mnt/ebs

# descriptions
aws_snapshot_description="Intermediate AMI snapshot, to be deleted after completion"
date=$(date)
aws_ami_name="Ubuntu LTS 12.04 Jenkins-Server as of $date"


# region
aws_region=$AWS_REGION
if [[ "$aws_region" == "" ]]; then
  echo " ERROR: No AWS_REGION given!! "
  return -2
fi
echo "Using region: $aws_region"

# architecture
aws_architecture=$AWS_ARCHITECTURE
if [[ "$aws_architecture" == "" ]]; then
  echo " ERROR: No AWS_ARCHITECTURE given!! "
  return -3
fi
echo "Using region: $aws_region"

# aws availability zone
aws_avail_zone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)

## instance id
aws_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)

## config variables

######################################
## creating ebs volume to be bundle root dev
command=$(sudo -E $EC2_AMITOOL_HOME/bin/ec2-create-volume --size 10 --region $aws_region --availability-zone $aws_avail_zone)
rest=${command/VOLUME/""}
aws_volume_id=${rest:0:12}

######################################
## attache volume
sudo -u $EC2_AMITOOL_HOME/bin/ec2-attache-volume $aws_volume_id -i $aws_instance_id --device /dev/xvdx --region $aws_region

mkdir $bundle_dir

####TODO we are at step 6 of docu!
# download bundle, unbundle dd to attached volume,  . . . 


#######################################
## create a snapshot and verify it
aws_snapshot_id=$(ec2-create-snapshot --region $aws_region -d $aws_snapshot_description -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY $aws_volume_id)
#### FIXME get the snapshot-id from command output as $aws_snapshot_id
result=$(ec2-describe-snapshots --region $aws_region $aws_snapshot_id)
#### FEXME get last argument: 100%


#######################################
## get processor architecture, virtualization type, and the kernel image (aki) 
aws_achitecture=$(ec2-describe-images --region $aws_region $aws_ami_id)

#######################################
## register a new AMI from the snapshot
aws_registerd_ami_id=$(ec2-register --region $aws_region -n $aws_ami_name -s $aws_snapshot_id -a x86_64)
#### FIXME get the new registerd ami-id from command output as $aws_registerd_ami_id
 

#######################################
## and delete the volume
## ec2-delete-volume $aws_volume_id 
#######################################

# AWS S3 Bucket 
s3_bucket="im7-ami/images/copied"

# x509 cert/pk file
if [[ "$AWS_PK_PATH" == "" ]]; then
  echo " ERROR: X509 private key file \"$AWS_PK_PATH\" not found!! "
  return -21
fi
if [[ "$AWS_CERT_PATH" == "" ]]; then
  echo " ERROR: X509 cert key file \"$AWS_CERT_PATH\" not found!! "
  return -22
fi

mkdir /tmp/bundle



####TODO
#### check for proper S3 bucket name!


#######################################
### this is bundle-work
sudo -E $EC2_HOME/bin/ec2-version
echo "*** Bundleing AMI, this may take several minutes "
set -x
sudo -E $EC2_AMITOOL_HOME/bin/ec2-bundle-vol -k $AWS_PK_PATH -c $AWS_CERT_PATH -u $AWS_ACCOUNT_ID -r x86_64 -e /tmp/cert/ -d $bundle_dir -p $prefix$date_fmt  $blockDevice $partition --batch
##TODO adjust ami name to ec2-bundle-vol command
echo "*** Uploading AMI bundle to $s3_bucket "
ec2-upload-bundle -b $s3_bucket -m $bundle_dir/$prefix$date_fmt.manifest.xml -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --region $aws_region
## only ec2-register needs jre installed!
echo "*** Registering images"
ec2-register   $s3_bucket/$prefix$date_fmt.manifest.xml $virtual_type -n "$aws_ami_name" -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region $aws_region --architecture $aws_architecture 
set +x
echo "*** "
echo "*** PARAMETER USED:"
echo "*** Root device:"$root_device
echo "*** Grub version:"$(grub --version)
echo "*** Bundle folder:"$bundle_dir
echo "*** Block device mapping:"$blockDevice
echo "*** Partition flag:"$partition
echo "*** Virtualization:"$virtual_type
echo "*** S3 Bucket:"$s3_bucket
echo "*** Region:"$aws_region
echo "*** AMI name:"$aws_ami_name
echo "*** "
echo "*** FINISHED BUNDLING THE AMI"

