scp tanzi@10.0.2.2:D:/CS-552-Operating-System/CS-552-Syc-Folder/Linux-Kernel-Programming/4-MemOS/MemOS-Simple-Memory-System/ZiqiTan/vga/* ./
as --32 vga16.s -o vga16.o
ld -T vga16.ld vga16.o -o vga16
dd bs=1 if=vga16 of=vga16_test skip=4096 count=512
qemu-system-i386 -hda vga16_test