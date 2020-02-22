vga16_test: vga16
	dd bs=1 if=vga16 of=disk.img skip=4096 count=512

vga16-1: vga16.o memos-1.ld
	ld -T vga16.ld vga16.o -o vga16

vga16.o: vga16.s
	as --32 vga16.s -o vga16.o

clean:
	rm -rf vga16.o vga16_test vga16
