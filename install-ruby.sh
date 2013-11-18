#!/bin/bash

PLATFORM=`uname -m`

if [ $PLATFORM = i686 ]
then
  PLATFORM=i386
fi

echo "Platform is $PLATFORM"

yum install -y wget bzip2 tar make gcc ntp sudo git

wget http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
rpm --import ./RPM-GPG-KEY-EPEL-6

wget http://dl.fedoraproject.org/pub/epel/6/$PLATFORM/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm

sed -i "s/https/http/" /etc/yum.repos.d/epel.repo

yum install -y libyaml-devel 

echo "Setting time to avoid makefile warning..."
ntpdate pool.ntp.org

echo "Downloading src tarballs..."
cd /tmp
if [ ! -f /tmp/ruby-install-0.2.1.tar.gz ]; then
    wget --no-check-certificate -O ruby-install-0.2.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.2.1.tar.gz
fi

if [ ! -d /tmp/ruby-install-0.2.1 ]; then
    tar -xzvf ruby-install-0.2.1.tar.gz
fi

if [ ! -f /tmp/chruby-0.3.6.tar.gz ]; then
    wget --no-check-certificate -O chruby-0.3.6.tar.gz https://github.com/postmodern/chruby/archive/v0.3.6.tar.gz
fi

if [ ! -d /tmp/chruby-0.3.6 ]; then
    tar -xzvf chruby-0.3.6.tar.gz
fi

echo "Setting up ruby-install..."
(cd ruby-install-0.2.1/ && make install)

if [ ! -d /opt/rubies/ruby-1.9.3-p448 ]; then
    echo "Installing ruby 1.9.3..."
    /usr/local/bin/ruby-install ruby 1.9.3-p448
fi

if [ -f /usr/local/bin/ruby-install ]; then
    echo "Setting up chruby..."
    (cd chruby-0.3.6/ && make install)
fi

if [ ! -f /etc/profile.d/chruby.sh ]; then
    echo "Set up 1.9.3 as default ruby version"
    echo "source /usr/local/share/chruby/chruby.sh && chruby 1.9.3-p448" >> /etc/profile.d/chruby.sh
    chmod a+x /etc/profile.d/chruby.sh
fi

echo "Ruby 1.9.3 installed, ready on next login/new shell."