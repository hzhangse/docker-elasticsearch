#!/bin/bash
sudo umount /mnt/esmount/es0
sudo umount /mnt/esmount/es1
sudo umount /mnt/esmount/es2
sudo umount /mnt/esmount/es3
sudo umount /mnt/ramdisk1
sudo umount /mnt/ramdisk2
sudo rm -rf /mnt/esmount
sudo mkdir -p /mnt/esmount/es{0,1,2,3}

sudo mount -t glusterfs 172.19.0.101,172.19.0.102,172.19.0.103:/es0 /mnt/esmount/es0/
sudo mount -t glusterfs 172.19.0.101,172.19.0.102,172.19.0.103:/es1 /mnt/esmount/es1/
sudo mount -t glusterfs 172.19.0.101,172.19.0.102,172.19.0.103:/es2 /mnt/esmount/es2/
sudo mount -t glusterfs 172.19.0.101,172.19.0.102,172.19.0.103:/es3 /mnt/esmount/es3/

sudo rm -rf /mnt/ramdisk1
sudo rm -rf /mnt/ramdisk2
sudo mkdir /mnt/ramdisk1
sudo mkdir /mnt/ramdisk2
sudo mount -t ramfs none  /mnt/ramdisk1/ -o maxsize=500000
sudo mount -t ramfs none  /mnt/ramdisk2/ -o maxsize=500000
sudo chmod 777 -R /mnt/esmount
sudo chmod 777 -R /mnt/ramdisk1
sudo chmod 777 -R /mnt/ramdisk2
