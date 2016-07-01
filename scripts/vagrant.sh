#!/usr/bin/env bash

mkdir /home/vagrant/.ssh
wget --no-check-certificate -O authorized_keys 'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
mv authorized_keys /home/vagrant/.ssh
chown -R vagrant.vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# fix selinux + SSH key stuff
restorecon -r /home/vagrant/.ssh

# vagrant needs passwordless sudo
echo '%vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/vagrant

# disable requiretty
sed -i.bak -r "s/.*(Defaults.*requiretty)$/#\1/" /etc/sudoers
