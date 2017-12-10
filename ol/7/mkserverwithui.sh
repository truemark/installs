#!/usr/bin/env bash

# NOTES:
#
# This version of the script creates an OL 7 ISO that will do a
# server install with UI.
#
# Currently the script assumes that the VM has the OL 7 ISO downloaded
# and connected, but not mounted on whichever system you're creating
# the install ISO on.

set -uex

DIR=$(dirname ${0})
cd $DIR

# Get ISO Image
mkdir -p ISOTMP
cd ISOTMP
sudo mount -o loop /dev/cdrom /media/cdrom
rm -rf image
mkdir -p image
rsync -av /media/cdrom/ image/
sudo umount /media/cdrom

cd image/isolinux
chmod 755 .
chmod 644 isolinux.cfg
sudo sed -i 's/  append initrd=initrd.img inst.stage2=hd:LABEL=OL-7.4\\x20Server.x86_64 rd.live.check quiet/  append initrd=initrd.img inst.ks=http:\/\/installs.truemark.io\/ol\/7\/server-with-ui-ks.cfg inst.txt quiet/' isolinux.cfg

sudo sed -i 's/timeout 6/timeout 0/' isolinux.cfg
cd ../../
sudo find image -type d -exec chmod 755 {} \;
sudo find image -type f -exec chmod 644 {} \;

mkisofs -r -V "TrueMark Oracle Server with UI Linux Install CD" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o truemark-OL-7.4-server-with-ui-x86_64.iso image/
