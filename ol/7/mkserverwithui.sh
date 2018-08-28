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

# You must have the Install ISO from oracle in same directory as the script
if [ ! -f "V921569-01.iso" ]; then
        echo "Original OL7 Install ISO must be in the same directory as this script"
        exit 1
fi

# Get ISO Image
mkdir -p ISOTMP
sudo mkdir -p /mnt/cdrom
cp V921569-01.iso ./ISOTMP/
cd ISOTMP
sudo mount -o loop V921569-01.iso /mnt/cdrom
rm -rf image
mkdir -p image
rsync -av /mnt/cdrom/ image/
sudo umount /mnt/cdrom

cd image/isolinux
chmod 755 .
chmod 644 isolinux.cfg
sudo sed -i 's/  append initrd=initrd.img inst.stage2=hd:LABEL=OL-7.4\\x20Server.x86_64 rd.live.check quiet/  append initrd=initrd.img inst.ks=http:\/\/installs.truemark.io\/ol\/7\/server-with-ui-ks.cfg inst.txt quiet/' isolinux.cfg

sudo sed -i 's/timeout 600/timeout 1/' isolinux.cfg
cd ../../
sudo find image -type d -exec chmod 755 {} \;
sudo find image -type f -exec chmod 644 {} \;

mkisofs -r -V "TrueMark OL7 UI" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o truemark-OL-7.4-ui.iso image/

sudo rm -fr image
cd ISOTMP
sha1sum truemark-OL-7.4-ui.iso > truemark-OL-7.4-ui.iso.sha1
scp -P 2020 truemark-OL-7.4-ui.iso download@69.160.74.206:oracle/Oracle\ Linux\ 7/
scp -P 2020 truemark-OL-7.4-ui.iso.sha1 download@69.160.74.206:oracle/Oracle\ Linux\ 7/
