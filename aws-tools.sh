#!/bin/bash
# Prepare an AMI with the AWS API/AMI tools
#   http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/set-up-ec2-cli-linux.html
#   http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/set-up-ami-tools.html
#  Prerequisites:
#   - we need installed:
#		ruby, default-jre (openjdk-6/7-jre), unzip, wget, openssl
#   - we need to export our $AWS_ACCESS_KEY and $AWS_SECRET_KEY as enironment variables like:
#       export AWS_ACCESS_KEY=your_access_key_id
#       export AWS_SECRET_KEY=your_secret_access_key
#   - some commands need sudo rights
#   - we need our AWS x509-pk/cert files on this machine
#
# CAUTION: to export env variables properly, this script should be called
#  $:>. aws-tools.sh
#
#######################################
## config variables

# aws credentials, mayb in env variables?
aws_secret_key=$AWS_SECRET_KEY
aws_access_key=$AWS_ACCESS_KEY
aws_account_id=$AWS_ACCOUNT_ID

# region
aws_region=$AWS_REGION

# architecture
aws_architecture=$AWS_ARCHITECTURE

## config variables

######################################
## packages needed anyways
echo "*** Installing packages 'ruby default-jre unzip wget openssl'"
sudo apt-get -q update
sudo apt-get -q install -y --force-yes ruby default-jre unzip wget openssl
## we experienced curl SSL errors as in
## http://tiku.io/questions/3051603/amazon-ec2-s3-self-signed-certificate-ssl-failure-when-using-ec2-upload-bundle
## so we reload the root certificates
sudo update-ca-certificates

######################################
## install api/ami tools under /usr/local/ec2
echo "*** Installing AWS TOOLS"
prefix="/usr/local/ec2/"
sudo mkdir $prefix
sudo rm -rf $prefix/*
rm -f ec2-ami-tools.zip ec2-api-tools.zip

wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
sudo unzip -q ec2-api-tools.zip -d /usr/local/ec2/
sudo unzip -q ec2-ami-tools.zip  -d /usr/local/ec2/

######################################
# get java install path
echo "*** SETTING JAVA PATH"
java_bin=$(which java)
java_path=$(readlink -f $java_bin)
echo $java_bin  $java_path
java_home=${java_path/'/bin/java'/''}
### set java home path
export JAVA_HOME=$java_home
echo "*** JAVA_HOME set to  \"$java_home\"" 
$JAVA_HOME/bin/java -version

######################################
### set ec2-home variable
echo "*** SETTING AWS TOOL PATH"
ami_tool=$prefix$(ls /usr/local/ec2 | grep ami)
api_tool=$prefix$(ls /usr/local/ec2 | grep api)
export EC2_AMITOOL_HOME=$ami_tool
export EC2_HOME=$api_tool
export PATH=$PATH:$EC2_AMITOOL_HOME/bin:$EC2_HOME/bin

### check if sudo ec2-path is ok:
sudo -E $EC2_HOME/bin/ec2-version
sudo -E $EC2_AMITOOL_HOME/bin/ec2-ami-tools-version

echo "*** EC2_HOME set to  \"$api_tool\""
echo "*** EC2_AMITOOL_HOME set to  \"$ami_tool\""
echo

######################################
### set the aws-access/secret-key/account-id

if [[ "$aws_access_key" == "" ]]
then
  echo -n "Enter your AWS_ACCESS_KEY:"
  read aws_access_key
  export AWS_ACCESS_KEY=$aws_access_key
fi

if [[ "$aws_secret_key" == "" ]]
then
  echo -n "Enter your AWS_SECRET_KEY:"
  read aws_secret_key
  export AWS_SECRET_KEY=$aws_secret_key
fi

if [[ "$aws_account_id" == "" ]]
then
  echo -n "Enter your AWS_ACCOUNT_ID:"
  read aws_account_id
  export AWS_ACCOUNT_ID=$aws_account_id
fi

if [[ "$aws_region" == "" ]]; then
    echo -n "Enter your AWS_REGION:"
    read aws_region
    export AWS_REGION=$aws_region
fi

if [[ "$aws_architecture" == "" ]]; then
    echo -n "Enter your AWS ARCHITECTURE:"
    read aws_architecture
    export AWS_ARCHITECTURE=$aws_architecture
fi

export AWS_ACCESS_KEY
export AWS_SECRET_KEY
export AWS_ACCOUND_ID
export AWS_REGION
export AWS_ARCHITECTURE

aws_access_key=${AWS_ACCESS_KEY:0:3}********${AWS_ACCESS_KEY:${#AWS_ACCESS_KEY}-3:3}
aws_secret_key=${AWS_SECRET_KEY:0:3}********${AWS_SECRET_KEY:${#AWS_SECRET_KEY}-3:3}
aws_account_id=${AWS_ACCOUNT_ID:0:3}********${AWS_ACCOUNT_ID:${#AWS_ACCOUNT_ID}-3:3}
echo
echo "*** Using AWS_ACCESS_KEY:   \"$aws_access_key\""
echo "*** Using AWS_SECRET_KEY:   \"$aws_secret_key\""
echo "*** Using AWS_ACCOUNT_ID:   \"$aws_account_id\""
echo "*** Using AWS_REGION:       \"$aws_region\""
echo "*** Using AWS_ARCHITECTURE: \"$aws_architecture\""
echo

######################################
### set x509-pd/cert file path 
if [ -d /tmp/cert/ ]; then # may be in /tmp/cert?
   echo "Found these files in /tmp/cert/ "
   ls /tmp/cert/
fi

if [[ "$AWS_CERT_PATH" == "" ]]
then
  echo -n "Enter /path/to/x509-cert.pem: "
  read awsCertPath
  if [ ! -f "$awsCertPath"  ]; then
        echo "*** ERROR: AWS X509 CERT FILE NOT FOUND IN:$awsCertPath"
        return -1
  fi
  export AWS_CERT_PATH=$awsCertPath
fi

if [[ "$AWS_PK_PATH" == "" ]]
then
  echo -n "Enter /path/to/x509-pk.pem: "
  read awsPkPath
  if [  ! -f "$awsPkPath" ]; then
        echo "*** ERROR: AWS X509 PK FILE NOT FOUND IN:$awsPkPath"
        return -1
  fi
  export AWS_PK_PATH=$awsPkPath
fi

echo "*** Using x509-cert.pem \"$AWS_CERT_PATH\""
echo "*** Using x509-pk.pem \"$AWS_PK_PATH\""
echo 
echo "***  DONE WHITH $0"

