disk1.img: memos1
	# dd bs=1 if=memos1 of=memos1_bootstrap skip=4096 count=512
	dd bs=1 if=memos1 of=disk1.img skip=4096 count=32760
memos1: memos1.o memos1.ld
	ld -T memos1.ld memos1.o -o memos1

memos1.o: memos1.s
	as --32 memos1.s -o memos1.o

clean:
	rm -rf memos1.o disk1.img memos1
