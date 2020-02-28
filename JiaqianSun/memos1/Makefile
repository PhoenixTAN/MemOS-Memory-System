memos1_bootstrap: memos1
	dd bs=1 if=memos1 of=memos1_bootstrap skip=4096 count=512

memos1: memos1.o memos1.ld
	ld -T memos1.ld memos1.o -o memos1

memos1.o: memos1.s
	as --32 memos1.s -o memos1.o

install: memos1_bootstrap
	cp memos1_bootstrap /root/mydisk/boot

clean:
	rm -rf memos1.o memos1_bootstrap memos1
