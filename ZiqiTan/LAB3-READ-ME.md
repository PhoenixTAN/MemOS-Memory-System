# Lab 3: Virtual Disk and Grub
## Preliminaries
Tasks for today:
1. Build a virtual disk
2. Install Grub onto the virtual disk

## Virtual Disk
* Disk = An array of sectors
* Disk size = number of sectors * size of sector (512 bytes)

```
$ sudo fdisk -l /dev/sda
```
* virtual disk = a piece of the real disk
* So how to create a virtual disk?
* use echo to create a virtual disk, mydisk.img
```
dd if=/dev/zero of=disk.img bs=1k count=32760
```

```
ls -lah

hexdump disk.img

fdisk disk.img
```

format this partition

What is a partition?

```
losetup -o 32256 /dev/loop0 disk.img
```
Where do we get 32256 the first cylinder? 

What is loop0?

```
mke2fs /dev/loop0
```

```
losetup -d /dev/loop0
```

```
mount disk.img mydisk/ -text2 -o loop, offset=32256
```

```
mkdir -p boot/grub
```

hd0: hard disk 0

Install grub...

* I wrote something into the disk? Next time, how am I gonna find the thing I wrote?
* Need some place to store the bookkeeping data
* What is the layout of the contents in the disk?
* partition table:
```
$ sudo fdisk -l /dev/sda 
```
*  (what about mydisk.img?)
Before creating partitions: hexdump mydisk.img
Now give mydisk.img some partitions: fdisk mydisk.img
Create one big partition on the entire disk. hexdump again. What has been overwritten?
What about want a second partition?
Format the first partition to ext2: mkfs.ext2 mydisk.img?
Only partition has file system: verifiy it by $mount
How to format a partition in a virtual disk -- how to format a real partition
Expose partition as a device: losetup /dev/loop0 mydisk.img?
losetup -o [offset] /dev/loop0 mydisk.img. Now to the kernel, loop0 is a real partition
Now format loop0, mount loop0, write a file (again, to the kernel, it is a real fs/partition). hexdump again. umount, losetup -d

## Grub
When reading a file, fs kernel code runs to read from the disk
Kernel image is a file in /boot
Chicken and egg problem: when booting kernel, who reads kernel image from disk
Reserve the first sector: MBR. How to put fs code into MBR?
Find fs code in grub
Install grub to MBR
In puppy, mount the partition
mkdir -p boot/grub
copy over files /boot/grub
$grub
device (hd0) /path/to/disk.img
root (hd0,0)
setup (hd0t)
test it out: qemu-system-i386 -hda disk.img
