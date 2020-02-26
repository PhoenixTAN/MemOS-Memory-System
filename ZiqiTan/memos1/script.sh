as --32 memos1.s -o memos1.o
ld -T memos1.ld memos1.o -o memos1
dd bs=1 if=memos1 of=memos1_exec skip=4096 count=512
qemu-system-i386 -hda memos1_exec