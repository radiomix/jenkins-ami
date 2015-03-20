#!/bin/bash
sudo apt-get install mosh
lsblk 
### read the proper device
echo -n "Enter the proper device to be copied: "
read device
#sudo file -s /dev/xvda1
sudo file -s $device
sudo grub-install --version
### read the proper grub version
echo  "to be shure, we install grub verions 0.9x"
sudo apt-get insatll -y grub
sudo apt-get install -y grub gdisk kpartx
sudo apt-get update
grub-version=$(grub --version)
grub --version
### read the proper cmdline parameter to insert into menu.lst
cat /proc/cmdline
echo -n "Enter the Kernel parameter: "
read kernel-para
grep ^kernel /boot/grub/menu.lst
sudo vi /boot/grub/menu.lst
grep ^kernel /boot/grub/menu.lst
### remove evi entries if exist
ls /boot/efi*
### read the cert path
echo -n "Enter full cert path (/path/to/x509-cert-file.pem): "
read certPath
echo -n "Enter full pk path (/path/to/x509-pk-file.pem): "
read pkPath
sudo mkdir $certPath
sudo apt-get install -y openjdk-7-jre
sudo apt-get install -y unzip wget
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip 
sudo mkdir /usr/local/ec2/
sudo unzip ec2-api-tools.zip -d /usr/local/ec2/
which java
readlink -f /usr/bin/java 
### read the proper java home path
echo -n "Java home dir except bin" 
read java-home
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre/
export JAVA_HOME=$java-home
$JAVA_HOME/java -version
$JAVA_HOME/bin/java -version
ls  /usr/local/ec2/ec2-ap*
### read the proper ec2-home
echo -n "Enter the AWS ec2-api-tools folder: "
read ec2-home
#export EC2_HOME=/usr/local/ec2/ec2-api-tools-1.7.3.0/
export EC2_HOME=$ec2-home
export PATH=$PATH:$EC2_HOME/bin
ec2-version 
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
sudo unzip ec2-ami-tools.zip  -d /usr/local/ec2/
ls /usr/local/ec2/ec2-ami-tool*
### read the proper ec2-ami-home
echo -n "Enter the AWS ec2-ami-tools folder: "
read ec2-ami-home
#export EC2_AMITOOL_HOME=/usr/local/ec2/ec2-ami-tools-1.5.6/
export EC2_AMITOOL_HOME=$ec2-ami-home
export PATH=$PATH:$EC2_AMITOOL_HOME/bin
ec2-ami-tools-version 
sudo apt-get install -y ruby
ec2-ami-tools-version 
### read the aws-access-key value
#export AWS_ACCESS_KEY="MY-AWS-ACCESS-KEY"
if [[ "$AWS_ACCESS_KEY" == "" ]]
then 
  echo -n "Enter your awsAccessKey: "
  read awsAccessKey
  export AWS_ACCESS_KEY=$awsAccessKey
fi
echo " Using awsAccessKey\"$awsAccessKey\""
### read the aws-secret-key value
#export AWS_SECRET_KEY="MY-AWS-SECRET-KEY"
if [[ "$AWS_SECRET_KEY" == "" ]]
then 
  echo -n "Enter your awsSecretKey: "/
  read awsSecretKey
  export AWS_secret_KEY=$awsSecretKey
fi
echo " Using awsSecretKey\"$awsSecretKey\""
### read the aws-account-id value
#export AWS_ACCOUNT_ID="MY-AWS-ACCOUNT-ID"
if [[ "$AWS_ACCOUNT_ID" == "" ]]
then
  echo -n "Enter your aws account id: "
  read awsAccountId
  export AWS_ACCOUNT_ID=$aws-accont-id
fi
echo " Using aws-account-it\"$awsAccountId\""
ec2-ami-tools-version 
date-fmt=$(date '+%F-%H-%M-%S')
## get the directory to store the bundle
df -h
echo -n "Enter the folder to store the bundle (should be on a parition with more then 4GB left): "
read bundle-dir
sudo mkdir $bundle-dir
exit### this is bundle-work
sudo -E $EC2_HOME/bin/ec2-version
echo " bundle ami with block-device-mapping "
sudo -E $EC2_AMITOOL_HOME/bin/ec2-bundle-vol -k $pkPath -c $certPath -u $awsAccountId -r x86_64 -e /tmp/cert/ -d $bundle-dir -p image-sda-$date-fmt  --block-device-mapping ami=sda,root=/dev/sda1 --batch
ec2-upload-bundle  -b im7-backup/instance-prepared-sda -m /tmp/image-sda-$date-fmt.manifest.xml -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --region us-west-2
echo " bundle ami without block-device-mapping "
sudo -E $EC2_AMITOOL_HOME/bin/ec2-bundle-vol -k $pkPath -c $certPath -u $awsAccountId -r x86_64 -e /tmp/cert/ -d $bundle-dir -p image-no-sda-$date-fmt   --batch
ec2-upload-bundle  -b im7-backup/instance-prepared -m /tmp/image-no-sda-$date-fmt.manifest.xml -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY --region us-west-2
echo "Registering images"
ec2-register  im7-backup/instance-prepared/image-sda-$date-fmt.manifest.xml -n "instance-prepared" -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region us-west-2 
ec2-register  im7-backup/instance-prepared-sda/image-no-sda-$date-fmt.$.manifest.xml -n "instance-prepared-sda" -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region us-west-2 
