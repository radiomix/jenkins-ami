#!/bin/bash
#
# install etcd as of https://github.com/coreos/etcd/releases/tag/${VERSION}
#

VERSION="v2.0.11"
echo "***INSTALLING ETCD VERSION ${VERSION}"
# Install ETCD
cd /usr/local
curl -L  https://github.com/coreos/etcd/releases/download/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz -o etcd-${VERSION}-linux-amd64.tar.gz
sudo tar xzvf etcd-${VERSION}-linux-amd64.tar.gz
# link binaries
sudo ln -v -s /usr/local/etcd-${VERSION}-linux-amd64/etcd /usr/local/bin
sudo ln -v -s /usr/local/etcd-${VERSION}-linux-amd64/etcdctl /usr/local/bin/

# copy default/init script to the right place
sudo mv -v /tmp/etcd.init /etc/init.d/etcd
sudo chown root.root /etc/init.d/etcd
sudo chmod a+x /etc/init.d/etcd
sudo mv -v /tmp/etcd.default /etc/default/etcd
sudo chown root.root /etc/default/etcd

# link start/stop script in run levels
sudo update-rc.d etcd start 19 2 3 4 5 . stop 19 0 1 6 .

# check installation
export PATH=$PATH:/usr/local/bin
service etcd start
which etcd
which etcdctl
#
#

