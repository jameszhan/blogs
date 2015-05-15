---
layout: post
title:  在Raspberry Pi上安装ArchLinux
author: 詹子知(James Zhan)
date:   2015-04-30 23:00:00
meta:   版权所有，转载须声明出处
category: raspberrypi
tags: [raspberrypi, linux, archlinux, docker]
---

SD Card Creation
Replace sdX in the following instructions with the device name for the SD card as it appears on your computer.

Start fdisk to partition the SD card:
fdisk /dev/sdX
At the fdisk prompt, delete old partitions and create a new one:
Type o. This will clear out any partitions on the drive.
Type p to list partitions. There should be no partitions left.
Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
Type t, then c to set the first partition to type W95 FAT32 (LBA).
Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
Write the partition table and exit by typing w.
Create and mount the FAT filesystem:
mkfs.vfat /dev/sdX1
mkdir boot
mount /dev/sdX1 boot
Create and mount the ext4 filesystem:
mkfs.ext4 /dev/sdX2
mkdir root
mount /dev/sdX2 root
Download and extract the root filesystem (as root, not via sudo):
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root
sync
Move boot files to the first partition:
mv root/boot/* boot
Unmount the two partitions:
umount boot root
Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.
Use the serial console or SSH to the IP address given to the board by your router. The default root password is 'root'.

ArchLinux的包管理软件是[pacman][1]，类似apt-get，yum，brew等。

```sh
#更新整个系统，新安装好要运行一次
pacman -Syu && sync 

#完全清理包缓存
pacman -Scc 

# 安装应用程序
pacman -S gcc make git docker 
# 删除docker
pacman -R docker –nosave
```


[1]: http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2 "ArchLinux"
[2]: https://wiki.archlinux.org/index.php/Pacman "Pacman"