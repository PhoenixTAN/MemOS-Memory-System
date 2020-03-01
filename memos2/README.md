# How to run this
## Teamwork: Ziqi Tan, Jiaqian Sun

## Step 1:
```
$ make
```

## Step 2: copy the memos-2 to /mydisk2/boot/
```
$ make install
```

## Step 3:
```
qemu-system-i386 disk.img
```

## Step 4:
```
$ cd /vnc/opt/TigerVNC
$ ./vncviewer :5900
```

## Step 5:
```
grub> kernel /boot/memos-2
grub> boot
```
