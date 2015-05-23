#!/bin/bash
#
# install etcd as of https://github.com/coreos/etcd/releases/tag/$version
#

version="v2.0.11"
echo "***INSTALLING ETCD version $version"
# Install ETCD
cd /usr/local
curl -L  https://github.com/coreos/etcd/releases/download/$version/etcd-$version-linux-amd64.tar.gz -o etcd-$version-linux-amd64.tar.gz
sudo tar xzvf etcd-$version-linux-amd64.tar.gz
# link binaries
sudo ln -v -s /usr/local/etcd-$version-linux-amd64/etcd /usr/local/bin
sudo ln -v -s /usr/local/etcd-$version-linux-amd64/etcdctl /usr/local/bin/

# copy default/init script to the right place
sudo mv /tmp/etcd.init /etc/init.d/etcd
sudo chown root.root /etc/init.d/etcd
sudo mv /tmp/etcd.default /etc/default/etcd
sudo chown root.root /etc/default/etcd

# link start/stop scripts
cd /etc/rc5.d/
sudo ln -v -s ../init.d/etcd S19etcd
cd /etc/rc2.d/
sudo ln -v -s ../init.d/etcd S19etcd

# check installation
export PATH=$PATH:/usr/local/bin
service etcd start
which etcd
which etcdctl
#
#

