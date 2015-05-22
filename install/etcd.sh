#!/bin/bash
#
# install etcd as of https://github.com/coreos/etcd/releases/tag/$version
#

version="v2.0.11"
echo "***INSTALLING ETCD version $version"
# Install ETCD
cd /usr/local
curl -L  https://github.com/coreos/etcd/releases/download/$version/etcd-$version-linux-amd64.tar.gz -o etcd-$version-linux-amd64.tar.gz
tar xzvf etcd-$version-linux-amd64.tar.gz
ln -v -s /usr/local/etcd-$version-linux-amd64/etcd /usr/local/bin
ln -v -s /usr/local/etcd-$version-linux-amd64/etcdctl /usr/local/bin/
#
export PATH=$PATH:/usr/local/bin
which etcd
which etcdctl

