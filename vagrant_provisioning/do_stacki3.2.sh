#! /bin/bash
# Vagrant runs its provisioning scripts as root.

cat /vagrant/vagrant_provisioning/site.attrs

mount -o loop /vagrant/isos/stacki*3.2*iso /mnt/
cp /mnt/frontend-install.py /tmp/
umount /mnt

# change installer instructions for vagrant
chmod +w /tmp/frontend-install.py
sed -i -r "s/Reboot/Run 'vagrant halt \&\& vagrant up'/" /tmp/frontend-install.py

# copy a basic preconfigured set of stacki attributes
cp /vagrant/vagrant_provisioning/site.attrs /tmp/
cp /vagrant/vagrant_provisioning/rolls.xml /tmp/

# install the frontend
/tmp/frontend-install.py \
--stacki-name=stacki \
--stacki-version=3.2 \
--stacki-iso=/vagrant/isos/stacki-3.2-7.x.x86_64.disk1.iso \
--os-name=CentOS \
--os-version=7.2 \
--os-iso=/vagrant/isos/CentOS-7-x86_64-Everything-1511.iso

# give the vagrant user access to stacki commands
cat >> /home/vagrant/.stackipathrc <<EOF
export PATH=\$PATH:/opt/stack/bin:/opt/stack/sbin 
EOF

source /home/vagrant/.stackipathrc
/opt/stack/bin/stack set access command="*" group=vagrant

# Fix the gateway to point to the NAT network interface so we can get out
sed -i -r "s/^GATEWAY=.*$/GATEWAY=10.0.2.2/" /etc/sysconfig/network

