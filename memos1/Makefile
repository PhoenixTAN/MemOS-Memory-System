memos1_bootstrap: memos1
	dd bs=1 if=memos1 of=disk1.img count=446 conv=notrunc
	
memos1: memos1.o memos1.ld
	ld -T memos1.ld memos1.o -o memos1

memos1.o: memos1.s
	as --32 memos1.s -o memos1.o

clean:
	rm -rf memos1.o disk1.img memos1
