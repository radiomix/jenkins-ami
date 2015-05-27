#!/bin/bash
#
# Install ruby 2.0.0 needed for knife ec2 plugin
#

# install tools
sudo apt-get update
sudo apt-get install -y ruby-build autoconf bison

#build ruby 2.0.0 
sudo mkdir -p /opt/ruby_2.0.0-dev
sudo ruby-build  2.0.0-dev /opt/ruby_2.0.0-dev/

# link binaries with version
cd /usr/bin/
sudo ln -s /opt/ruby_2.0.0-dev/bin/erb  erb2.0.0
sudo ln -s /opt/ruby_2.0.0-dev/bin/gem  gem2.0.0
sudo ln -s /opt/ruby_2.0.0-dev/bin/irb  irb2.0.0
sudo ln -s /opt/ruby_2.0.0-dev/bin/rdoc  rdoc2.0.0
sudo ln -s /opt/ruby_2.0.0-dev/bin/ri  ri2.0.0
sudo ln -s /opt/ruby_2.0.0-dev/bin/ruby  ruby2.0.0
# link binaries without version
sudo ln -s erb2.0.0  erb
sudo ln -s gem2.0.0 gem
sudo ln -s ird2.0.0  ird
sudo ln -s rdoc2.0.0  rdoc
sudo ln -s ri2.0.0  ri
sudo ln -s ruby2.0.0  ruby
which ruby
