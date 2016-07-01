#!/usr/bin/env bash

ISO_PATH=~/VBoxGuestAdditions.iso
MNT_PATH=/tmp/virtualbox

mkdir $MNT_PATH
mount -o loop $ISO_PATH $MNT_PATH
sh $MNT_PATH/VBoxLinuxAdditions.run
umount $MNT_PATH
rmdir $MNT_PATH
rm $ISO_PATH
