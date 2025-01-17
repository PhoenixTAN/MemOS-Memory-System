# ** Copyright Rich West, Boston University **
#	
# Test vga settings using real mode
# This dumps various register values used for setting up a video
# mode such as 16 color 640x480.
#	
# Originally developed as a bootup routine to reverse-engineer a VGA-based
# video driver for the Quest OS, to support Pacman.
# If it can't play Pacman it's not a proper OS!	

# All assembler directives have names that begin with a period (`.'). 
# The rest of the name is letters, usually in lower case.

.text	
	.global _start	# start entry
	
	.code16		# code will be run in 16-bit mode.

# start 
_start:
	movw $0x9000, %ax	# ax, bx, cx and dx are general purpose registers
	# we cannot set up the ss register directly
	movw %ax, %ss	# initialize the stack segment
	xorw %sp, %sp	# clear the stack pointer

# set video mode
	movw $0x0003, %ax
	int $0x10	# BIOS interrupts call
	# INT 10
	# Function: Set video mode
	# Function code: AH=00H
	# Parameters: AL = video mode, in this scenario AL=03H
	# Return: AL = video mode flag / CRT controller mode byte.

# sequencer	
	movw $0x3c4, %dx	# 
	xorb %al, %al	# clear al
	movw $5, %cx	# set up the loop times for 5
1:	
	outb %al, %dx
	incw %dx
	pushw %ax
	inb %dx, %al
	decw %dx

	call print
	
	popw %ax
	incb %al
	loop 1b		# go backward for code segment 1

	movw $0x0e0d, %ax
	movw $0x07, %bx
	int $0x10
	movw $0x0e0a, %ax
	movw $0x07, %bx
	int $0x10

# attribute controller	
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

# graphics register
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

# crt controller	
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

# misc o/p register
	movw $0x3cc, %dx
	inb %dx, %al

	call print

1:	jmp 1b		# 

# print function
# Function: print Hex from dec.
# eg: 10(d) = 0x0a, then we should add 55 to get the ascii code of 'a'
print:	
	pushw %dx		# save dx
	movb %al, %dl	# save al in dl
	shrb $4, %al	# shift right for 4 bits
	cmpb $10, %al	# compare 10 with al
	jge 1f			# if 10 >= %al, then jump foward to segment 1
	addb $0x30, %al
	jmp 2f
1:	addb $55, %al	
	
	# call BIOS interrupt	
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

	# call BIOS interrupt		
2:	movb $0x0E, %ah
	movw $0x07, %bx
	int $0x10
	popw %dx		# restore dx
	ret				# return

# This is going to be in our MBR for Bochs, so we need a valid signature
	.org 0x1FE

	.byte 0x55
	.byte 0xAA

# To test:	
# as --32 vga16.s -o vga16.o
# ld -T vga.ld vga16.o -o vga16
# dd bs=1 if=vga16 of=vga16_test skip=4096 count=512
# bochs -qf bochsrc-vga
