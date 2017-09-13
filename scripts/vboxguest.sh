#! /bin/bash

# stackios is missing a few rpms used for compiling guest additions
/opt/stack/bin/stack add pallet /root/vbox_deps*iso
/opt/stack/bin/stack enable pallet vbox_deps
rm /root/vbox_deps*iso

yum install -y gcc kernel-devel kernel-headers

# Mount and install the Guest Additions
ISO_PATH=~/VBoxGuestAdditions.iso
MNT_PATH=/tmp/virtualbox

mkdir $MNT_PATH
mount -o loop $ISO_PATH $MNT_PATH
sh $MNT_PATH/VBoxLinuxAdditions.run
umount $MNT_PATH
rmdir $MNT_PATH
rm $ISO_PATH
