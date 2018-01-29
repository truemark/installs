#!/usr/bin/env bash

set -uex

DIR=$(dirname ${0})
cd $DIR

# Get ISO Image
mkdir -p ISOTMP
cd ISOTMP
wget -c http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-server-amd64.iso
sudo mkdir -p /mnt/cdrom
sudo mount -o loop ubuntu-16.04.3-server-amd64.iso /mnt/cdrom
rm -rf image
mkdir -p image
rsync -av /mnt/cdrom/ image/
sudo umount /mnt/cdrom

cd image/isolinux
chmod 755 .
chmod 644 txt.cfg
sudo sed -i 's/file=\/cdrom\/preseed\/ubuntu-server.seed vga=788 initrd=\/install\/initrd.gz/auto=true priority=critical url=http:\/\/installs.truemark.io\/ubuntu\/16.04\/vmware.seed vga=788 initrd=\/install\/initrd.gz/' txt.cfg
sudo sed -i 's/timeout 0/timeout 1/' isolinux.cfg
cd ../../
sudo find image -type d -exec chmod 755 {} \;
sudo find image -type f -exec chmod 644 {} \;

mkisofs -r -V "TrueMark Ubuntu Install CD" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o truemark-vmware-ubuntu-16.04.3-server-amd64.iso image/

sudo rm -rf image
sha1sum truemark-vmware-ubuntu-16.04.3-server-amd64.iso > truemark-vmware-ubuntu-16.04.3-server-amd64.iso.sha1
scp truemark-vmware-ubuntu-16.04.3-server-amd64.iso download@172.16.224.50:iso/
scp truemark-vmware-ubuntu-16.04.3-server-amd64.iso.sha1 download@172.16.224.50:iso/
