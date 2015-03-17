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

# access key from env variable, needed for authentification
aws_access_key=$AWS_ACCESS_KEY

# secrete key from env variable, needed for authentification
aws_secret_key=$AWS_SECRET_KEY

# region
aws_region=us-west-2

# availability zone
aws_availability_zone=us-west-2a

# base AMI the instance was launched off, needed to get kernel, virtual. type etc
aws_ami_id=ami-bdab868d

# device and mountpoint of the new volume, we put our new AMI onto this device(aws_volume)
aws_device=/dev/xvdc
aws_mount_point=/mnt/ebs

# descriptions
aws_snapshot_description="Intermediate AMI snapshot, to be deleted after completion"
date=$(date)
aws_ami_name="Ubuntu LTS 12.04 Jenkins-Server as of $date"
## config variables

#######################################
## Create an EBS volume bigger than the instance backed AMI
##
aws_volume_result=$(ec2-create-volume --size 10 --region $aws_region --availability-zone $aws_availability_zone)
###FIXME  get the second argument as the $aws_volume_id


#######################################
## Attach the volume: as of 03/2015 kernel mounts volumens /dev/xvd[a,b,c, . . .]
##
ec2-attach-volume $aws_volume_id -i $aws_instance_id --device $aws_device --region $aws_region

#######################################
## Create a file system on the new volume and mount it
##
mkfs.ext3 $aws_device
mkdir -p $aws_mount_point
mount $aws_device $aws_mount_point

#######################################
## Shutdown all services (DB/APACHE/JENKINS ???)
## and sync the new volume
rsynx -avHx  --exclude $aws_mount_point  / $aws_mount_point
## either sync the device 
#rsync -avHx /dev $aws_mount_point
## or remake them
# MAKEDEV console 
# MAKEDEV generic
# MAKEDEV zero
# MAKEDEV null

#######################################
#####  MAYBE NOT NEEDED???  
echo "
## replacint in /etc/fstab, /boot/grub/menu.lst and /boot/grub/grub.cfg 
## under mount point $aws_mount_point 
## \"LABEL=cloudimg-rootfs\" with \"/dev/xvda1"\ 
##
"
### TODO should be cone with sed!!
vi $aws_mount_point/etc/fstab
vi $aws_mount_point/boot/grub/menu.lst
vi $aws_mount_point/boot/grub/grub.cfg

#######################################
## unmount and detach the volume
umount $aws_device
ec2-detach-volume $aws_volume_id --region $aws_region

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
ec2-delete-volume $aws_volume_id 
