# ** Copyright Rich West, Boston University **
#	
# Test vga settings using real mode
# This dumps various register values used for setting up a video
# mode such as 16 color 640x480.
#	
# Originally developed as a bootup routine to reverse-engineer a VGA-based
# video driver for the Quest OS, to support Pacman.
# If it can't play Pacman it's not a proper OS!	
 
	.globl _start
	
	.code16
# 16位 汇编
# xorw 为32位逻辑异或
# 由于没有直接将操作数存入es的指令，所以需要通过ax中转
# start 为函数起始

_start:
	movw $0x9000, %ax
    # 栈的基地址
	movw %ax, %ss
	xorw %sp, %sp

# set video mode
# 可以在如下网站查看到中断信息以及寄存器位置：http://www.ctyme.com/intr/int-10.htm	
# ah中00+int10设置video mode， al中03对应80x25
	movw $0x0003, %ax
	int $0x10
# xor eax, eax ; 在C语言中，都是以EAX寄存器作为返回值


#inb 从I/O端口读取一个字节(BYTE, HALF-WORD) ;
#outb 向I/O端口写入一个字节（BYTE, HALF-WORD） ;
#inw 从I/O端口读取一个字（WORD，即两个字节） ;
#outw 向I/O端口写入一个字（WORD，即两个字节） ;
#word inw(word port); ;
#void outb(word port, byte value);
#OUT 21H,AL；将AL的值写入21H端口
#IN AL,21H；表示从21H端口读取一字节数据到AL
#push: 将ax,bx入栈, 但是入栈压栈到底有什么用
#看起来是入栈之后才能读出al的内容，然后再pop出来

#自减指令dec decw:16位dec指令

# sequencer	
	movw $0x3c4, %dx
	xorb %al, %al
	movw $5, %cx
    #设置循环寄存器，即循环5次
1:	
	outb %al, %dx
	incw %dx
	pushw %ax
	inb %dx, %al
	decw %dx
    # print是吧al打印出来

	call print
	
	popw %ax
	incb %al
	loop 1b
    #b：backward
    #换行：0d，ah为主要操作，此处0e为输出一个自负，0d为/r
	movw $0x0e0d, %ax
	movw $0x07, %bx
	int $0x10
	movw $0x0e0a, %ax
	movw $0x07, %bx
	int $0x10

#attribute controller	
	movw $0x3c0, %dx
	movb $0x10, %al
	movw $4, %cx
1:	
	outb %al, %dx
	incw %dx
	pushw %ax
	inb %dx, %al
	decw %dx
	
	call print
	
	popw %ax
	incb %al
	loop 1b

	movb $0x34, %al
	outb %al, %dx
	incw %dx
	inb %dx, %al

	call print

	movw $0x0e0d, %ax
	movw $0x07, %bx
	int $0x10
	movw $0x0e0a, %ax
	movw $0x07, %bx
	int $0x10

#inc自增操作


#graphics register
	movw $0x3ce, %dx
	xorb %al, %al
	movw $9, %cx
1:	
	outb %al, %dx
	incw %dx
	pushw %ax
	inb %dx, %al
	decw %dx

	call print
	
	popw %ax
	incb %al
	loop 1b

	movw $0x0e0d, %ax
	movw $0x07, %bx
	int $0x10
	movw $0x0e0a, %ax
	movw $0x07, %bx
	int $0x10

#crt controller	
	movw $0x3d4, %dx
	xorb %al, %al
	movw $25, %cx
1:	
	outb %al, %dx
	incw %dx
	pushw %ax
	inb %dx, %al
	decw %dx

	call print
	
	popw %ax
	incb %al
	loop 1b

	movw $0x0e0d, %ax
	movw $0x07, %bx
	int $0x10
	movw $0x0e0a, %ax
	movw $0x07, %bx
	int $0x10


#shrb右移指令
#jge 转移条件：sf异或of=0  转移说明：大于等于转移
#misc o/p register
	movw $0x3cc, %dx
	inb %dx, %al

	call print

1:	jmp 1b

#先存起来dx	
#每次输出只能输出一个字，长度为2个word
print:	pushw %dx
	movb %al, %dl
	shrb $4, %al
	cmpb $10, %al
	jge 1f
    # forward
	addb $0x30, %al
	jmp 2f
1:	addb $55, %al	
# 避免输出数字，a的asci为65	
#输出到屏幕
2:	movb $0x0E, %ah
	movw $0x07, %bx
	int $0x10

	movb %dl, %al
	andb $0x0f, %al
	cmpb $10, %al
	jge 1f
	addb $0x30, %al
	jmp 2f
1:	addb $55, %al		
2:	movb $0x0E, %ah
	movw $0x07, %bx
	int $0x10
	popw %dx
	ret

# This is going to be in our MBR for Bochs, so we need a valid signature
	.org 0x1FE
#org为汇编生成
	.byte 0x55
	.byte 0xAA

# To test:	
# as --32 vga16.s -o vga16.o
# ld -T vga.ld vga16.o -o vga16
# dd bs=1 if=vga16 of=vga16_test skip=4096 count=512
# bochs -qf bochsrc-vga
	