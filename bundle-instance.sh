#!/bin/bash
# Bundle Instance backed AMI, which was configured, to be registered as a new AMI
#  http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.htm
#
# Prerequisite:
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
aws_region=$AWS_REGION
if [[ "$aws_region" == "" ]]; then
  echo " ERROR: No AWS_REGION given!! "
  return -2
fi
echo "Using region:$aws_region"

# architecture
aws_architecture=$AWS_ARCHITECTURE
if [[ "$aws_architecture" == "" ]]; then
  echo " ERROR: No AWS_ARCHITECTURE given!! "
  return -3
fi
echo "Using architecture:$aws_architecture"


# ami descriptions and ami name
aws_ami_description="Intermediate AMI snapshot, for backup-reasons"
date_fmt=$(date '+%F-%H-%M')
string=$(grep ID /etc/lsb-release)
id=${string##*=}
string=$(grep RELEASE /etc/lsb-release)
release=${string##*=}
aws_ami_name="$id-$release-bundle-instance-$date_fmt"

# bundle directory, should be on a partition with lots of space
bundle_dir="/mnt/image/"
if [[ ! -d $bundle_dir ]]; then
  sudo mkdir $bundle_dir
fi
result=$(sudo test -w $bundle_dir && echo yes)
if [[ $result == yes ]]; then
  echo " ERROR: directory $bundle_dir to bundle the image is not writable!! "
  return -11
fi

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

# image file prefix
prefix="bundle-instance-"

# log file
log_file=bundle-$date_fmt.log
touch $log_file

# AMI id we are bundling (This one!)
current_ami_id=$(curl -s http://169.254.169.254/latest/meta-data/ami-id) 
output=$($EC2_AMITOOL_HOME/bin/ec2-describe-images --region $aws_region $current_ami_id)
echo "*** Bundling AMI:$current_ami_id:"$output
echo "*** Bundling AMI:$current_ami_id:"$output >> $log_file

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
mount | grep sda
lsblk  #not on all distros available
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
echo  "*** Installing grub verions 0.9x"
sudo apt-get install -y grub
grub_version=$(grub --version)
echo "*** Grub version:$grub_version."

#######################################
### show boot cmdline parameter and adjust /boot/grub/menu.lst
echo "*** Checking for boot parameters"
echo "*** Next line holds boot command line parameters:"
cat /proc/cmdline
echo "*** Next line holds kernel parameters in /boot/grub/menu.lst:"
grep ^kernel /boot/grub/menu.lst
echo
echo  "Do you want to edit kernel parameter in /boot/grub/menu.list "
echo -n "to reflect command line? [y|N]:"
read edit
if  [[ "$edit" == "y" ]]; then
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
### what virtualization type are we?
### we check curl -s http://169.254.169.254/latest/meta-data/profile/
### returning [default-paravirtual|default-hvm]
meta_data_profile=$(curl -s http://169.254.169.254/latest/meta-data/profile/ | grep "default-")
profile=${meta_data_profile##default-}
### remember virtual. type in s3-bucket name and parameter virtual. type
## s3_bucket=$s3_bucket"/"$profile
virtual_type="--virtualization-type "$profile" "
aws_ami_name=$aws_ami_name"-"$profile

echo "*** Checking virtualization parameter for type:$profile"
## on paravirtual AMI every thing is fine here
partition=""
## for hvm AMI we set partition mbr
echo "Is virtualization type:$profile correct? [y|N]"
read parameter
if [[ "$parameter" == "y" ]]; then
  if  [[ "$profile" == "hvm" ]]; then
    partition="  --partition mbr "
  fi
fi

#######################################
### do we need --block-device-mapping to bundle?
echo "Do you want to bundle with parameter \"--block-device-mapping \"? [y|N]:"
read blockDevice
if  [[ "$blockDevice" == "y" ]]; then
  echo "Root device is set to \"$root_device\". Select root device [xvda|sda] in device mapping:[x|S]"
  read blockDevice
  if  [[ "$blockDevice" == "x" ]]; then
    blockDevice="  --block-device-mapping ami=xvda,root=/dev/xvda1 "
    prefix=$prefix"xvda-"
    ## s3_bucket=$s3_bucket"/xvda"
  else
    blockDevice="  --block-device-mapping ami=sda,root=/dev/sda1 "
    prefix=$prefix"sda-"
    ##s3_bucket=$s3_bucket"/sda"
  fi
else
    blockDevice=""
fi


#######################################
echo "*** Using partition:     $partition"
echo "*** Using virtual_type:  $virtual_type"
echo "*** Using block_device:  $blockDevice"
echo "*** Using s3_bucket:     $s3_bucket"
## write parameter to log file
echo "*** Using partition:     $partition" >> $log_file
echo "*** Using virtual_type:  $virtual_type"  >> $log_file
echo "*** Using block_device:  $blockDevice"  >> $log_file
echo "*** Using s3_bucket:     $s3_bucket"  >> $log_file
echo "***"  >> $log_file
sleep 5
start=$SECONDS

#######################################
### this is bundle-work
sudo -E $EC2_HOME/bin/ec2-version
echo "*** Bundleing AMI, this may take several minutes "
set -x
sudo -E $EC2_AMITOOL_HOME/bin/ec2-bundle-vol -k $AWS_PK_PATH -c $AWS_CERT_PATH -u $AWS_ACCOUNT_ID -r x86_64 -e /tmp/cert/ -d $bundle_dir -p $prefix$date_fmt  $blockDevice $partition --batch

echo "*** Uploading AMI bundle to $s3_bucket "
ec2-upload-bundle -b $s3_bucket -m $bundle_dir/$prefix$date_fmt.manifest.xml -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --region $aws_region

echo "*** Registering images"
output=$(ec2-register   $s3_bucket/$prefix$date_fmt.manifest.xml $virtual_type -n "$aws_ami_name" -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region $aws_region --architecture $aws_architecture )
echo $output
echo $output >> $log_file
aws_ami_id=${echo $output | cut -d ' ' -f 2}

set +x

export AWS_AMI_ID=$aws_ami_id
export AWS_S3_BUCKER=$s3_bucket
export AWS_MANIFEST=$prefix$date_fmt.manifest.xml

## profiling
end=$SECONDS
period=$(($end - $start))

echo "*** "
echo "*** PARAMETER USED:"
echo "*** Root device:"$root_device
echo "*** Grub version:"$(grub --version)
echo "*** Bundle folder:"$bundle_dir
echo "*** Block device mapping:"$blockDevice
echo "*** Partition flag:"$partition
echo "*** Virtualization:"$virtual_type
echo "*** S3 Bucket:"$s3_bucket
echo "*** Manifest:"$prefix$date_fmt.manifest.xml
echo "*** Region:"$aws_region
echo "*** AMI name:"$aws_ami_name
echo "*** AMI Id:"$aws_ami_id 
echo "*** "
echo "*** FINISHED Bundling AMI:$current_ami_id  in $period seconds"

## write parameter to log file

echo "*** "  >> $log_file
echo "*** PARAMETER USED:"  >> $log_file
echo "*** Root device:"$root_device  >> $log_file
echo "*** Grub version:"$(grub --version)  >> $log_file
echo "*** Bundle folder:"$bundle_dir  >> $log_file
echo "*** Block device mapping:"$blockDevice  >> $log_file
echo "*** Partition flag:"$partition   >> $log_file
echo "*** Virtualization:"$virtual_type  >> $log_file
echo "*** S3 Bucket:"$s3_bucket  >> $log_file
echo "*** Manifest:"$prefix$date_fmt.manifest.xml  >> $log_file
echo "*** Region:"$aws_region  >> $log_file
echo "*** AMI name:"$aws_ami_name  >> $log_file
echo "*** AMI Id:"$aws_ami_id >> $log_file
echo "*** FINISHED Bundling AMI:$current_ami_id  in $period seconds" >> $log_file
